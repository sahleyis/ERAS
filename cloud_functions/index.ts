import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Re-export Cloud Function modules
export { onEmergencyCreated } from './proximity_search';
export { sendEmergencyNotification } from './send_notification';
