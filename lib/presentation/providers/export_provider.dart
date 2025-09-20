import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/export/export_usecase.dart';
import '../../../data/export/export_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/reports/reports_repository.dart';
import '../../../data/repositories/category_repository.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepository(
    transactionRepository: TransactionRepository(),
    reportsRepository: ReportsRepository(),
    categoryRepository: CategoryRepository(),
  );
});

final exportUseCaseProvider = Provider<ExportUseCase>((ref) {
  final exportRepository = ref.read(exportRepositoryProvider);
  return ExportUseCase(exportRepository: exportRepository);
});