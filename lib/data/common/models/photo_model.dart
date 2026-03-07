import 'package:itto/domain/common/entities/photo.dart';

class PhotoModel {
  final int id;
  final String url;
  final bool isRepresentative;

  const PhotoModel({
    required this.id,
    required this.url,
    required this.isRepresentative,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        id: json['id'] as int,
        url: json['url'] as String,
        isRepresentative: json['isRepresentative'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'isRepresentative': isRepresentative,
      };

  Photo toEntity() =>
      Photo(id: id, url: url, isRepresentative: isRepresentative);
}
