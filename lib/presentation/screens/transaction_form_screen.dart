import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_form_provider.dart';
import '../widgets/category_selector.dart'; // Import our new category selector
import '../utils/number_formatter.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int userId;

  const TransactionFormScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionFormProvider.notifier).loadData(widget.userId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildForm(formState),
        ),
      ),
    );
  }

  Widget _buildForm(TransactionFormState formState) {
    if (formState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Type selector
          _buildTypeSelector(formState),
          const SizedBox(height: 20),
          
          // Amount input
          _buildAmountInput(formState),
          const SizedBox(height: 20),
          
          // Account selector
          _buildAccountSelector(formState),
          const SizedBox(height: 20),
          
          // Category selector
          _buildCategorySelector(formState),
          const SizedBox(height: 20),
          
          // Date picker
          _buildDatePicker(formState),
          const SizedBox(height: 20),
          
          // Description input
          _buildDescriptionInput(formState),
          const SizedBox(height: 30),
          
          // Save button
          _buildSaveButton(formState),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSaveButton(TransactionFormState formState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: formState.isSubmitting
            ? null
            : () async {
                print('=== INICIANDO GUARDADO DE TRANSACCIÓN ===');
                print('Estado actual del formulario:');
                print('- Monto: ${formState.amount}');
                print('- Cuenta seleccionada: ${formState.selectedAccountId}');
                print('- Categoría seleccionada: ${formState.selectedCategoryId}');
                print('- Tipo: ${formState.type}');
                print('- Descripción: ${formState.description}');
                print('- Fecha: ${formState.selectedDate}');
                
                // Validaciones básicas antes de enviar
                if (formState.amount.isEmpty) {
                  print('ERROR: Monto vacío');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor ingrese un monto'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
                
                if (formState.selectedAccountId == null) {
                  print('ERROR: No se seleccionó cuenta');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor seleccione una cuenta'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
                
                if (formState.selectedCategoryId == null) {
                  print('ERROR: No se seleccionó categoría');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor seleccione una categoría'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
                
                print('Llamando al notifier.submitForm...');
                final notifier = ref.read(transactionFormProvider.notifier);
                final success = await notifier.submitForm(widget.userId);
                print('Resultado de submitForm: $success');
                
                if (success) {
                  print('TRANSACCIÓN GUARDADA EXITOSAMENTE');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transacción guardada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true); // Return true to indicate success
                  }
                } else {
                  print('ERROR AL GUARDAR LA TRANSACCIÓN');
                  // Show error message if submission failed
                  if (mounted) {
                    final errorMessage = formState.submitError ?? 'Error al guardar la transacción';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: formState.isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'GUARDANDO...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Text(
                'CONFIRMAR Y GUARDAR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildTypeSelector(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de transacción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                title: 'Ingreso',
                isSelected: formState.type == 'income',
                color: Colors.green,
                onTap: formState.isSubmitting
                    ? null
                    : () => formNotifier.setType('income'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeButton(
                title: 'Gasto',
                isSelected: formState.type == 'expense',
                color: Colors.red,
                onTap: formState.isSubmitting
                    ? null
                    : () => formNotifier.setType('expense'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInput(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: r'$',
            prefixStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            errorText: formState.amountError,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(16),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => formNotifier.setAmount(value),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuenta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: formState.selectedAccountId,
          hint: const Text('Seleccione una cuenta'),
          items: formState.accounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Row(
                children: [
                  Icon(
                    _getAccountIcon(account.type),
                    color: _getAccountColor(account.type),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_getAccountTypeLabel(account.type)} • ${NumberFormatter.formatCurrency(account.balance)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            formNotifier.setSelectedAccount(value);
          },
          decoration: InputDecoration(
            errorText: formState.accountError,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Use our custom category selector instead of dropdown
        CategorySelector(
          userId: widget.userId,
          transactionType: formState.type,
          selectedCategoryId: formState.selectedCategoryId,
          onCategorySelected: (categoryId) {
            formNotifier.setSelectedCategory(categoryId);
          },
        ),
        if (formState.categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              formState.categoryError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Seleccione una fecha',
            errorText: formState.dateError,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          controller: TextEditingController(
            text: _formatDate(formState.selectedDate),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: formState.selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              formNotifier.setSelectedDate(pickedDate);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(TransactionFormState formState) {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Descripción de la transacción',
            errorText: formState.descriptionError,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          onChanged: formNotifier.setDescription,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper methods for account icons and colors
  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getAccountColor(String type) {
    switch (type) {
      case 'checking':
        return Colors.blue;
      case 'savings':
        return Colors.green;
      case 'credit':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'checking':
        return 'Cuenta Corriente';
      case 'savings':
        return 'Caja de Ahorro';
      case 'credit':
        return 'Tarjeta de Crédito';
      default:
        return type;
    }
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _TypeButton({
    required this.title,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}