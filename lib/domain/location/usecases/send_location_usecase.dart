import 'package:itto/domain/location/repositories/location_repository.dart';

class SendLocationUseCase {
  final LocationRepository repository;

  SendLocationUseCase({required this.repository});

  Future<void> execute({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String timestamp,
  }) =>
      repository.sendLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        timestamp: timestamp,
      );
}
