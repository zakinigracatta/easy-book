import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easy_book/admin/repositories/admin_repository.dart';
import 'package:easy_book/models/user_model.dart';

void main() {
  group('AdminRepository business workflow', () {
    test('lists and filters the real businesses collection', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('businesses').doc('verified').set({
        'name': 'Verified Salon',
        'is_verified': true,
      });
      await firestore.collection('businesses').doc('pending').set({
        'name': 'Pending Salon',
        'is_verified': false,
      });
      final repository = AdminRepository(firestore: firestore);

      expect(await repository.listBusinesses(), hasLength(2));
      final pending = await repository.listBusinesses(verified: false);
      expect(pending.single.id, 'pending');
    });

    test('admin can approve and customer cannot mutate a business', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('businesses').doc('business').set({
        'name': 'Easy Salon',
        'is_verified': false,
      });
      final repository = AdminRepository(firestore: firestore);

      await repository.setBusinessVerified(
        actorRole: UserRole.admin,
        businessId: 'business',
        verified: true,
      );
      expect(
        (await firestore.collection('businesses').doc('business').get())
            .data()?['is_verified'],
        isTrue,
      );

      await expectLater(
        repository.setBusinessVerified(
          actorRole: UserRole.customer,
          businessId: 'business',
          verified: false,
        ),
        throwsStateError,
      );
    });

    test('loads business details from existing subcollections', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('owner').set({
        'full_name': 'Owner Name',
        'role': 'owner',
      });
      await firestore.collection('businesses').doc('business').set({
        'name': 'Easy Salon',
        'owner_id': 'owner',
        'is_verified': true,
      });
      await firestore
          .collection('businesses')
          .doc('business')
          .collection('services')
          .doc('service')
          .set({'name': 'Haircut'});
      await firestore.collection('bookings').doc('booking').set({
        'salon_id': 'business',
        'service_name': 'Haircut',
      });

      final details = await AdminRepository(firestore: firestore)
          .businessDetails('business');
      expect(details.owner?.text(['full_name']), 'Owner Name');
      expect(details.services.single.text(['name']), 'Haircut');
      expect(details.bookings.single.id, 'booking');
    });
  });
}
