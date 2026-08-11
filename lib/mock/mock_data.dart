import '../models/user_model.dart';
import '../models/business_model.dart';
import '../models/appointment_model.dart';

class MockData {
  static const String defaultCustomerAvatar =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80';
  static const String defaultSalonBanner =
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80';

  static final UserModel sampleCustomer = UserModel(
    id: 'cust_101',
    email: 'ahmed.m@example.com',
    fullName: 'Ahmed Mohamed',
    phone: '+1 (555) 234-5678',
    avatarUrl: defaultCustomerAvatar,
    role: UserRole.customer,
    walletBalance: 240.00,
  );

  static final UserModel sampleOwner = UserModel(
    id: 'owner_202',
    email: 'owner@executivebarber.com',
    fullName: 'Executive Barber Lounge',
    phone: '+1 (555) 987-6543',
    role: UserRole.owner,
    businessName: 'Executive Barber Lounge',
    category: 'Barber',
    location: '142 Luxury Blvd, Downtown NYC',
    businessImageUrl: defaultSalonBanner,
  );

  static final List<BusinessModel> businesses = [
    BusinessModel(
      id: 'b1',
      name: 'Executive Barber Lounge',
      category: 'Barber',
      address: '142 Luxury Blvd, Downtown NYC',
      rating: 4.9,
      reviewCount: 328,
      imageUrl:
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description:
          'Premium grooming experience with luxury drinks and hot towel treatment.',
      ownerId: 'owner_202',
    ),
    BusinessModel(
      id: 'b2',
      name: 'Royal Spa & Wellness',
      category: 'Spa & Relax',
      address: '88 Serenity Way, Upper West NYC',
      rating: 4.8,
      reviewCount: 210,
      imageUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description: 'Holistic skin rejuvenation and deep tissue massages.',
      ownerId: 'owner_203',
    ),
    BusinessModel(
      id: 'b3',
      name: 'Elegance Hair Couture',
      category: 'Hair Salon',
      address: '45 Fashion St, Midtown NYC',
      rating: 4.95,
      reviewCount: 540,
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description:
          'Master colorists, balayage specialists, and precision hair styling.',
      ownerId: 'owner_204',
    ),
  ];

  static final List<AppointmentModel> appointments = [
    AppointmentModel(
      id: 'apt_101',
      customerId: 'cust_101',
      businessId: 'b1',
      businessName: 'Executive Barber Lounge',
      serviceName: 'Royal Haircut & Beard Sculpting',
      servicePrice: 65.0,
      staffName: 'Marcus Vance',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: AppointmentStatus.confirmed,
    ),
    AppointmentModel(
      id: 'apt_102',
      customerId: 'cust_101',
      businessId: 'b2',
      businessName: 'Royal Spa & Wellness',
      serviceName: 'Deep Tissue Spa Massage',
      servicePrice: 90.0,
      staffName: 'Elena Rostova',
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      status: AppointmentStatus.completed,
    ),
  ];
}
