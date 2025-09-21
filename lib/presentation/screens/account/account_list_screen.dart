import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/account.dart';
import '../../../presentation/providers/account_provider.dart';
import '../../../presentation/utils/number_formatter.dart';

class AccountListScreen extends ConsumerStatefulWidget {
  final int userId;

  const AccountListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends ConsumerState<AccountListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountProvider.notifier).loadAccounts(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);

    ref.listen(accountProvider, (previous, next) {
      if (next is AccountState && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAccountDialog(),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(accountProvider.notifier).loadAccounts(widget.userId);
          },
          child: accountState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : accountState.accounts.isEmpty
                  ? _buildEmptyState()
                  : _buildAccountList(accountState.accounts),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAccountDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes cuentas registradas',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Show create account dialog
            },
            child: const Text('Crear primera cuenta'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList(List<Account> accounts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _AccountCard(account: account, onTap: () => _showEditAccountDialog(account));
      },
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => _AccountFormDialog(
        userId: widget.userId,
        onSaved: () {
          ref.read(accountProvider.notifier).loadAccounts(widget.userId);
        },
      ),
    );
  }

  void _showEditAccountDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => _AccountFormDialog(
        userId: widget.userId,
        account: account,
        onSaved: () {
          ref.read(accountProvider.notifier).loadAccounts(widget.userId);
        },
      ),
    );
  }

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

class _AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const _AccountCard({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getAccountColor(account.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getAccountIcon(account.type),
            color: _getAccountColor(account.type),
            size: 24,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getAccountTypeLabel(account.type),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormatter.formatCurrency(account.balance, currency: NumberFormatter.getCurrentCurrency()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              account.currency,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

class _AccountFormDialog extends ConsumerStatefulWidget {
  final int userId;
  final Account? account;
  final VoidCallback onSaved;

  const _AccountFormDialog({
    Key? key,
    required this.userId,
    this.account,
    required this.onSaved,
  }) : super(key: key);

  @override
  ConsumerState<_AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<_AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _accountType = 'checking';
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _accountType = widget.account!.type;
      _currency = widget.account!.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.account?.id,
        userId: widget.userId,
        name: _nameController.text.trim(),
        type: _accountType,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        currency: _currency,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final accountState = ref.read(accountProvider);
      bool success;

      if (widget.account == null) {
        // Create new account
        success = await ref.read(accountProvider.notifier).createAccount(account);
      } else {
        // Update existing account
        success = await ref.read(accountProvider.notifier).updateAccount(account);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.account == null
                  ? 'Cuenta creada exitosamente'
                  : 'Cuenta actualizada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la cuenta'),
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
      title: Text(widget.account == null ? 'Nueva Cuenta' : 'Editar Cuenta'),
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
          onPressed: accountState.isSubmitting ? null : _saveAccount,
          child: accountState.isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.account == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}