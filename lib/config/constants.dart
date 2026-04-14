/// ERAS Application Constants
///
/// Centralized configuration for search parameters, emergency types,
/// and app-wide values.
library;

// ─── Search Algorithm Configuration ──────────────────────────
/// Progressive search radii in kilometers.
/// System starts at 0.5km and expands outward.
const List<double> kSearchRadiiKm = [0.5, 1.0, 2.0, 5.0];

/// Time to wait for responder acceptance at each radius tier.
const Duration kRadiusTimeout = Duration(seconds: 30);

/// Maximum total search duration before escalation.
const Duration kMaxSearchDuration = Duration(seconds: 120);

/// Minimum interval between location updates (meters).
const double kLocationDistanceFilter = 10.0;

/// Location update interval for active responders.
const Duration kLocationUpdateInterval = Duration(seconds: 5);

// ─── Emergency Types ─────────────────────────────────────────
enum EmergencyType {
  cardiac(
    label: 'Cardiac',
    description: 'Heart attack, chest pain, cardiac arrest',
    icon: 'favorite',
    colorHex: 0xFFE53935,
  ),
  trauma(
    label: 'Trauma',
    description: 'Severe injury, accident, fall, wound',
    icon: 'local_hospital',
    colorHex: 0xFFFF6F00,
  ),
  respiratory(
    label: 'Respiratory',
    description: 'Difficulty breathing, asthma attack',
    icon: 'air',
    colorHex: 0xFF1565C0,
  ),
  burn(
    label: 'Burn',
    description: 'Fire burn, chemical burn, scalding',
    icon: 'whatshot',
    colorHex: 0xFFE65100,
  ),
  choking(
    label: 'Choking',
    description: 'Airway obstruction, swallowing hazard',
    icon: 'warning',
    colorHex: 0xFF6A1B9A,
  ),
  other(
    label: 'Other',
    description: 'Other medical emergency',
    icon: 'medical_services',
    colorHex: 0xFF546E7A,
  );

  const EmergencyType({
    required this.label,
    required this.description,
    required this.icon,
    required this.colorHex,
  });

  final String label;
  final String description;
  final String icon;
  final int colorHex;
}

// ─── Emergency Status ────────────────────────────────────────
enum EmergencyStatus {
  searching,
  matched,
  inProgress,
  resolved,
  cancelled,
  escalated,
}

// ─── User Roles ──────────────────────────────────────────────
enum UserRole {
  victim,
  responder,
  both,
}

// ─── Responder Specializations ───────────────────────────────
enum Specialization {
  doctor('Doctor', 'MD'),
  nurse('Nurse', 'RN'),
  paramedic('Paramedic', 'EMT'),
  pharmacist('Pharmacist', 'PharmD'),
  firstAid('First Aid Certified', 'FA');

  const Specialization(this.label, this.abbreviation);

  final String label;
  final String abbreviation;
}

// ─── Verification Status ─────────────────────────────────────
enum VerificationStatus {
  pending,
  verified,
  rejected,
}

// ─── Blood Types ─────────────────────────────────────────────
const List<String> kBloodTypes = [
  'A+', 'A-',
  'B+', 'B-',
  'AB+', 'AB-',
  'O+', 'O-',
  'Unknown',
];

// ─── Nigeria Emergency Numbers ───────────────────────────────
const String kNigeriaEmergencyNumber = '112';
const String kNemaHotline = '0800-CALL-NEMA';
const String kAmbulanceNumber = '199';

// ─── Firestore Collections ───────────────────────────────────
const String kUsersCollection = 'users';
const String kEmergenciesCollection = 'emergencies';
const String kResponderLocationsCollection = 'responder_locations';
const String kChatSubcollection = 'chat';
const String kMedicalProfileSubcollection = 'medical_profile';

// ─── FCM Topics ──────────────────────────────────────────────
const String kActiveRespondersTopicPrefix = 'responders_active_';

// ─── Map Configuration ───────────────────────────────────────
const double kDefaultMapZoom = 15.0;
const double kNavigationMapZoom = 17.0;

/// Default center: Lagos, Nigeria
const double kDefaultLatitude = 6.5244;
const double kDefaultLongitude = 3.3792;

// ─── Timing ──────────────────────────────────────────────────
const Duration kAnimationFast = Duration(milliseconds: 200);
const Duration kAnimationMedium = Duration(milliseconds: 400);
const Duration kAnimationSlow = Duration(milliseconds: 800);
const Duration kPulseAnimationDuration = Duration(milliseconds: 1500);
