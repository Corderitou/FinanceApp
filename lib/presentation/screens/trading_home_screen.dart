import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingresos_costos_app/presentation/theme/trading_theme.dart';
import 'package:ingresos_costos_app/presentation/utils/number_formatter.dart';
import 'package:intl/intl.dart';
import 'transaction_form_screen.dart';
import 'account/account_list_screen.dart';
import 'reports/reports_dashboard_screen.dart';
import 'budget_list_screen.dart';
import 'work_location/work_locations_list_screen.dart';
import 'work_location/work_location_form_screen.dart';
import 'reminder/reminder_list_screen.dart';
import '../../domain/entities/category.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/reports/reports_repository.dart';
import '../../domain/reports/report_models.dart'; // Import report models
import '../../presentation/providers/account_provider.dart';

// Provider for reports repository
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

// Provider for category expenses
final categoryExpensesProvider = FutureProvider.family<List<CategoryExpense>, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  return repository.getCategoryExpenses(userId);
});

// Provider for category income
final categoryIncomeProvider = FutureProvider.family<List<CategoryIncome>, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  return repository.getCategoryIncome(userId);
});

class TradingHomeScreen extends ConsumerStatefulWidget {
  const TradingHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TradingHomeScreen> createState() => _TradingHomeScreenState();
}

class _TradingHomeScreenState extends ConsumerState<TradingHomeScreen> {
  int _selectedIndex = 0;

  // Mock categories for demonstration
  static final mockCategories = [
    Category(
      id: 1,
      userId: 1,
      name: 'Comida',
      type: 'expense',
      color: '#F44336',
      createdAt: DateTime.now(),
    ),
    Category(
      id: 2,
      userId: 1,
      name: 'Transporte',
      type: 'expense',
      color: '#FF5722',
      createdAt: DateTime.now(),
    ),
    Category(
      id: 3,
      userId: 1,
      name: 'Salario',
      type: 'income',
      color: '#4CAF50',
      createdAt: DateTime.now(),
    ),
  ];

