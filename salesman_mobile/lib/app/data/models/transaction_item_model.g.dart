// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionItemModel _$TransactionItemModelFromJson(
  Map<String, dynamic> json,
) => TransactionItemModel(
  id: (json['id'] as num).toInt(),
  transactionId: (json['transactionId'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
  product: json['product'] == null
      ? null
      : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$TransactionItemModelToJson(
  TransactionItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'transactionId': instance.transactionId,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'price': instance.price,
  'subtotal': instance.subtotal,
  'product': instance.product,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
