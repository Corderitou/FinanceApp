import 'package:flutter/material.dart';
import '../navigation/persistent_bottom_navigation.dart';
import '../screens/search/global_search_screen.dart';
import '../widgets/voice_commands.dart';
import '../../domain/entities/transaction.dart';

class ImprovedNavigationUI extends StatefulWidget {
  const ImprovedNavigationUI({Key? key}) : super(key: key);

  @override
  _ImprovedNavigationUIState createState() => _ImprovedNavigationUIState();
}

class _ImprovedNavigationUIState extends State<ImprovedNavigationUI> {
  int _currentIndex = 0;
  bool _isSearchActive = false;

  // Sample pages - in a real app these would be actual screens
  final List<Widget> _pages = [
    const HomeScreenWithQuickActions(),
    const AccountsScreen(),
    const TransactionsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isSearchActive = false;
    });
  }

  void _onSearchActivated() {
    setState(() {
      _isSearchActive = true;
    });
  }

  void _onVoiceCommandReceived(VoiceCommandEvent event) {
    // Handle voice commands for navigation
    if (event is NavigateToEvent) {
      int index = 0;
      switch (event.target) {
        case NavigationTarget.home:
          index = 0;
          break;
        case NavigationTarget.accounts:
          index = 1;
          break;
        case NavigationTarget.transactions:
          index = 2;
          break;
        case NavigationTarget.analytics:
          index = 3;
          break;
        case NavigationTarget.settings:
          index = 4;
          break;
      }
      
      setState(() {
        _currentIndex = index;
        _isSearchActive = false;
      });
    } else if (event is AddTransactionEvent) {
      // Handle add transaction command
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adding ${event.type == TransactionType.income ? 'income' : 'expense'} transaction'
          ),
        ),
      );
    } else if (event is SearchEvent) {
      // Handle search command
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for: ${event.query}')),
      );
    } else if (event is UnknownCommandEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Command not recognized')),
      );
    } else if (event is ErrorCommandEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice command error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSearchActive
          ? const GlobalSearchScreen()
          : _pages[_currentIndex],
      bottomNavigationBar: PersistentBottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
      appBar: AppBar(
        title: const Text('FinanceApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearchActivated,
            tooltip: 'Search',
          ),
          VoiceCommandWidget(onCommandReceived: _onVoiceCommandReceived),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // Add transaction
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Transaction',
            )
          : null,
    );
  }
}

// Enhanced home screen with quick actions
class HomeScreenWithQuickActions extends StatelessWidget {
  const HomeScreenWithQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          const FinancialSummaryCards(),
          const SizedBox(height: 20),

          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildQuickActionCard(
                context,
                icon: Icons.add,
                title: 'Add Income',
                color: Colors.green,
                onTap: () {
                  // Add income
                },
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.remove,
                title: 'Add Expense',
                color: Colors.red,
                onTap: () {
                  // Add expense
                },
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.account_balance,
                title: 'Transfer',
                color: Colors.blue,
                onTap: () {
                  // Transfer between accounts
                },
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.bar_chart,
                title: 'Analytics',
                color: Colors.purple,
                onTap: () {
                  // Navigate to analytics
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder widgets
class FinancialSummaryCards extends StatelessWidget {
  const FinancialSummaryCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget('Financial Summary Cards');
  }
}

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget('Recent Transactions List');
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String text;

  const PlaceholderWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(text),
      ),
    );
  }
}