import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String name;
  final String sku;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => 
      _$ProductModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
