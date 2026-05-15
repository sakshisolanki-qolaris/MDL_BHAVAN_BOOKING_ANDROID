class FacilityModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final String? facilityType;
  final double baseRate;
  final int? maxCapacity;
  final List<String> images;
  final String? pricingType;
  final Map<String, dynamic>? pricingDetails;
  final int inventoryCount;
  final double securityDeposit;
  final bool isActive;

  FacilityModel({
    required this.id,
    required this.name,
    this.description,
    this.baseRate = 0,
    this.imageUrl,
    this.isAvailable = true,
    this.facilityType,
    this.maxCapacity,
    this.images = const [],
    this.pricingType,
    this.pricingDetails,
    this.inventoryCount = 1,
    this.securityDeposit = 0,
    this.isActive = true,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      baseRate: double.tryParse(json['baseRate']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      facilityType: json['facilityType'],
      maxCapacity: int.tryParse(json['maxCapacity']?.toString() ?? ''),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      pricingType: json['pricingType'],
      pricingDetails: json['pricingDetails'],
      inventoryCount: int.tryParse(json['inventoryCount']?.toString() ?? '1') ?? 1,
      securityDeposit: double.tryParse(json['securityDeposit']?.toString() ?? '0') ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'baseRate': baseRate,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'facilityType': facilityType,
      'maxCapacity': maxCapacity,
      'images': images,
      'pricingType': pricingType,
      'pricingDetails': pricingDetails,
      'inventoryCount': inventoryCount,
      'securityDeposit': securityDeposit,
      'isActive': isActive,
    };
  }
}

