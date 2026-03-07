class SignupTermsRequestModel {
  final bool serviceTerms;
  final bool privacyPolicy;
  final bool locationTerms;
  final bool marketingConsent;

  const SignupTermsRequestModel({
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

class SignupProfileRequestModel {
  final String nickname;
  final String gender;
  final String birthDate;
  final List<int> hobbyIds;
  final String? introduction;

  const SignupProfileRequestModel({
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
