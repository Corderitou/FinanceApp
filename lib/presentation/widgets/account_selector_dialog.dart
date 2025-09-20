import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import 'account_provider.dart';

class AccountSelectorDialog extends ConsumerStatefulWidget {
  final int userId;
  final int? selectedAccountId;
  final Function(int?) onAccountSelected;

  const AccountSelectorDialog({
    Key? key,
    required this.userId,
    this.selectedAccountId,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  ConsumerState<AccountSelectorDialog> createState() => _AccountSelectorDialogState();
}

class _AccountSelectorDialogState extends ConsumerState<AccountSelectorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String? _selectedCurrency = 'USD';
  String? _accountType = 'checking';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountProvider.notifier).loadAccounts(widget.userId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _createNewAccount() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final balance = double.tryParse(_balanceController.text) ?? 0.0;
      
      final account = Account(
        userId: widget.userId,
        name: name,
        type: _accountType!,
        balance: balance,
        currency: _selectedCurrency!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(accountProvider.notifier).createAccount(account);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear la cuenta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _selectAccount(int accountId) {
    widget.onAccountSelected(accountId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);

    return AlertDialog(
      title: const Text('Seleccionar Cuenta'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (accountState.error != null)
              Center(
                child: Text(
                  accountState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else ...[
              // Lista de cuentas existentes
              if (accountState.accounts.isNotEmpty) ...[
                const Text(
                  'Selecciona una cuenta:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: accountState.accounts.length,
                    itemBuilder: (context, index) {
                      final account = accountState.accounts[index];
                      return RadioListTile<int>(
                        title: Text('${account.name} (\$${account.balance.toStringAsFixed(2)})'),
                        value: account.id!,
                        groupValue: widget.selectedAccountId,
                        onChanged: (value) => _selectAccount(value!),
                      );
                    },
                  ),
                ),
                const Divider(),
              ],
              
              // Opción para crear nueva cuenta
              const Text(
                'O crea una nueva cuenta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la cuenta',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre para la cuenta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Saldo inicial',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un saldo inicial';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _accountType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cuenta',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'checking', child: Text('Cuenta Corriente')),
                        DropdownMenuItem(value: 'savings', child: Text('Caja de Ahorro')),
                        DropdownMenuItem(value: 'credit', child: Text('Tarjeta de Crédito')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _accountType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Moneda',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('Dólar (USD)')),
                        DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
                        DropdownMenuItem(value: 'MXN', child: Text('Peso Mexicano (MXN)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (accountState.accounts.isEmpty ||
            _nameController.text.isNotEmpty &&
                _balanceController.text.isNotEmpty &&
                double.tryParse(_balanceController.text) != null)
          ElevatedButton(
            onPressed: accountState.isSubmitting
                ? null
                : _createNewAccount,
            child: accountState.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear Cuenta'),
          ),
      ],
    );
  }
}