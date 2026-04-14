import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

/// Emergency model representing an active or historical emergency event.
class EmergencyModel {
  final String id;
  final String victimId;
  final String victimName;
  final EmergencyType type;
  final String? description;
  final EmergencyStatus status;
  final GeoPoint location;
  final String? address;
  final DateTime? createdAt;
  final DateTime? matchedAt;
  final DateTime? resolvedAt;
  final double currentSearchRadius; // in meters
  final String? responderId;
  final String? responderName;
  final double? responderEta; // minutes
  final List<String> notifiedResponders;
  final List<String> declinedResponders;

  const EmergencyModel({
    required this.id,
    required this.victimId,
    required this.victimName,
    required this.type,
    this.description,
    this.status = EmergencyStatus.searching,
    required this.location,
    this.address,
    this.createdAt,
    this.matchedAt,
    this.resolvedAt,
    this.currentSearchRadius = 500,
    this.responderId,
    this.responderName,
    this.responderEta,
    this.notifiedResponders = const [],
    this.declinedResponders = const [],
  });

  factory EmergencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EmergencyModel(
      id: doc.id,
      victimId: data['victimId'] as String? ?? '',
      victimName: data['victimName'] as String? ?? '',
      type: EmergencyType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'other'),
        orElse: () => EmergencyType.other,
      ),
      description: data['description'] as String?,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'searching'),
        orElse: () => EmergencyStatus.searching,
      ),
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      address: data['address'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      matchedAt: (data['matchedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      currentSearchRadius:
          (data['currentSearchRadius'] as num?)?.toDouble() ?? 500,
      responderId: data['responderId'] as String?,
      responderName: data['responderName'] as String?,
      responderEta: (data['responderEta'] as num?)?.toDouble(),
      notifiedResponders:
          List<String>.from(data['notifiedResponders'] ?? []),
      declinedResponders:
          List<String>.from(data['declinedResponders'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'victimId': victimId,
      'victimName': victimName,
      'type': type.name,
      'description': description,
      'status': status.name,
      'location': location,
      'address': address,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'matchedAt':
          matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
      'resolvedAt':
          resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'currentSearchRadius': currentSearchRadius,
      'responderId': responderId,
      'responderName': responderName,
      'responderEta': responderEta,
      'notifiedResponders': notifiedResponders,
      'declinedResponders': declinedResponders,
    };
  }

  EmergencyModel copyWith({
    EmergencyStatus? status,
    double? currentSearchRadius,
    String? responderId,
    String? responderName,
    double? responderEta,
    List<String>? notifiedResponders,
    List<String>? declinedResponders,
    DateTime? matchedAt,
    DateTime? resolvedAt,
  }) {
    return EmergencyModel(
      id: id,
      victimId: victimId,
      victimName: victimName,
      type: type,
      description: description,
      status: status ?? this.status,
      location: location,
      address: address,
      createdAt: createdAt,
      matchedAt: matchedAt ?? this.matchedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      currentSearchRadius:
          currentSearchRadius ?? this.currentSearchRadius,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      responderEta: responderEta ?? this.responderEta,
      notifiedResponders:
          notifiedResponders ?? this.notifiedResponders,
      declinedResponders:
          declinedResponders ?? this.declinedResponders,
    );
  }

  /// Duration since emergency was created.
  Duration get elapsed {
    if (createdAt == null) return Duration.zero;
    return DateTime.now().difference(createdAt!);
  }

  /// Whether the emergency is still active.
  bool get isActive =>
      status == EmergencyStatus.searching ||
      status == EmergencyStatus.matched ||
      status == EmergencyStatus.inProgress;

  /// Human-readable search radius.
  String get searchRadiusLabel {
    if (currentSearchRadius >= 1000) {
      return '${(currentSearchRadius / 1000).toStringAsFixed(1)}km';
    }
    return '${currentSearchRadius.toInt()}m';
  }
}
