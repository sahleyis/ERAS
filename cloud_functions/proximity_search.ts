/**
 * ERAS — Server-Side Expanding Search Algorithm
 *
 * Triggered when a new emergency document is created in Firestore.
 * Runs the expanding radius search on the server side for reliability
 * (works even if the victim's app crashes after sending).
 *
 * Algorithm:
 *   1. Listen for new emergency documents
 *   2. Query active responders within 500m using GeoHash
 *   3. Send FCM high-priority notifications
 *   4. Wait 30s for acceptance
 *   5. If no acceptance → expand to 1km → 2km → 5km
 *   6. If 5km exhausted → mark as escalated
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as geohash from 'ngeohash';

const db = admin.firestore();

// Search radii in kilometers
const SEARCH_RADII_KM = [0.5, 1.0, 2.0, 5.0];

// Timeout per radius in milliseconds
const RADIUS_TIMEOUT_MS = 30000;

/**
 * Calculate GeoHash bounds for a given center and radius.
 */
function getGeohashBounds(
  latitude: number,
  longitude: number,
  radiusKm: number
): { lower: string; upper: string }[] {
  const lat = 0.0089831; // Degrees per km (approx)
  const lon = 0.0089831 / Math.cos(latitude * Math.PI / 180);

  const lowerLat = latitude - lat * radiusKm;
  const upperLat = latitude + lat * radiusKm;
  const lowerLon = longitude - lon * radiusKm;
  const upperLon = longitude + lon * radiusKm;

  const lower = geohash.encode(lowerLat, lowerLon, 9);
  const upper = geohash.encode(upperLat, upperLon, 9);

  return [{ lower, upper }];
}

/**
 * Calculate distance between two points using Haversine formula.
 */
function haversineDistance(
  lat1: number, lon1: number,
  lat2: number, lon2: number
): number {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Wait for emergency status to change to 'matched'.
 */
function waitForAcceptance(
  emergencyId: string,
  timeoutMs: number
): Promise<boolean> {
  return new Promise((resolve) => {
    const timeout = setTimeout(() => {
      unsubscribe();
      resolve(false);
    }, timeoutMs);

    const unsubscribe = db
      .collection('emergencies')
      .doc(emergencyId)
      .onSnapshot((snapshot) => {
        const data = snapshot.data();
        if (data?.status === 'matched') {
          clearTimeout(timeout);
          unsubscribe();
          resolve(true);
        }
      });
  });
}

/**
 * Cloud Function: Triggered on emergency creation.
 */
export const onEmergencyCreated = functions.firestore
  .document('emergencies/{emergencyId}')
  .onCreate(async (snapshot, context) => {
    const emergencyId = context.params.emergencyId;
    const emergencyData = snapshot.data();

    if (!emergencyData) return;

    const victimLocation = emergencyData.location as admin.firestore.GeoPoint;
    const latitude = victimLocation.latitude;
    const longitude = victimLocation.longitude;
    const emergencyType = emergencyData.type || 'other';

    console.log(`[ERAS] Emergency created: ${emergencyId}, type: ${emergencyType}`);
    console.log(`[ERAS] Location: ${latitude}, ${longitude}`);

    const allNotified: string[] = [];

    for (let i = 0; i < SEARCH_RADII_KM.length; i++) {
      const radiusKm = SEARCH_RADII_KM[i];

      console.log(`[ERAS] Searching at radius: ${radiusKm}km`);

      // Update search radius in emergency document
      await db.collection('emergencies').doc(emergencyId).update({
        currentSearchRadius: radiusKm * 1000,
        status: 'searching',
      });

      // Query active responders using GeoHash range
      const bounds = getGeohashBounds(latitude, longitude, radiusKm);

      const respondersQuery = await db
        .collection('responder_locations')
        .where('isActive', '==', true)
        .where('position.geohash', '>=', bounds[0].lower)
        .where('position.geohash', '<=', bounds[0].upper)
        .get();

      // Filter by exact distance and exclude already notified
      const newResponders: admin.firestore.DocumentSnapshot[] = [];

      for (const doc of respondersQuery.docs) {
        if (allNotified.includes(doc.id)) continue;

        const data = doc.data();
        const responderGeopoint = data?.position?.geopoint;
        if (!responderGeopoint) continue;

        const distance = haversineDistance(
          latitude, longitude,
          responderGeopoint.latitude, responderGeopoint.longitude
        );

        if (distance <= radiusKm) {
          newResponders.push(doc);
        }
      }

      console.log(`[ERAS] Found ${newResponders.length} new responders at ${radiusKm}km`);

      // Send notifications
      if (newResponders.length > 0) {
        const tokens: string[] = [];
        const newIds: string[] = [];

        for (const doc of newResponders) {
          const data = doc.data();
          if (data?.fcmToken) {
            tokens.push(data.fcmToken);
          }
          newIds.push(doc.id);
          allNotified.push(doc.id);
        }

        // Send FCM high-priority notifications
        if (tokens.length > 0) {
          try {
            await admin.messaging().sendEachForMulticast({
              tokens,
              notification: {
                title: '🚨 Emergency Alert',
                body: `${emergencyType} emergency nearby — tap to respond`,
              },
              data: {
                emergencyId,
                type: emergencyType,
                latitude: latitude.toString(),
                longitude: longitude.toString(),
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'eras_emergency',
                  priority: 'max',
                  sound: 'emergency_alert',
                  vibrateTimingsMillis: [0, 500, 200, 500],
                },
              },
              apns: {
                headers: {
                  'apns-priority': '10',
                  'apns-push-type': 'alert',
                },
                payload: {
                  aps: {
                    alert: {
                      title: '🚨 Emergency Alert',
                      body: `${emergencyType} emergency nearby`,
                    },
                    sound: {
                      critical: 1,
                      name: 'emergency_alert.caf',
                      volume: 1.0,
                    },
                    'content-available': 1,
                    'interruption-level': 'critical',
                  },
                },
              },
            });
            console.log(`[ERAS] Notifications sent to ${tokens.length} devices`);
          } catch (err) {
            console.error('[ERAS] FCM error:', err);
          }
        }

        // Track notified responders
        await db.collection('emergencies').doc(emergencyId).update({
          notifiedResponders: admin.firestore.FieldValue.arrayUnion(newIds),
        });
      }

      // Wait for acceptance
      console.log(`[ERAS] Waiting ${RADIUS_TIMEOUT_MS}ms for acceptance...`);
      const accepted = await waitForAcceptance(emergencyId, RADIUS_TIMEOUT_MS);

      if (accepted) {
        console.log(`[ERAS] ✅ Emergency ${emergencyId} matched!`);
        return;
      }

      console.log(`[ERAS] No acceptance at ${radiusKm}km, expanding...`);
    }

    // No responder found — escalate
    console.log(`[ERAS] ⚠️ Emergency ${emergencyId} escalated — no responder found`);
    await db.collection('emergencies').doc(emergencyId).update({
      status: 'escalated',
    });
  });
