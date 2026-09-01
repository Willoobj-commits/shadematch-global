class VisualReference {
  const VisualReference({
    required this.id,
    required this.kind,
    required this.label,
    required this.verificationStatus,
    required this.rightsStatus,
    required this.matchEligible,
    required this.isPrimary,
    this.displayHex,
    this.imageUrl,
    this.sourceUrl,
    this.disclaimer,
    this.measurementMethod,
  });

  factory VisualReference.fromJson(Map<String, dynamic> json) {
    return VisualReference(
      id: json['id'] as String,
      kind: json['kind'] as String,
      label: json['label'] as String,
      verificationStatus: json['verificationStatus'] as String? ?? 'unverified',
      rightsStatus: json['rightsStatus'] as String? ?? 'unknown',
      matchEligible: json['matchEligible'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayHex: json['displayHex'] as String?,
      imageUrl: json['imageUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      disclaimer: json['disclaimer'] as String?,
      measurementMethod: json['measurementMethod'] as String?,
    );
  }

  final String id;
  final String kind;
  final String label;
  final String verificationStatus;
  final String rightsStatus;
  final bool matchEligible;
  final bool isPrimary;
  final String? displayHex;
  final String? imageUrl;
  final String? sourceUrl;
  final String? disclaimer;
  final String? measurementMethod;

  bool get isProfileEstimate => kind == 'universal_profile_estimate';

  bool get isQuantitativeEvidence =>
      matchEligible &&
      (kind == 'spectrophotometer_measurement' ||
          kind == 'calibrated_standardized_swatch');
}
