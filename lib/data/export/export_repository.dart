import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../data/repositories/transaction_repository.dart';
import '../../domain/export/export_models.dart';
import '../../domain/reports/report_models.dart';
import '../../data/repositories/reports/reports_repository.dart';
import '../../data/repositories/category_repository.dart';

class ExportRepository {
  final TransactionRepository _transactionRepository;
  final ReportsRepository _reportsRepository;
  final CategoryRepository _categoryRepository;

  ExportRepository({
    required TransactionRepository transactionRepository,
    required ReportsRepository reportsRepository,
    required CategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _reportsRepository = reportsRepository,
        _categoryRepository = categoryRepository;

  /// Export transactions in a date range to CSV or PDF
  Future<ExportResult> exportTransactions(
    int userId,
    ExportOptions options,
  ) async {
    // Get transactions in the specified date range
    final transactions = await _getTransactionsInDateRange(userId, options);

    if (options.format == ExportFormat.csv) {
      return _exportTransactionsToCsv(transactions, options);
    } else if (options.format == ExportFormat.excel) {
      return _exportTransactionsToExcel(transactions, options);
    } else {
      return _exportTransactionsToPdf(transactions, options);
    }
  }

  /// Export financial summary report to CSV or PDF
  Future<ExportResult> exportFinancialSummary(
    int userId,
    ExportOptions options,
  ) async {
    final summary = await _reportsRepository.getFinancialSummary(userId);
    final categoryExpenses = await _reportsRepository.getCategoryExpenses(userId);
    final incomeVsExpense = await _reportsRepository.getIncomeVsExpense(
      userId,
      options.startDate,
      options.endDate,
    );

    if (options.format == ExportFormat.csv) {
      return _exportFinancialSummaryToCsv(
        summary,
        categoryExpenses,
        incomeVsExpense,
        options,
      );
    } else if (options.format == ExportFormat.excel) {
      return _exportFinancialSummaryToExcel(
        summary,
        categoryExpenses,
        incomeVsExpense,
        options,
      );
    } else {
      return _exportFinancialSummaryToPdf(
        summary,
        categoryExpenses,
        incomeVsExpense,
        options,
      );
    }
  }

  /// Get transactions within a date range
  Future<List<entity.Transaction>> _getTransactionsInDateRange(
    int userId,
    ExportOptions options,
  ) async {
    // Get all user transactions
    final allTransactions = await _transactionRepository.getTransactionsByUser(userId);
    
    // Filter by date range
    return allTransactions.where((transaction) {
      return transaction.date.isAfter(options.startDate.subtract(Duration(days: 1))) &&
          transaction.date.isBefore(options.endDate.add(Duration(days: 1)));
    }).toList();
  }

  /// Export transactions to CSV
  Future<ExportResult> _exportTransactionsToCsv(
    List<entity.Transaction> transactions,
    ExportOptions options,
  ) async {
    // Get categories for mapping
    final categories = await _categoryRepository.getCategoriesByUser(1); // Default user ID
    final categoryMap = {for (var category in categories) category.id: category};

    // Prepare CSV data
    List<List<dynamic>> csvData = [];

    // Add headers if requested
    if (options.includeHeaders) {
      csvData.add([
        'ID',
        'Fecha',
        'Tipo',
        'Categoría',
        'Monto',
        'Descripción',
      ]);
    }

    // Add transaction data
    for (var transaction in transactions) {
      csvData.add([
        transaction.id,
        transaction.date.toIso8601String().split('T')[0],
        transaction.type,
        categoryMap[transaction.categoryId]?.name ?? 'N/A',
        transaction.amount,
        transaction.description ?? '',
      ]);
    }

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);

    // Save to file
    final filePath = await _saveToFile(csvString, 'transactions', 'csv');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.csv,
      recordCount: transactions.length,
    );
  }

