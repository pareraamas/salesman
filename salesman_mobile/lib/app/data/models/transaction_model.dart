import 'package:json_annotation/json_annotation.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/models/transaction_item_model.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final int id;
  final int storeId;
  final int? userId;
  final String invoiceNumber;
  final double totalAmount;
  final double? discount;
  final double? tax;
  final double grandTotal;
  final String status;
  final String? notes;
  final String? transactionDate;
  final StoreModel? store;
  final UserModel? user;
  final List<TransactionItemModel>? items;
  final String? createdAt;
  final String? updatedAt;

  TransactionModel({
    required this.id,
    required this.storeId,
    this.userId,
    required this.invoiceNumber,
    required this.totalAmount,
    this.discount,
    this.tax,
    required this.grandTotal,
    required this.status,
    this.notes,
    this.transactionDate,
    this.store,
    this.user,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => 
      _$TransactionModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
