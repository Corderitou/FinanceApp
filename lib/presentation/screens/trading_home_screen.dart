import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingresos_costos_app/presentation/theme/trading_theme.dart';
import 'package:ingresos_costos_app/presentation/utils/number_formatter.dart';
import 'transaction_form_screen.dart';
import 'account/account_list_screen.dart';
import 'reports/reports_dashboard_screen.dart';
import 'budget_list_screen.dart';
import 'work_location/work_locations_list_screen.dart';
import 'work_location/work_location_form_screen.dart';
import '../../domain/entities/category.dart';

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

  static List<Widget> _widgetOptions(List<Category> categories) {
    return [
      const _TradingDashboard(),
      const AccountListScreen(userId: 1),
      ReportsDashboardScreen(userId: 1, categories: categories),
      const WorkLocationsListScreen(userId: 1),
      BudgetListScreen(userId: 1, categories: categories),
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
      body: _widgetOptions(mockCategories).elementAt(_selectedIndex),
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
            icon: Icon(Icons.account_balance_wallet),
            label: 'Presupuesto',
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

class _StatusImmediateSection extends ConsumerWidget {
  const _StatusImmediateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Obtener el saldo total de todas las cuentas y el PNL del día
    // Por ahora usamos valores mock
    final double totalBalance = 12450.75;
    final double dailyPnL = 245.50;
    final double dailyPnLPercentage = 2.1;

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
            NumberFormatter.formatCurrency(totalBalance),
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
                  color: dailyPnL >= 0 
                      ? TradingTheme.profitGreen.withOpacity(0.2)
                      : TradingTheme.lossRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      dailyPnL >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: dailyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${dailyPnL >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(dailyPnL)} (${dailyPnLPercentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dailyPnL >= 0 ? TradingTheme.profitGreen : TradingTheme.lossRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hoy',
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
              icon: Icons.bar_chart,
              label: 'Análisis',
              color: TradingTheme.accentYellow,
              onTap: () {
                // Handle analysis
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
    // TODO: Obtener datos reales de gastos por categoría
    // Por ahora usamos datos mock
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Comida',
        'amount': 450.00,
        'change': 12.5,
        'isPositive': false,
      },
      {
        'name': 'Transporte',
        'amount': 230.50,
        'change': -5.2,
        'isPositive': true,
      },
      {
        'name': 'Entretenimiento',
        'amount': 180.75,
        'change': 8.3,
        'isPositive': false,
      },
      {
        'name': 'Salud',
        'amount': 95.25,
        'change': 0.0,
        'isPositive': true,
      },
    ];

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
            name: category['name'],
            amount: category['amount'],
            change: category['change'],
            isPositive: category['isPositive'],
          );
        },
      ),
    );
  }
}

class _IncomeCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Obtener datos reales de ingresos por categoría
    // Por ahora usamos datos mock
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Salario',
        'amount': 2500.00,
        'change': 0.0,
        'isPositive': true,
      },
      {
        'name': 'Freelance',
        'amount': 850.50,
        'change': 15.2,
        'isPositive': true,
      },
      {
        'name': 'Inversiones',
        'amount': 320.75,
        'change': -3.5,
        'isPositive': false,
      },
    ];

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
            name: category['name'],
            amount: category['amount'],
            change: category['change'],
            isPositive: category['isPositive'],
          );
        },
      ),
    );
  }
}

class _BalanceCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Obtener datos reales de balance por categoría
    // Por ahora usamos datos mock
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Comida',
        'amount': -450.00,
        'change': 12.5,
        'isPositive': false,
      },
      {
        'name': 'Transporte',
        'amount': -230.50,
        'change': -5.2,
        'isPositive': true,
      },
      {
        'name': 'Salario',
        'amount': 2500.00,
        'change': 0.0,
        'isPositive': true,
      },
      {
        'name': 'Freelance',
        'amount': 850.50,
        'change': 15.2,
        'isPositive': true,
      },
    ];

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
            name: category['name'],
            amount: category['amount'],
            change: category['change'],
            isPositive: category['amount'] > 0,
          );
        },
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
            NumberFormatter.formatCurrency(amount.abs()),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: change > 0
                  ? (isPositive ? TradingTheme.profitGreen : TradingTheme.lossRed).withOpacity(0.2)
                  : (isPositive ? TradingTheme.lossRed : TradingTheme.profitGreen).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: change > 0
                      ? (isPositive ? TradingTheme.profitGreen : TradingTheme.lossRed)
                      : (isPositive ? TradingTheme.lossRed : TradingTheme.profitGreen),
                ),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: change > 0
                        ? (isPositive ? TradingTheme.profitGreen : TradingTheme.lossRed)
                        : (isPositive ? TradingTheme.lossRed : TradingTheme.profitGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}