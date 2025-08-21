import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
class StoreModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? ownerName;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  final String? photoUrl;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.ownerName,
    this.latitude,
    this.longitude,
    this.photoPath,
    this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => _$StoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);

  String? get getFullPhotoUrl => photoUrl != null ? '${dotenv.env['BASE_URL']}$photoUrl' : null;
}
