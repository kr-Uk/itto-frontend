class SignupTermsRequest {
  final bool serviceTerms;
  final bool privacyPolicy;
  final bool locationTerms;
  final bool marketingConsent;

  const SignupTermsRequest({
    required this.serviceTerms,
    required this.privacyPolicy,
    required this.locationTerms,
    this.marketingConsent = false,
  });

  Map<String, dynamic> toJson() => {
    'serviceTerms': serviceTerms,
    'privacyPolicy': privacyPolicy,
    'locationTerms': locationTerms,
    'marketingConsent': marketingConsent,
  };
}

class SignupProfileRequest {
  final String nickname;
  final String gender;
  final String birthDate;
  final List<int> hobbyIds;
  final String? introduction;

  const SignupProfileRequest({
    required this.nickname,
    required this.gender,
    required this.birthDate,
    required this.hobbyIds,
    this.introduction,
  });

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'gender': gender,
    'birthDate': birthDate,
    'hobbyIds': hobbyIds,
    if (introduction != null) 'introduction': introduction,
  };
}

class PhotoUploadResponse {
  final List<PhotoItem> photos;

  const PhotoUploadResponse({required this.photos});

  factory PhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    return PhotoUploadResponse(
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => PhotoItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory PhotoUploadResponse.fromList(List<dynamic> list) {
    return PhotoUploadResponse(
      photos: list
          .map((e) => PhotoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PhotoItem {
  final int id;
  final String url;
  final bool isRepresentative;

  const PhotoItem({
    required this.id,
    required this.url,
    required this.isRepresentative,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) => PhotoItem(
    id: json['id'] as int,
    url: json['url'] as String,
    isRepresentative: json['isRepresentative'] as bool? ?? false,
  );
}
