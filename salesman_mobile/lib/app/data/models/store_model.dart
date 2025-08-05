import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
class StoreModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => 
      _$StoreModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$StoreModelToJson(this);
}
