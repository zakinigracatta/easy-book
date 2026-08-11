import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

export { createBooking } from './booking/createBooking';
export { createWalkInBooking } from './booking/createWalkInBooking';
export { cancelBooking } from './booking/cancelBooking';
export { rescheduleBooking } from './booking/rescheduleBooking';
export { updateBookingStatus } from './booking/updateBookingStatus';
