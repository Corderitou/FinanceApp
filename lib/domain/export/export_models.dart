enum ExportFormat { csv, pdf, excel }

class ExportOptions {
  final DateTime startDate;
  final DateTime endDate;
  final ExportFormat format;
  final bool includeHeaders;

  ExportOptions({
    required this.startDate,
    required this.endDate,
    required this.format,
    this.includeHeaders = true,
  });
}

class ExportResult {
  final String filePath;
  final ExportFormat format;
  final int recordCount;

  ExportResult({
    required this.filePath,
    required this.format,
    required this.recordCount,
  });
}