import 'visual_reference.dart';

class Shade {
  const Shade({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.origin,
    required this.marketScope,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.shadeCode,
    required this.universalDepth,
    required this.depthFamily,
    required this.undertoneCode,
    required this.undertoneName,
    required this.universalProfile,
    required this.status,
    required this.normalizationBasis,
    required this.sourceUrl,
    required this.sourceType,
    required this.verifiedDate,
    required this.qualityFlags,
    required this.visualReferences,
    this.shadeName,
    this.manufacturerDepth,
    this.manufacturerUndertone,
    this.sourceCoverageNote,
  });

  factory Shade.fromJson(Map<String, dynamic> json) {
    return Shade(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      brandName: json['brandName'] as String,
      origin: json['origin'] as String? ?? 'Unknown',
      marketScope: json['marketScope'] as String? ?? 'Unspecified',
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productType: json['productType'] as String? ?? 'Complexion',
      shadeCode: json['shadeCode'] as String,
      shadeName: json['shadeName'] as String?,
      manufacturerDepth: json['manufacturerDepth'] as String?,
      manufacturerUndertone: json['manufacturerUndertone'] as String?,
      universalDepth: json['universalDepth'] as int,
      depthFamily: json['depthFamily'] as String,
      undertoneCode: json['undertoneCode'] as String,
      undertoneName: json['undertoneName'] as String,
      universalProfile: json['universalProfile'] as String,
      status: json['status'] as String,
      normalizationBasis: json['normalizationBasis'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sourceType: json['sourceType'] as String? ?? 'Unclassified source',
      sourceCoverageNote: json['sourceCoverageNote'] as String?,
      verifiedDate: json['verifiedDate'] as String,
      qualityFlags:
          (json['qualityFlags'] as List<dynamic>? ?? const []).cast<String>(),
      visualReferences: (json['visualReferences'] as List<dynamic>? ?? const [])
          .map((item) => VisualReference.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String brandId;
  final String brandName;
  final String origin;
  final String marketScope;
  final String productId;
  final String productName;
  final String productType;
  final String shadeCode;
  final String? shadeName;
  final String? manufacturerDepth;
  final String? manufacturerUndertone;
  final int universalDepth;
  final String depthFamily;
  final String undertoneCode;
  final String undertoneName;
  final String universalProfile;
  final String status;
  final String normalizationBasis;
  final String sourceUrl;
  final String sourceType;
  final String? sourceCoverageNote;
  final String verifiedDate;
  final List<String> qualityFlags;
  final List<VisualReference> visualReferences;

  String get displayName {
    final name = shadeName?.trim();
    return name == null || name.isEmpty || name == shadeCode
        ? shadeCode
        : '$shadeCode · $name';
  }

  String get searchText => [
        brandName,
        productName,
        shadeCode,
        shadeName,
        manufacturerDepth,
        manufacturerUndertone,
        universalProfile,
      ].whereType<String>().join(' ').toLowerCase();

  VisualReference? get primaryVisual {
    for (final visual in visualReferences) {
      if (visual.isPrimary) return visual;
    }
    return visualReferences.isEmpty ? null : visualReferences.first;
  }

  bool get hasOfficialImage => visualReferences.any(
        (visual) =>
            visual.imageUrl != null &&
            (visual.kind == 'official_digital_swatch' ||
                visual.kind == 'official_product_image'),
      );

  bool get hasQuantitativeVisual =>
      visualReferences.any((visual) => visual.isQuantitativeEvidence);

  bool get isCurrent => status.toLowerCase() == 'current';
}

class BrandDirectoryEntry {
  const BrandDirectoryEntry({
    required this.id,
    required this.name,
    required this.dataStatus,
    required this.sourceStatus,
    this.origin,
    this.primaryRegion,
  });

  factory BrandDirectoryEntry.fromJson(Map<String, dynamic> json) {
    return BrandDirectoryEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      origin: json['origin'] as String?,
      primaryRegion: json['primaryRegion'] as String?,
      dataStatus: json['dataStatus'] as String,
      sourceStatus: json['sourceStatus'] as String? ?? 'Awaiting shade data',
    );
  }

  final String id;
  final String name;
  final String? origin;
  final String? primaryRegion;
  final String dataStatus;
  final String sourceStatus;

  bool get isVerified => dataStatus == 'verified';
}

class UndertoneDefinition {
  const UndertoneDefinition({
    required this.code,
    required this.name,
    this.vector,
  });

  factory UndertoneDefinition.fromJson(Map<String, dynamic> json) {
    return UndertoneDefinition(
      code: json['code'] as String,
      name: json['name'] as String,
      vector: (json['vector'] as List<dynamic>?)
          ?.map((value) => (value as num).toDouble())
          .toList(growable: false),
    );
  }

  final String code;
  final String name;
  final List<double>? vector;
}
