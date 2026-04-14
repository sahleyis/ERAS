import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

/// Demo/mock user for preview mode (no Firebase needed).
final demoUser = UserModel(
  uid: 'demo-user-001',
  displayName: 'Dahir Ahmed',
  email: 'dahir@eras.ng',
  phone: '+2348012345678',
  role: UserRole.both,
  medicalProfile: const MedicalProfile(
    bloodType: 'O+',
    allergies: ['Penicillin', 'Peanuts'],
    chronicConditions: ['Asthma'],
    emergencyContactName: 'Amina Ahmed',
    emergencyContactPhone: '+2348098765432',
    emergencyContactRelation: 'Spouse',
  ),
  responderProfile: const ResponderProfile(
    specialization: Specialization.doctor,
    licenseNumber: 'MDCN/2024/12345',
    verificationStatus: VerificationStatus.verified,
    isActive: true,
    rating: 4.8,
    totalResponses: 23,
  ),
  createdAt: DateTime(2024, 1, 15),
);

/// Whether the app is running in demo mode (no Firebase).
final isDemoModeProvider = StateProvider<bool>((ref) => false);

/// The demo user provider - returns the mock user when in demo mode.
final demoUserProvider = StateProvider<UserModel?>((ref) => null);
