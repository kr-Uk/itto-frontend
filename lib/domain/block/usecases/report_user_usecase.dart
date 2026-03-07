import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';

class ReportUserUseCase {
  final BlockRepository repository;

  ReportUserUseCase({required this.repository});

  Future<void> execute(ReportRequest request) => repository.report(request);
}
