// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsignmentTransactionModel _$ConsignmentTransactionModelFromJson(
  Map<String, dynamic> json,
) => ConsignmentTransactionModel(
  id: (json['id'] as num).toInt(),
  consignmentId: (json['consignment_id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  transactionType: json['transaction_type'] as String,
  quantity: (json['quantity'] as num).toInt(),
  notes: json['notes'] as String?,
  transactionDate: json['transaction_date'] as String,
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>)
      .map(
        (e) =>
            ConsignmentTransactionItemModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ConsignmentTransactionModelToJson(
  ConsignmentTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'consignment_id': instance.consignmentId,
  'user_id': instance.userId,
  'transaction_type': instance.transactionType,
  'quantity': instance.quantity,
  'notes': instance.notes,
  'transaction_date': instance.transactionDate,
  'user': instance.user?.toJson(),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ConsignmentTransactionItemModel _$ConsignmentTransactionItemModelFromJson(
  Map<String, dynamic> json,
) => ConsignmentTransactionItemModel(
  id: (json['id'] as num).toInt(),
  consignmentTransactionId: (json['consignment_transaction_id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  transactionType: json['transaction_type'] as String,
  notes: json['notes'] as String?,
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ConsignmentTransactionItemModelToJson(
  ConsignmentTransactionItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'consignment_transaction_id': instance.consignmentTransactionId,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'transaction_type': instance.transactionType,
  'notes': instance.notes,
  'product': instance.product?.toJson(),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