  /// Export transactions to PDF
  Future<ExportResult> _exportTransactionsToPdf(
    List<entity.Transaction> transactions,
    ExportOptions options,
  ) async {
    // Get categories for mapping
    final categories = await _categoryRepository.getCategoriesByUser(1); // Default user ID
    final categoryMap = {for (var category in categories) category.id: category};

    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte de Transacciones',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.Text('Período: ${options.startDate.toIso8601String().split('T')[0]} al ${options.endDate.toIso8601String().split('T')[0]}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: options.includeHeaders
                    ? ['ID', 'Fecha', 'Tipo', 'Categoría', 'Monto', 'Descripción']
                    : null,
                data: [
                  for (var transaction in transactions)
                    [
                      transaction.id?.toString() ?? '',
                      transaction.date.toIso8601String().split('T')[0],
                      transaction.type,
                      categoryMap[transaction.categoryId]?.name ?? 'N/A',
                      transaction.amount.toStringAsFixed(2),
                      transaction.description ?? '',
                    ]
                ],
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    // Save to file
    final pdfBytes = await pdf.save();
    final filePath = await _saveToFile(pdfBytes, 'transactions', 'pdf');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.pdf,
      recordCount: transactions.length,
    );
  }

  /// Export transactions to Excel
  Future<ExportResult> _exportTransactionsToExcel(
    List<entity.Transaction> transactions,
    ExportOptions options,
  ) async {
    // Get categories for mapping
    final categories = await _categoryRepository.getCategoriesByUser(1); // Default user ID
    final categoryMap = {for (var category in categories) category.id: category};

    // Create Excel document
    final excel = Excel.createExcel();
    final sheet = excel['Transacciones'];

    // Add headers if requested
    if (options.includeHeaders) {
      sheet.appendRow([
        'ID',
        'Fecha',
        'Tipo',
        'Categoría',
        'Monto',
        'Descripción',
      ]);
    }

    // Add transaction data
    for (var transaction in transactions) {
      sheet.appendRow([
        transaction.id?.toString() ?? '',
        transaction.date.toIso8601String().split('T')[0],
        transaction.type,
        categoryMap[transaction.categoryId]?.name ?? 'N/A',
        transaction.amount.toStringAsFixed(2),
        transaction.description ?? '',
      ]);
    }

    // Save to file
    final filePath = await _saveToFile(excel, 'transactions', 'xlsx');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.excel,
      recordCount: transactions.length,
    );
  }

  /// Export financial summary to CSV
  Future<ExportResult> _exportFinancialSummaryToCsv(
    FinancialSummary summary,
    List<CategoryExpense> categoryExpenses,
    IncomeVsExpense incomeVsExpense,
    ExportOptions options,
  ) async {
    List<List<dynamic>> csvData = [];

    // Add summary section
    csvData.add(['RESUMEN FINANCIERO']);
    csvData.add(['Ingresos totales', summary.totalIncome]);
    csvData.add(['Gastos totales', summary.totalExpense]);
    csvData.add(['Balance', summary.balance]);
    csvData.add(['Ingreso promedio', summary.averageIncome]);
    csvData.add(['Gasto promedio', summary.averageExpense]);
    csvData.add(['']);

    // Add income vs expense section
    csvData.add(['INGRESOS VS GASTOS']);
    csvData.add(['Período', '${incomeVsExpense.periodStart.toIso8601String().split('T')[0]} al ${incomeVsExpense.periodEnd.toIso8601String().split('T')[0]}']);
    csvData.add(['Ingresos', incomeVsExpense.income]);
    csvData.add(['Gastos', incomeVsExpense.expense]);
    csvData.add(['']);

    // Add category expenses section
    csvData.add(['GASTOS POR CATEGORÍA']);
    csvData.add(['Categoría', 'Monto']);
    for (var expense in categoryExpenses) {
      csvData.add([expense.categoryName, expense.amount]);
    }

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);

    // Save to file
    final filePath = await _saveToFile(csvString, 'financial_summary', 'csv');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.csv,
      recordCount: 1, // Single report
    );
  }

  /// Export financial summary to PDF
  Future<ExportResult> _exportFinancialSummaryToPdf(
    FinancialSummary summary,
    List<CategoryExpense> categoryExpenses,
    IncomeVsExpense incomeVsExpense,
    ExportOptions options,
  ) async {
    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte Financiero Resumido',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Financial Summary Section
              pw.Text(
                'Resumen Financiero',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                data: [
                  ['Concepto', 'Valor'],
                  ['Ingresos totales', summary.totalIncome.toStringAsFixed(2)],
                  ['Gastos totales', summary.totalExpense.toStringAsFixed(2)],
                  ['Balance', summary.balance.toStringAsFixed(2)],
                  ['Ingreso promedio', summary.averageIncome.toStringAsFixed(2)],
                  ['Gasto promedio', summary.averageExpense.toStringAsFixed(2)],
                ],
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              
              // Income vs Expense Section
              pw.Text(
                'Ingresos vs Gastos (Período: ${incomeVsExpense.periodStart.toIso8601String().split('T')[0]} al ${incomeVsExpense.periodEnd.toIso8601String().split('T')[0]})',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                data: [
                  ['Concepto', 'Valor'],
                  ['Ingresos', incomeVsExpense.income.toStringAsFixed(2)],
                  ['Gastos', incomeVsExpense.expense.toStringAsFixed(2)],
                ],
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              
              // Category Expenses Section
              pw.Text(
                'Gastos por Categoría',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                data: [
                  ['Categoría', 'Monto'],
                  for (var expense in categoryExpenses)
                    [expense.categoryName, expense.amount.toStringAsFixed(2)],
                ],
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    // Save to file
    final pdfBytes = await pdf.save();
    final filePath = await _saveToFile(pdfBytes, 'financial_summary', 'pdf');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.pdf,
      recordCount: 1, // Single report
    );
  }

  /// Export financial summary to Excel
  Future<ExportResult> _exportFinancialSummaryToExcel(
    FinancialSummary summary,
    List<CategoryExpense> categoryExpenses,
    IncomeVsExpense incomeVsExpense,
    ExportOptions options,
  ) async {
    // Create Excel document
    final excel = Excel.createExcel();
    
    // Add Financial Summary sheet
    final summarySheet = excel['Resumen Financiero'];
    summarySheet.appendRow(['Concepto', 'Valor']);
    summarySheet.appendRow(['Ingresos totales', summary.totalIncome.toStringAsFixed(2)]);
    summarySheet.appendRow(['Gastos totales', summary.totalExpense.toStringAsFixed(2)]);
    summarySheet.appendRow(['Balance', summary.balance.toStringAsFixed(2)]);
    summarySheet.appendRow(['Ingreso promedio', summary.averageIncome.toStringAsFixed(2)]);
    summarySheet.appendRow(['Gasto promedio', summary.averageExpense.toStringAsFixed(2)]);

    // Add Income vs Expense sheet
    final incomeVsExpenseSheet = excel['Ingresos vs Gastos'];
    incomeVsExpenseSheet.appendRow(['Concepto', 'Valor']);
    incomeVsExpenseSheet.appendRow(['Ingresos', incomeVsExpense.income.toStringAsFixed(2)]);
    incomeVsExpenseSheet.appendRow(['Gastos', incomeVsExpense.expense.toStringAsFixed(2)]);

    // Add Category Expenses sheet
    final categoryExpensesSheet = excel['Gastos por Categoría'];
    categoryExpensesSheet.appendRow(['Categoría', 'Monto']);
    for (var expense in categoryExpenses) {
      categoryExpensesSheet.appendRow([expense.categoryName, expense.amount.toStringAsFixed(2)]);
    }

    // Save to file
    final filePath = await _saveToFile(excel, 'financial_summary', 'xlsx');

    return ExportResult(
      filePath: filePath,
      format: ExportFormat.excel,
      recordCount: 1, // Single report
    );
  }

  /// Save content to file
  Future<String> _saveToFile(dynamic content, String baseName, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '$baseName-${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = '${directory.path}/$fileName';

    if (content is String) {
      // For CSV
      final file = File(filePath);
      await file.writeAsString(content);
    } else if (content is Uint8List) {
      // For PDF
      final file = File(filePath);
      await file.writeAsBytes(content);
    } else if (content is Excel) {
      // For Excel
      final file = File(filePath);
      final bytes = content.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      } else {
        // If encoding fails, create an empty file
        await file.writeAsString('');
      }
    }

    return filePath;
  }

  /// Open exported file
  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}