// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsignmentModel _$ConsignmentModelFromJson(Map<String, dynamic> json) =>
    ConsignmentModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['storeId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      soldQuantity: (json['soldQuantity'] as num?)?.toInt(),
      returnedQuantity: (json['returnedQuantity'] as num?)?.toInt(),
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
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$ConsignmentModelToJson(ConsignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'productId': instance.productId,
      'quantity': instance.quantity,
      'soldQuantity': instance.soldQuantity,
      'returnedQuantity': instance.returnedQuantity,
      'status': instance.status,
      'notes': instance.notes,
      'store': instance.store,
      'product': instance.product,
      'user': instance.user,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
