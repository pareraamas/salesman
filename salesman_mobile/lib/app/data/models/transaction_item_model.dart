import 'package:json_annotation/json_annotation.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';

part 'transaction_item_model.g.dart';

@JsonSerializable()
class TransactionItemModel {
  final int id;
  final int transactionId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final ProductModel? product;
  final String? createdAt;
  final String? updatedAt;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) => 
      _$TransactionItemModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionItemModelToJson(this);
}
