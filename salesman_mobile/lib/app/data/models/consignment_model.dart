import 'package:json_annotation/json_annotation.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';

part 'consignment_model.g.dart';

@JsonSerializable()
class ConsignmentItemModel {
  final int id;
  final int productId;
  final int quantity;
  final int? soldQuantity;
  final int? returnedQuantity;
  final ProductModel? product;
  final String? createdAt;
  final String? updatedAt;

  ConsignmentItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    this.soldQuantity,
    this.returnedQuantity,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsignmentItemModel.fromJson(Map<String, dynamic> json) => _$ConsignmentItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsignmentItemModelToJson(this);
}

@JsonSerializable()
class ConsignmentModel {
  final int id;
  final int storeId;
  final String code;
  final String status;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final StoreModel? store;
  final UserModel? user;
  final List<ConsignmentItemModel> items;
  final String? createdAt;
  final String? updatedAt;

  ConsignmentModel({
    required this.id,
    required this.storeId,
    required this.code,
    required this.status,
    this.notes,
    required this.startDate,
    this.endDate,
    this.store,
    this.user,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsignmentModel.fromJson(Map<String, dynamic> json) => _$ConsignmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsignmentModelToJson(this);

  ConsignmentModel copyWith({
    int? id,
    int? storeId,
    String? code,
    String? status,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    StoreModel? store,
    UserModel? user,
    List<ConsignmentItemModel>? items,
    String? createdAt,
    String? updatedAt,
  }) {
    return ConsignmentModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      code: code ?? this.code,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      store: store ?? this.store,
      user: user ?? this.user,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