  static List<Widget> _widgetOptions(List<Category> categories, BuildContext context) {
    return [
      const _TradingDashboard(),
      const AccountListScreen(userId: 1),
      ReportsDashboardScreen(userId: 1, categories: categories),
      const WorkLocationsListScreen(userId: 1),
      ReminderListScreen(userId: 1),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions(mockCategories, context).elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Cuentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Trabajo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Recordatorios',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _TradingDashboard extends ConsumerWidget {
  const _TradingDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load accounts when the widget is built
    ref.read(accountProvider.notifier).loadAccounts(1); // Assuming user ID 1 for now
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas Personales'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zona 1: Status Inmediato
              const _StatusImmediateSection(),
              const SizedBox(height: 24),
              
              // Zona 2: Acciones Rápidas
              const _QuickActionsSection(),
              const SizedBox(height: 24),
              
              // Zona 3: Descubrimiento y Oportunidades
              const _DiscoveryOpportunitiesSection(),
              const SizedBox(height: 24),
              
              // Zona 4: Exploración del Mercado
              const _MarketExplorationSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// Enumeración para los diferentes períodos de tiempo
enum TimePeriod {
  oneDay('1 día', 1),
  sevenDays('7 días', 7),
  oneMonth('1 mes', 30),
  sixMonths('6 meses', 180),
  oneYear('1 año', 365);

  const TimePeriod(this.label, this.days);
  final String label;
  final int days;
}

class _StatusImmediateSection extends ConsumerStatefulWidget {
  const _StatusImmediateSection();

  @override
  _StatusImmediateSectionState createState() => _StatusImmediateSectionState();
}

class _StatusImmediateSectionState extends ConsumerState<_StatusImmediateSection> {
  TimePeriod _selectedPeriod = TimePeriod.sevenDays;

  Future<Map<String, double>> _calculatePnL(int userId, double totalBalance, TimePeriod period) async {
    try {
      final transactionRepository = TransactionRepository();
      
      // Calculate date range based on selected period
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: period.days));
      
      // Get transactions for the selected period
      final transactions = await transactionRepository.getTransactionsByUserAndDateRange(
        userId, 
        startDate, 
        now
      );
      
      // Calculate total income and expenses
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      
      for (var transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else if (transaction.type == 'expense') {
          totalExpenses += transaction.amount;
        }
      }
      
      // Calculate PnL and percentage
      final double pnl = totalIncome - totalExpenses;
      // Fix the percentage calculation to be based on the total balance
      final double percentage = (totalBalance > 0) 
          ? (pnl / totalBalance) * 100 
          : 0.0;
      
      return {
        'pnl': pnl,
        'percentage': percentage,
      };
    } catch (e) {
      // Return default values in case of error
      return {
        'pnl': 0.0,
        'percentage': 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get accounts from provider
    final accountState = ref.watch(accountProvider);
    
    // Calculate total balance from all accounts
    final double totalBalance = accountState.accounts.fold(0.0, (sum, account) => sum + account.balance);
    
    // Calculate PnL for the selected period
    return FutureBuilder<Map<String, double>>(
      future: _calculatePnL(1, totalBalance, _selectedPeriod), // Assuming user ID 1 for now
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Total',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF909090),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Cargando...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF909090),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle error case with zero values instead of mock data
          final double weeklyPnL = 0.0;
          final double weeklyPnLPercentage = 0.0;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo Total',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF909090),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormatter.formatCurrency(totalBalance, currency: NumberFormatter.getCurrentCurrency()),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: weeklyPnL >= 0 
                            ? TradingTheme.profitGreen.withOpacity(0.2)
                            : TradingTheme.lossRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            weeklyPnL >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: weeklyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${weeklyPnL >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(weeklyPnL, currency: NumberFormatter.getCurrentCurrency())} (${weeklyPnLPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: weeklyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // Show a dialog or bottom sheet to select the time period
                        _showPeriodSelector(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            _selectedPeriod.label,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF909090),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF909090),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final double weeklyPnL = data['pnl']!;
        final double weeklyPnLPercentage = data['percentage']!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Total',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF909090),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormatter.formatCurrency(totalBalance, currency: NumberFormatter.getCurrentCurrency()),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: weeklyPnL >= 0 
                          ? TradingTheme.profitGreen.withOpacity(0.2)
                          : TradingTheme.lossRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          weeklyPnL >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: weeklyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${weeklyPnL >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(weeklyPnL, currency: NumberFormatter.getCurrentCurrency())} (${weeklyPnLPercentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: weeklyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // Show a dialog or bottom sheet to select the time period
                      _showPeriodSelector(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          _selectedPeriod.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF909090),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF909090),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPeriodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar período',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...TimePeriod.values.map((period) {
                return ListTile(
                  title: Text(period.label),
                  selected: _selectedPeriod == period,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionButton(
              icon: Icons.add,
              label: 'Ingreso',
              color: TradingTheme.profitGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(userId: 1),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.remove,
              label: 'Gasto',
              color: TradingTheme.lossRed,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionFormScreen(userId: 1),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.location_on,
              label: 'Trabajo',
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkLocationFormScreen(userId: 1),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.savings,
              label: 'Ahorros',
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.pushNamed(context, '/savings-goals-list');
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryOpportunitiesSection extends StatelessWidget {
  const _DiscoveryOpportunitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descubrimiento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2E35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tendencias de IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TradingTheme.accentYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NUEVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TradingTheme.accentYellow,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Basado en tu historial de gastos, podrías ahorrar \$150/mes en comida',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle discovery action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Explorar Ahorros'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketExplorationSection extends ConsumerWidget {
  const _MarketExplorationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Gastos'),
                    Tab(text: 'Ingresos'),
                    Tab(text: 'Balance'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _ExpenseCategoryList(),
                    _IncomeCategoryList(),
                    _BalanceCategoryList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get real data from the provider instead of using mock data
    final categoryExpensesAsync = ref.watch(categoryExpensesProvider(1)); // Assuming user ID 1 for now

    return categoryExpensesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay gastos registrados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                name: category.categoryName,
                amount: category.amount,
                change: 0.0, // We don't have change data in this simple implementation
                isPositive: false, // Expenses are negative
              );
            },
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Error al cargar datos: $error',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get real data from the provider instead of using mock data
    final categoryIncomeAsync = ref.watch(categoryIncomeProvider(1)); // Assuming user ID 1 for now

    return categoryIncomeAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay ingresos registrados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                name: category.categoryName,
                amount: category.amount,
                change: 0.0, // We don't have change data in this simple implementation
                isPositive: true, // Income is positive
              );
            },
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Error al cargar datos: $error',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get real data from both providers
    final categoryExpensesAsync = ref.watch(categoryExpensesProvider(1)); // Assuming user ID 1 for now
    final categoryIncomeAsync = ref.watch(categoryIncomeProvider(1)); // Assuming user ID 1 for now

    // We need to combine both async values to show a combined view
    return categoryExpensesAsync.when(
      data: (expenses) {
        return categoryIncomeAsync.when(
          data: (income) {
            // Combine both lists
            final List<Map<String, dynamic>> combinedCategories = [];
            
            // Add expenses (as negative values)
            for (var expense in expenses) {
              combinedCategories.add({
                'name': expense.categoryName,
                'amount': -(expense.amount), // Negative for expenses
              });
            }
            
            // Add income (as positive values)
            for (var inc in income) {
              combinedCategories.add({
                'name': inc.categoryName,
                'amount': inc.amount, // Positive for income
              });
            }
            
            // Sort by absolute amount (highest first)
            combinedCategories.sort((a, b) => 
              (b['amount'] as double).abs().compareTo((a['amount'] as double).abs()));
            
            if (combinedCategories.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No hay transacciones registradas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: combinedCategories.length,
                itemBuilder: (context, index) {
                  final category = combinedCategories[index];
                  return _CategoryItem(
                    name: category['name'],
                    amount: category['amount'],
                    change: 0.0, // We don't have change data in this simple implementation
                    isPositive: category['amount'] > 0, // Positive for income, negative for expenses
                  );
                },
              ),
            );
          },
          loading: () => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Error al cargar ingresos: $error',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Error al cargar gastos: $error',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final double amount;
  final double change;
  final bool isPositive;

  const _CategoryItem({
    required this.name,
    required this.amount,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2E35), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            NumberFormatter.formatCurrency(amount.abs(), currency: NumberFormatter.getCurrentCurrency()),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}