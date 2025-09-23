import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/export/export_models.dart';
import '../../../domain/usecases/export/export_usecase.dart';
import '../../providers/export_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int userId;

  const ExportScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _includeHeaders = true;
  bool _exportTransactions = true; // true for transactions, false for reports

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Datos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona las opciones para exportar tus datos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Export type selector
              const Text(
                'Tipo de exportación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: const Text('Transacciones'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: _exportTransactions,
                  onChanged: (value) {
                    setState(() {
                      _exportTransactions = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _exportTransactions = true;
                  });
                },
              ),
              ListTile(
                title: const Text('Reportes resumidos'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: _exportTransactions,
                  onChanged: (value) {
                    setState(() {
                      _exportTransactions = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _exportTransactions = false;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Date range pickers
              const Text(
                'Rango de fechas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickStartDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha inicial',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate == null
                              ? 'Seleccionar'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickEndDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha final',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate == null
                              ? 'Seleccionar'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Format selector
              const Text(
                'Formato de exportación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('CSV (Valores separados por comas)'),
                leading: Radio<ExportFormat>(
                  value: ExportFormat.csv,
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedFormat = ExportFormat.csv;
                  });
                },
              ),
              ListTile(
                title: const Text('Excel (Documento de Excel)'),
                leading: Radio<ExportFormat>(
                  value: ExportFormat.excel,
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedFormat = ExportFormat.excel;
                  });
                },
              ),
              ListTile(
                title: const Text('PDF (Documento PDF)'),
                leading: Radio<ExportFormat>(
                  value: ExportFormat.pdf,
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedFormat = ExportFormat.pdf;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Options
              const Text(
                'Opciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Incluir encabezados'),
                value: _includeHeaders,
                onChanged: (value) {
                  setState(() {
                    _includeHeaders = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              
              // Export button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndExport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Exportar Datos',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _validateAndExport() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        _showError('Por favor selecciona ambas fechas');
        return;
      }

      if (_startDate!.isAfter(_endDate!)) {
        _showError('La fecha inicial no puede ser posterior a la fecha final');
        return;
      }

      _performExport();
    }
  }

  Future<void> _performExport() async {
    try {
      final exportUseCase = ref.read(exportUseCaseProvider);
      
      final options = ExportOptions(
        startDate: _startDate!,
        endDate: _endDate!,
        format: _selectedFormat,
        includeHeaders: _includeHeaders,
      );

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Exportando datos...'),
              ],
            ),
          );
        },
      );

      ExportResult result;
      if (_exportTransactions) {
        result = await exportUseCase.exportTransactions(widget.userId, options);
      } else {
        result = await exportUseCase.exportFinancialSummary(widget.userId, options);
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success dialog with options to open or share
      _showExportSuccessDialog(result);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      _showError('Error al exportar datos: $e');
    }
  }

  void _showExportSuccessDialog(ExportResult result) {
    final exportUseCase = ref.read(exportUseCaseProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Exportación exitosa!'),
          content: Text(
              'Tus datos han sido exportados correctamente.\n\n'
              'Formato: ${result.format.name.toUpperCase()}\n'
              'Registros: ${result.recordCount}\n'
              'Ubicación: ${result.filePath}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await exportUseCase.openFile(result.filePath);
              },
              child: const Text('Abrir archivo'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}