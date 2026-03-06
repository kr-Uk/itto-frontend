import '../../../core/network/api_client.dart';

class IdentityService {
  final ApiClient _client;

  IdentityService(this._client);

  Future<IdentityRequestResult> requestVerification() async {
    final json = await _client.post('/identity/request');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return IdentityRequestResult.fromJson(data);
  }

  Future<IdentityStatusResult> getVerificationStatus() async {
    final json = await _client.get('/identity/status');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return IdentityStatusResult.fromJson(data);
  }
}

class IdentityRequestResult {
  final String requestNo;
  final String authUrl;

  const IdentityRequestResult({
    required this.requestNo,
    required this.authUrl,
  });

  factory IdentityRequestResult.fromJson(Map<String, dynamic> json) {
    return IdentityRequestResult(
      requestNo: json['requestNo'] as String,
      authUrl: json['authUrl'] as String,
    );
  }
}

class IdentityStatusResult {
  final String status;
  final String? name;
  final String? gender;
  final String? birthDate;
  final String? phoneNumber;

  const IdentityStatusResult({
    required this.status,
    this.name,
    this.gender,
    this.birthDate,
    this.phoneNumber,
  });

  factory IdentityStatusResult.fromJson(Map<String, dynamic> json) {
    return IdentityStatusResult(
      status: json['status'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  bool get isSuccess => status == 'SUCCESS';
}
