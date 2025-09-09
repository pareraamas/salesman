import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
class StoreModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'owner_name')
  final String? ownerName;

  @JsonKey(name: 'latitude')
  final double? latitude;

  @JsonKey(name: 'longitude')
  final double? longitude;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'distance', includeIfNull: false)
  final double? distance;

  @JsonKey(name: 'unit', includeIfNull: false)
  final String? unit;

  @JsonKey(name: 'created_at', includeIfNull: false)
  final String? createdAt;

  @JsonKey(name: 'updated_at', includeIfNull: false)
  final String? updatedAt;

  StoreModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    this.phone,
    this.ownerName,
    this.latitude,
    this.longitude,
    this.status = 'active',
    this.distance,
    this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);

  // Copy with method for immutability
  StoreModel copyWith({
    int? id,
    String? code,
    String? name,
    String? address,
    String? phone,
    String? ownerName,
    double? latitude,
    double? longitude,
    String? status,
    double? distance,
    String? unit,
  }) {
    return StoreModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      ownerName: ownerName ?? this.ownerName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      unit: unit ?? this.unit,
    );
  }

  /// Get full photo URL for the store
  /// Returns null if STORAGE_URL is not configured or store is not active
  String? get fullPhotoUrl {
    final storageUrl = dotenv.env['STORAGE_URL'];
    if (storageUrl != null && storageUrl.isNotEmpty && status == 'active') {
      return '$storageUrl/stores/$id.jpg';
    }
    return null;
  }

  // Check if store is open
  bool get isActive => status == 'active';
}
