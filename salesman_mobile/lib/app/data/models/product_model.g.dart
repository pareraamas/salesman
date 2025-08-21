// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  price: json['price'] as String,
  description: json['description'] as String?,
  photoPath: json['photo_path'] as String?,
  photoUrl: json['photo_url'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  deletedAt: json['deleted_at'] as String?,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'price': instance.price,
      'description': instance.description,
      'photo_path': instance.photoPath,
      'photo_url': instance.photoUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
