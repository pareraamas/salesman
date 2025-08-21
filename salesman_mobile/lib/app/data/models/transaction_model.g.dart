// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['store_id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      invoiceNumber: json['invoice_number'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      transactionDate: json['transaction_date'] as String?,
      store: json['store'] == null
          ? null
          : StoreModel.fromJson(json['store'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'user_id': instance.userId,
      'invoice_number': instance.invoiceNumber,
      'total_amount': instance.totalAmount,
      'discount': instance.discount,
      'tax': instance.tax,
      'grand_total': instance.grandTotal,
      'status': instance.status,
      'notes': instance.notes,
      'transaction_date': instance.transactionDate,
      'store': instance.store?.toJson(),
      'user': instance.user?.toJson(),
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
