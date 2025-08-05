import 'package:json_annotation/json_annotation.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';

part 'consignment_model.g.dart';

@JsonSerializable()
class ConsignmentModel {
  final int id;
  final int storeId;
  final int productId;
  final int quantity;
  final int? soldQuantity;
  final int? returnedQuantity;
  final String status;
  final String? notes;
  final StoreModel? store;
  final ProductModel? product;
  final UserModel? user;
  final String? createdAt;
  final String? updatedAt;

  ConsignmentModel({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.quantity,
    this.soldQuantity,
    this.returnedQuantity,
    required this.status,
    this.notes,
    this.store,
    this.product,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsignmentModel.fromJson(Map<String, dynamic> json) => 
      _$ConsignmentModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ConsignmentModelToJson(this);
}
