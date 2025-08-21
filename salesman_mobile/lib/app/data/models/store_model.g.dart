// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => StoreModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  ownerName: json['owner_name'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  photoPath: json['photo_path'] as String?,
  photoUrl: json['photo_url'] as String?,
  description: json['description'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
);

Map<String, dynamic> _$StoreModelToJson(StoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'owner_name': instance.ownerName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photo_path': instance.photoPath,
      'photo_url': instance.photoUrl,
      'description': instance.description,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
