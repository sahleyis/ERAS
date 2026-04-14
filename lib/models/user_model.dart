import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

/// Medical profile data model for a user.
/// Contains sensitive health information only visible
/// to an assigned responder during an active emergency.
class MedicalProfile {
  final String bloodType;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final DateTime? lastUpdated;

  const MedicalProfile({
    this.bloodType = 'Unknown',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.emergencyContactRelation = '',
    this.lastUpdated,
  });

  factory MedicalProfile.fromMap(Map<String, dynamic> map) {
    return MedicalProfile(
      bloodType: map['bloodType'] as String? ?? 'Unknown',
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
      emergencyContactName: map['emergencyContactName'] as String? ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] as String? ?? '',
      emergencyContactRelation: map['emergencyContactRelation'] as String? ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  MedicalProfile copyWith({
    String? bloodType,
    List<String>? allergies,
    List<String>? chronicConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) {
    return MedicalProfile(
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      lastUpdated: lastUpdated,
    );
  }

  bool get hasEmergencyContact =>
      emergencyContactName.isNotEmpty && emergencyContactPhone.isNotEmpty;

  bool get isComplete =>
      bloodType != 'Unknown' && hasEmergencyContact;
}

/// Responder-specific profile data.
class ResponderProfile {
  final Specialization specialization;
  final String licenseNumber;
  final VerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final bool isActive;
  final double rating;
  final int totalResponses;

  const ResponderProfile({
    this.specialization = Specialization.firstAid,
    this.licenseNumber = '',
    this.verificationStatus = VerificationStatus.pending,
    this.verifiedAt,
    this.verifiedBy,
    this.isActive = false,
    this.rating = 0.0,
    this.totalResponses = 0,
  });

  factory ResponderProfile.fromMap(Map<String, dynamic> map) {
    return ResponderProfile(
      specialization: Specialization.values.firstWhere(
        (e) => e.name == (map['specialization'] as String? ?? 'firstAid'),
        orElse: () => Specialization.firstAid,
      ),
      licenseNumber: map['licenseNumber'] as String? ?? '',
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == (map['verificationStatus'] as String? ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: map['verifiedBy'] as String?,
      isActive: map['isActive'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalResponses: map['totalResponses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'specialization': specialization.name,
      'licenseNumber': licenseNumber,
      'verificationStatus': verificationStatus.name,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      'isActive': isActive,
      'rating': rating,
      'totalResponses': totalResponses,
    };
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;
}

/// User model representing both victims and responders.
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String? photoUrl;
  final UserRole role;
  final MedicalProfile medicalProfile;
  final ResponderProfile? responderProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.email = '',
    this.phone = '',
    this.photoUrl,
    this.role = UserRole.victim,
    this.medicalProfile = const MedicalProfile(),
    this.responderProfile,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] as String? ?? 'victim'),
        orElse: () => UserRole.victim,
      ),
      medicalProfile: data['medicalProfile'] != null
          ? MedicalProfile.fromMap(data['medicalProfile'] as Map<String, dynamic>)
          : const MedicalProfile(),
      responderProfile: data['responderProfile'] != null
          ? ResponderProfile.fromMap(data['responderProfile'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.name,
      'medicalProfile': medicalProfile.toMap(),
      if (responderProfile != null)
        'responderProfile': responderProfile!.toMap(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    UserRole? role,
    MedicalProfile? medicalProfile,
    ResponderProfile? responderProfile,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      medicalProfile: medicalProfile ?? this.medicalProfile,
      responderProfile: responderProfile ?? this.responderProfile,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isResponder =>
      role == UserRole.responder || role == UserRole.both;

  bool get isVictim =>
      role == UserRole.victim || role == UserRole.both;

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}
