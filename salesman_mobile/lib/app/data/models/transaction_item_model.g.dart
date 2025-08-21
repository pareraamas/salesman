// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionItemModel _$TransactionItemModelFromJson(
  Map<String, dynamic> json,
) => TransactionItemModel(
  id: (json['id'] as num).toInt(),
  transactionId: (json['transaction_id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TransactionItemModelToJson(
  TransactionItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'transaction_id': instance.transactionId,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'subtotal': instance.subtotal,
  'product': instance.product?.toJson(),
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
