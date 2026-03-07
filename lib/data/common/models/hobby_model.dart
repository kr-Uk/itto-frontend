import 'package:itto/domain/common/entities/hobby.dart';

class HobbyModel {
  final int id;
  final String name;
  final String? category;

  const HobbyModel({required this.id, required this.name, this.category});

  factory HobbyModel.fromJson(Map<String, dynamic> json) => HobbyModel(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (category != null) 'category': category,
      };

  Hobby toEntity() => Hobby(id: id, name: name, category: category);
}
