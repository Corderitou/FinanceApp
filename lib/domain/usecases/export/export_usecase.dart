import '../../../domain/export/export_models.dart';
import '../../../data/export/export_repository.dart';

class ExportUseCase {
  final ExportRepository _exportRepository;

  ExportUseCase({required ExportRepository exportRepository})
      : _exportRepository = exportRepository;

  /// Export transactions in a date range
  Future<ExportResult> exportTransactions(
    int userId,
    ExportOptions options,
  ) {
    return _exportRepository.exportTransactions(userId, options);
  }

  /// Export financial summary report
  Future<ExportResult> exportFinancialSummary(
    int userId,
    ExportOptions options,
  ) {
    return _exportRepository.exportFinancialSummary(userId, options);
  }

  /// Open exported file
  Future<void> openFile(String filePath) {
    return _exportRepository.openFile(filePath);
  }
}