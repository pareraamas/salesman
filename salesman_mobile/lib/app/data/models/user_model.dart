import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'role')
  final String role;
  
  @JsonKey(name: 'email_verified_at', includeIfNull: false)
  final String? emailVerifiedAt;
  
  @JsonKey(name: 'created_at', includeIfNull: false)
  final String? createdAt;
  
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Copy with method for immutability
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
