/**
 * ERAS — FCM Notification Dispatch
 *
 * Callable Cloud Function for sending emergency notifications.
 * Used as a fallback when the client-side needs to trigger
 * notifications directly.
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Send a high-priority emergency notification to a specific device.
 */
export const sendEmergencyNotification = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Must be authenticated to send notifications'
      );
    }

    const { token, emergencyId, emergencyType, distance } = data;

    if (!token || !emergencyId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields: token, emergencyId'
      );
    }

    const distanceText = distance
      ? `${Math.round(distance)}m away`
      : 'nearby';

    try {
      await admin.messaging().send({
        token,
        notification: {
          title: '🚨 Emergency Alert',
          body: `${emergencyType || 'Medical'} emergency ${distanceText} — tap to respond`,
        },
        data: {
          emergencyId,
          type: emergencyType || 'other',
          distance: String(distance || 0),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          ttl: 60000, // 60 second TTL
          notification: {
            channelId: 'eras_emergency',
            priority: 'max',
            sound: 'emergency_alert',
            tag: `emergency_${emergencyId}`,
            vibrateTimingsMillis: [0, 500, 200, 500, 200, 500],
            lightSettings: {
              color: '#FF0000',
              lightOnDurationMillis: 500,
              lightOffDurationMillis: 200,
            },
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
            'apns-push-type': 'alert',
            'apns-expiration': String(Math.floor(Date.now() / 1000) + 60),
          },
          payload: {
            aps: {
              alert: {
                title: '🚨 Emergency Alert',
                body: `${emergencyType || 'Medical'} emergency ${distanceText}`,
                'launch-image': 'emergency_alert',
              },
              badge: 1,
              sound: {
                critical: 1,
                name: 'emergency_alert.caf',
                volume: 1.0,
              },
              'content-available': 1,
              'mutable-content': 1,
              'interruption-level': 'critical',
              'relevance-score': 1.0,
            },
          },
        },
      });

      return { success: true };
    } catch (error) {
      console.error('[ERAS] Notification send error:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send notification'
      );
    }
  }
);

/**
 * Send a notification when a responder accepts an emergency.
 * Triggered by emergency document update to 'matched' status.
 */
export const onEmergencyMatched = functions.firestore
  .document('emergencies/{emergencyId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger when status changes to 'matched'
    if (before.status === 'matched' || after.status !== 'matched') {
      return;
    }

    const victimId = after.victimId;
    const responderName = after.responderName || 'A responder';

    // Get victim's FCM token
    const victimDoc = await admin.firestore()
      .collection('responder_locations')
      .doc(victimId)
      .get();

    const victimToken = victimDoc.data()?.fcmToken;
    if (!victimToken) return;

    // Notify victim
    try {
      await admin.messaging().send({
        token: victimToken,
        notification: {
          title: '✅ Help is on the way!',
          body: `${responderName} has accepted your emergency alert`,
        },
        data: {
          emergencyId: context.params.emergencyId,
          type: 'matched',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'eras_emergency',
            priority: 'max',
            sound: 'match_success',
          },
        },
        apns: {
          headers: { 'apns-priority': '10' },
          payload: {
            aps: {
              sound: 'match_success.caf',
              'interruption-level': 'time-sensitive',
            },
          },
        },
      });
    } catch (err) {
      console.error('[ERAS] Failed to notify victim of match:', err);
    }
  });
