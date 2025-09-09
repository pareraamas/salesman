// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => StoreModel(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  ownerName: json['owner_name'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  status: json['status'] as String? ?? 'active',
  distance: (json['distance'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$StoreModelToJson(StoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'owner_name': instance.ownerName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': instance.status,
      'distance': ?instance.distance,
      'unit': ?instance.unit,
      'created_at': ?instance.createdAt,
      'updated_at': ?instance.updatedAt,
    };
