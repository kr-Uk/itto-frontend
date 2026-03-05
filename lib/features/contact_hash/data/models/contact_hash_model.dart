import '../../domain/entities/contact_hash.dart';

class ContactHashModel {
  final int id;
  final String phoneHash;
  final DateTime createdAt;

  const ContactHashModel({
    required this.id,
    required this.phoneHash,
    required this.createdAt,
  });

  factory ContactHashModel.fromJson(Map<String, dynamic> json) {
    return ContactHashModel(
      id: json['id'] as int,
      phoneHash: json['phoneHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneHash': phoneHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ContactHash toEntity() {
    return ContactHash(id: id, phoneHash: phoneHash, createdAt: createdAt);
  }
}
