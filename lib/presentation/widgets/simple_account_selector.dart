import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';

class SimpleAccountSelector extends ConsumerWidget {
  final int userId;
  final int? selectedAccountId;
  final Function(int?) onAccountSelected;
  final bool showCreateOption;

  const SimpleAccountSelector({
    Key? key,
    required this.userId,
    this.selectedAccountId,
    required this.onAccountSelected,
    this.showCreateOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);

    ref.listen(accountProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Load accounts when widget is built
    useEffect(() {
      ref.read(accountProvider.notifier).loadAccounts(userId);
      return null;
    }, []);

    if (accountState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (accountState.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Error: ${accountState.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (accountState.accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'No tienes cuentas registradas',
              style: TextStyle(color: Colors.grey),
            ),
            if (showCreateOption) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _showCreateAccountDialog(context, ref);
                },
                child: const Text('Crear Cuenta'),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona una cuenta:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...accountState.accounts.map((account) {
                final isSelected = selectedAccountId == account.id;
                return ChoiceChip(
                  label: Text('${account.name} (\$${account.balance.toStringAsFixed(2)})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    onAccountSelected(selected ? account.id : null);
                  },
                  backgroundColor: isSelected ? null : Colors.grey[200],
                );
              }).toList(),
              if (showCreateOption)
                ActionChip(
                  label: const Text('+ Crear'),
                  avatar: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    _showCreateAccountDialog(context, ref);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateAccountDialog(
        userId: userId,
        onAccountCreated: (account) {
          ref.read(accountProvider.notifier).loadAccounts(userId);
          onAccountSelected(account.id);
        },
      ),
    );
  }
}

class _CreateAccountDialog extends ConsumerStatefulWidget {
  final int userId;
  final Function(Account) onAccountCreated;

  const _CreateAccountDialog({
    Key? key,
    required this.userId,
    required this.onAccountCreated,
  }) : super(key: key);

  @override
  ConsumerState<_CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<_CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _accountType = 'checking';
  String _currency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        userId: widget.userId,
        name: _nameController.text.trim(),
        type: _accountType,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        currency: _currency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(accountProvider.notifier).createAccount(account);
      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onAccountCreated(account);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la cuenta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);

    return AlertDialog(
      title: const Text('Crear Nueva Cuenta'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo inicial',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 12),
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
                  if (value != null) {
                    setState(() {
                      _accountType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currency,
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
                  if (value != null) {
                    setState(() {
                      _currency = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: accountState.isSubmitting ? null : _createAccount,
          child: accountState.isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}