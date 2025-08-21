// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsignmentModel _$ConsignmentModelFromJson(Map<String, dynamic> json) =>
    ConsignmentModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['store_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      soldQuantity: (json['sold_quantity'] as num?)?.toInt(),
      returnedQuantity: (json['returned_quantity'] as num?)?.toInt(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      store: json['store'] == null
          ? null
          : StoreModel.fromJson(json['store'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ConsignmentModelToJson(ConsignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'sold_quantity': instance.soldQuantity,
      'returned_quantity': instance.returnedQuantity,
      'status': instance.status,
      'notes': instance.notes,
      'store': instance.store?.toJson(),
      'product': instance.product?.toJson(),
      'user': instance.user?.toJson(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
