// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsignmentItemModel _$ConsignmentItemModelFromJson(
  Map<String, dynamic> json,
) => ConsignmentItemModel(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  soldQuantity: (json['sold_quantity'] as num?)?.toInt(),
  returnedQuantity: (json['returned_quantity'] as num?)?.toInt(),
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ConsignmentItemModelToJson(
  ConsignmentItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'sold_quantity': instance.soldQuantity,
  'returned_quantity': instance.returnedQuantity,
  'product': instance.product?.toJson(),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ConsignmentModel _$ConsignmentModelFromJson(Map<String, dynamic> json) =>
    ConsignmentModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['store_id'] as num).toInt(),
      code: json['code'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      store: json['store'] == null
          ? null
          : StoreModel.fromJson(json['store'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => ConsignmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ConsignmentModelToJson(ConsignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'code': instance.code,
      'status': instance.status,
      'notes': instance.notes,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'store': instance.store?.toJson(),
      'user': instance.user?.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
