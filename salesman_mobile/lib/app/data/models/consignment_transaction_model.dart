import 'package:json_annotation/json_annotation.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';

part 'consignment_transaction_model.g.dart';

@JsonSerializable()
class ConsignmentTransactionModel {
  final int id;
  final int consignmentId;
  final int? userId;
  final String transactionType; // sale, return, adjustment
  final int quantity;
  final String? notes;
  final String transactionDate;
  final UserModel? user;
  final List<ConsignmentTransactionItemModel> items;
  final String? createdAt;
  final String? updatedAt;

  ConsignmentTransactionModel({
    required this.id,
    required this.consignmentId,
    this.userId,
    required this.transactionType,
    required this.quantity,
    this.notes,
    required this.transactionDate,
    this.user,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsignmentTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$ConsignmentTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsignmentTransactionModelToJson(this);
}

@JsonSerializable()
class ConsignmentTransactionItemModel {
  final int id;
  final int consignmentTransactionId;
  final int productId;
  final int quantity;
  final String transactionType; // sale, return, adjustment
  final String? notes;
  final ProductModel? product;
  final String? createdAt;
  final String? updatedAt;

  ConsignmentTransactionItemModel({
    required this.id,
    required this.consignmentTransactionId,
    required this.productId,
    required this.quantity,
    required this.transactionType,
    this.notes,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsignmentTransactionItemModel.fromJson(Map<String, dynamic> json) =>
      _$ConsignmentTransactionItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsignmentTransactionItemModelToJson(this);
}
