import '../models/user_model.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';
import '../models/employee_model.dart';
import '../models/booking_model.dart';

class MockData {
  static const String defaultCustomerAvatar =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80';
  static const String defaultSalonBanner =
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80';

  // --- Users Collection ---
  static final UserModel customerUser = UserModel(
    id: 'cust_101',
    email: 'ahmed.m@example.com',
    fullName: 'Ahmed Mohamed',
    phone: '+1 (555) 234-5678',
    avatarUrl: defaultCustomerAvatar,
    role: UserRole.customer,
    walletBalance: 240.00,
  );

  static final UserModel ownerUser = UserModel(
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

  static final UserModel adminUser = UserModel(
    id: 'admin_303',
    email: 'admin@easybook.com',
    fullName: 'Platform Super Admin',
    phone: '+1 (555) 000-1111',
    role: UserRole.admin,
  );

  // --- Salons Collection ---
  static final List<SalonModel> salons = [
    SalonModel(
      id: 's1',
      name: 'Executive Barber Lounge',
      category: 'Barber',
      address: '142 Luxury Blvd, Downtown NYC',
      rating: 4.9,
      reviewCount: 328,
      imageUrl:
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      ownerId: 'owner_202',
      description:
          'Premium grooming experience with luxury drinks and hot towel treatment.',
    ),
    SalonModel(
      id: 's2',
      name: 'Royal Spa & Wellness',
      category: 'Spa & Relax',
      address: '88 Serenity Way, Upper West NYC',
      rating: 4.8,
      reviewCount: 210,
      imageUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      ownerId: 'owner_203',
      description: 'Holistic skin rejuvenation and deep tissue massages.',
    ),
    SalonModel(
      id: 's3',
      name: 'Elegance Hair Couture',
      category: 'Hair Salon',
      address: '45 Fashion St, Midtown NYC',
      rating: 4.95,
      reviewCount: 540,
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      ownerId: 'owner_204',
      description:
          'Master colorists, balayage specialists, and precision hair styling.',
    ),
  ];

  // --- Services Collection ---
  static final List<ServiceModel> services = [
    ServiceModel(
      id: 'srv_1',
      salonId: 's1',
      name: 'Royal Haircut & Beard Sculpting',
      price: 65.0,
      duration: '45 mins',
      durationMinutes: 45,
      description:
          'Hair wash, precision haircut, beard sculpt and hot towel treatment.',
    ),
    ServiceModel(
      id: 'srv_2',
      salonId: 's1',
      name: 'Hot Towel Royal Shave',
      price: 45.0,
      duration: '30 mins',
      durationMinutes: 30,
      description:
          'Classic straight razor shave with essential oils and hot wrap.',
    ),
    ServiceModel(
      id: 'srv_3',
      salonId: 's2',
      name: 'Deep Tissue Spa Massage',
      price: 90.0,
      duration: '60 mins',
      durationMinutes: 60,
      description: 'Therapeutic full body massage for muscular tension relief.',
    ),
  ];

  // --- Employees Collection ---
  static final List<EmployeeModel> employees = [
    EmployeeModel(
      id: 'emp_1',
      salonId: 's1',
      name: 'Marcus Vance',
      role: 'Master Barber & Stylist',
      rating: 4.9,
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      isAvailable: true,
      shiftHours: '09:00 AM - 05:00 PM',
    ),
    EmployeeModel(
      id: 'emp_2',
      salonId: 's1',
      name: 'Elena Rostova',
      role: 'Senior Colorist',
      rating: 5.0,
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      isAvailable: true,
      shiftHours: '10:00 AM - 06:00 PM',
    ),
    EmployeeModel(
      id: 'emp_3',
      salonId: 's2',
      name: 'David Kim',
      role: 'Massage Specialist',
      rating: 4.8,
      avatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      isAvailable: false,
      shiftHours: '12:00 PM - 08:00 PM',
    ),
  ];

  // --- Bookings Collection ---
  static final List<BookingModel> bookings = [
    BookingModel(
      id: 'bk_101',
      customerId: 'cust_101',
      customerName: 'Ahmed Mohamed',
      businessId: 's1',
      businessName: 'Executive Barber Lounge',
      serviceId: 'srv_1',
      serviceName: 'Royal Haircut & Beard Sculpting',
      servicePrice: 65.0,
      staffId: 'emp_1',
      staffName: 'Marcus Vance',
      startDateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      endDateTime:
          DateTime.now().add(const Duration(days: 1, hours: 2, minutes: 45)),
      status: BookingStatus.confirmed,
    ),
    BookingModel(
      id: 'bk_102',
      customerId: 'cust_101',
      customerName: 'Ahmed Mohamed',
      businessId: 's2',
      businessName: 'Royal Spa & Wellness',
      serviceId: 'srv_3',
      serviceName: 'Deep Tissue Spa Massage',
      servicePrice: 90.0,
      staffId: 'emp_2',
      staffName: 'Elena Rostova',
      startDateTime: DateTime.now().subtract(const Duration(days: 4)),
      endDateTime: DateTime.now()
          .subtract(const Duration(days: 4))
          .add(const Duration(minutes: 60)),
      status: BookingStatus.completed,
    ),
  ];
}
