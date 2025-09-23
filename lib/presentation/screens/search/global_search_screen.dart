import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/reminder.dart';

class GlobalSearchService {
  /// Search across all data types
  Future<SearchResults> searchAll(String query, int userId) async {
    // In a real implementation, this would query the database for all relevant entities
    // For now, we'll simulate search results
    
    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock search results
    final transactions = <Transaction>[];
    final accounts = <Account>[];
    final categories = <Category>[];
    final bills = <Bill>[];
    final reminders = <Reminder>[];
    
    // Simulate finding some results based on the query
    if (query.toLowerCase().contains('grocery')) {
      transactions.add(
        Transaction(
          userId: userId,
          accountId: 1,
          categoryId: 2,
          amount: 45.67,
          type: 'expense',
          description: 'Grocery shopping',
          date: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    
    if (query.toLowerCase().contains('salary')) {
      transactions.add(
        Transaction(
          userId: userId,
          accountId: 1,
          categoryId: 1,
          amount: 2500.00,
          type: 'income',
          description: 'Monthly salary',
          date: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      accounts.add(
        Account(
          userId: userId,
          name: 'Salary Account',
          description: 'Main salary account',
          balance: 2500.00,
          currency: 'USD',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    
    return SearchResults(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
      bills: bills,
      reminders: reminders,
    );
  }
}

class SearchResults {
  final List<Transaction> transactions;
  final List<Account> accounts;
  final List<Category> categories;
  final List<Bill> bills;
  final List<Reminder> reminders;

  SearchResults({
    required this.transactions,
    required this.accounts,
    required this.categories,
    required this.bills,
    required this.reminders,
  });

  bool get isEmpty =>
      transactions.isEmpty &&
      accounts.isEmpty &&
      categories.isEmpty &&
      bills.isEmpty &&
      reminders.isEmpty;

  int get totalCount =>
      transactions.length +
      accounts.length +
      categories.length +
      bills.length +
      reminders.length;
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  _GlobalSearchScreenState createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalSearchService _searchService = GlobalSearchService();
  SearchResults? _searchResults;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchService.searchAll(query, 1); // TODO: Use actual user ID
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search transactions, accounts, bills...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = null;
              });
            },
          ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults == null
              ? const Center(
                  child: Text(
                    'Enter a search term to find transactions, accounts, and more',
                    textAlign: TextAlign.center,
                  ),
                )
              : _searchResults!.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: [
        if (_searchResults!.transactions.isNotEmpty) ...[
          const ListTile(
            title: Text(
              'TRANSACTIONS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ..._searchResults!.transactions.map((transaction) {
            return ListTile(
              title: Text(transaction.description ?? 'Unnamed Transaction'),
              subtitle: Text(
                '${transaction.date.toString().split(' ').first} • '
                '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              ),
              trailing: Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigate to transaction detail
              },
            );
          }).toList(),
          const Divider(),
        ],
        if (_searchResults!.accounts.isNotEmpty) ...[
          const ListTile(
            title: Text(
              'ACCOUNTS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ..._searchResults!.accounts.map((account) {
            return ListTile(
              title: Text(account.name),
              subtitle: Text(account.description ?? ''),
              trailing: Text(
                '\$${account.balance.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Navigate to account detail
              },
            );
          }).toList(),
          const Divider(),
        ],
        if (_searchResults!.bills.isNotEmpty) ...[
          const ListTile(
            title: Text(
              'BILLS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ..._searchResults!.bills.map((bill) {
            return ListTile(
              title: Text(bill.name),
              subtitle: Text(bill.description ?? ''),
              trailing: Text(
                bill.amount != null ? '\$${bill.amount!.toStringAsFixed(2)}' : 'Variable',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Navigate to bill detail
              },
            );
          }).toList(),
          const Divider(),
        ],
        if (_searchResults!.reminders.isNotEmpty) ...[
          const ListTile(
            title: Text(
              'REMINDERS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ..._searchResults!.reminders.map((reminder) {
            return ListTile(
              title: Text(reminder.name),
              subtitle: Text(reminder.description ?? ''),
              onTap: () {
                // Navigate to reminder detail
              },
            );
          }).toList(),
        ],
      ],
    );
  }
}