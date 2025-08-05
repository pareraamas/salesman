// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['storeId'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      invoiceNumber: json['invoiceNumber'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      transactionDate: json['transactionDate'] as String?,
      store: json['store'] == null
          ? null
          : StoreModel.fromJson(json['store'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'userId': instance.userId,
      'invoiceNumber': instance.invoiceNumber,
      'totalAmount': instance.totalAmount,
      'discount': instance.discount,
      'tax': instance.tax,
      'grandTotal': instance.grandTotal,
      'status': instance.status,
      'notes': instance.notes,
      'transactionDate': instance.transactionDate,
      'store': instance.store,
      'user': instance.user,
      'items': instance.items,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
