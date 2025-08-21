import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String name;
  final String code;
  final String price;
  final String? description;
  final String? photoPath;
  final String? photoUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    this.description,
    this.photoPath,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  String? get getFullPhotoUrl => photoUrl != null ? '${dotenv.env['BASE_URL']}$photoUrl' : null;
}
