import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../widgets/receipt_capture.dart';
import '../widgets/quick_add_fab.dart';
import '../../domain/services/location_based_categorization_service.dart';

class EnhancedTransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final List<Account> accounts;
  final List<Category> categories;

  const EnhancedTransactionForm({
    Key? key,
    this.transaction,
    required this.accounts,
    required this.categories,
  }) : super(key: key);

  @override
  _EnhancedTransactionFormState createState() => _EnhancedTransactionFormState();
}

class _EnhancedTransactionFormState extends State<EnhancedTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late int _selectedAccountId;
  late int _selectedCategoryId;
  late String _type;
  late DateTime _date;
  final LocationBasedCategorizationService _locationService = LocationBasedCategorizationService();
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController = TextEditingController(text: widget.transaction!.amount.toString());
      _descriptionController = TextEditingController(text: widget.transaction!.description);
      _selectedAccountId = widget.transaction!.accountId;
      _selectedCategoryId = widget.transaction!.categoryId;
      _type = widget.transaction!.type;
      _date = widget.transaction!.date;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedAccountId = widget.accounts.isNotEmpty ? widget.accounts.first.id : 0;
      _selectedCategoryId = widget.categories.isNotEmpty ? widget.categories.first.id : 0;
      _type = 'expense';
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });

        // Suggest category based on location
        final suggestedCategoryId = await _locationService.suggestCategoryByLocation(position);
        if (suggestedCategoryId != null) {
          setState(() {
            _selectedCategoryId = suggestedCategoryId;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _onReceiptCaptured(ReceiptData receiptData) {
    setState(() {
      _amountController.text = receiptData.totalAmount.toString();
      _descriptionController.text = receiptData.merchantName;
      _date = receiptData.date;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt data captured successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save logic would go here
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account selector
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                items: widget.accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category selector
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Type selector
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_date.toString().split(' ').first),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                    });
                  }
                },
              ),
              const Divider(),

              // Location-based categorization
              ListTile(
                title: const Text('Use Current Location'),
                subtitle: _currentPosition != null
                    ? Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}')
                    : const Text('Tap to get location-based category suggestion'),
                trailing: _isGettingLocation
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.location_on),
                onTap: _getCurrentLocation,
              ),
              const Divider(),

              // Receipt capture
              const Text(
                'Receipt Capture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ReceiptCaptureWidget(onReceiptCaptured: _onReceiptCaptured),
              const SizedBox(height: 16),

              // Nearby places (would be implemented in a real app)
              /*
              if (_currentPosition != null)
                FutureBuilder<List<NearbyPlace>>(
                  future: _locationService.getNearbyPlaces(_currentPosition!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nearby Places',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...snapshot.data!.map((place) {
                            return ListTile(
                              title: Text(place.name),
                              subtitle: Text(place.address),
                              onTap: () {
                                setState(() {
                                  _descriptionController.text = place.name;
                                  if (place.suggestedCategoryId != null) {
                                    _selectedCategoryId = place.suggestedCategoryId!;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              */
            ],
          ),
        ),
      ),
    );
  }
}