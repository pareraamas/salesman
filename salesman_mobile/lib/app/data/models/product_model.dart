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

  ProductModel copyWith({
    int? id,
    String? name,
    String? code,
    String? price,
    String? description,
    String? photoPath,
    String? photoUrl,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
