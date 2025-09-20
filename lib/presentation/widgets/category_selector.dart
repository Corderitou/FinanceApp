import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../presentation/providers/category_provider.dart';
import '../../data/models/category.dart' as model;

class CategorySelector extends ConsumerStatefulWidget {
  final int userId;
  final String transactionType;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.userId,
    required this.transactionType,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Category> _filteredCategories = [];
  bool _showSearchResults = false;
  bool _isLoading = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      await ref.read(categoryProvider.notifier).loadCategories(widget.userId);
      final categories = ref.read(categoryProvider).categories;
      final filtered = categories
          .where((category) => category.type == widget.transactionType)
          .toList();
      setState(() {
        _filteredCategories = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchError = 'Error al cargar categorías: ${e.toString()}';
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      // Show all categories of the correct type
      final categories = ref.read(categoryProvider).categories;
      setState(() {
        _filteredCategories = categories
            .where((category) => category.type == widget.transactionType)
            .toList();
        _showSearchResults = false;
      });
    } else {
      // Filter categories based on search query
      final categories = ref.read(categoryProvider).categories;
      final filtered = categories
          .where((category) =>
              category.type == widget.transactionType &&
              category.name.toLowerCase().contains(query))
          .toList();
      
      setState(() {
        _filteredCategories = filtered;
        _showSearchResults = true;
      });
    }
  }

  Future<void> _createNewCategory(String name) async {
    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      final newCategory = model.Category(
        userId: widget.userId,
        name: name.trim(),
        type: widget.transactionType,
        color: _getDefaultColor(widget.transactionType),
        createdAt: DateTime.now(),
        isSystemCategory: false,
      );

      final success = await ref.read(categoryProvider.notifier).createCategory(newCategory);
      
      if (success) {
        // Reload categories
        await _loadCategories();
        
        // Find and select the newly created category
        final categories = ref.read(categoryProvider).categories;
        final createdCategory = categories.firstWhere(
          (cat) => cat.name.toLowerCase() == name.toLowerCase().trim() && 
                  cat.type == widget.transactionType,
        );
        
        widget.onCategorySelected(createdCategory.id);
        _searchController.clear();
        setState(() {
          _showSearchResults = false;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoría "$name" creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No se pudo crear la categoría');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchError = 'Error al crear categoría: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_searchError!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDefaultColor(String type) {
    switch (type) {
      case 'income':
        return '#4CAF50'; // Green
      case 'expense':
      default:
        return '#F44336'; // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.selectedCategoryId != null
        ? ref.watch(categoryProvider).categories.firstWhereOrNull(
              (cat) => cat.id == widget.selectedCategoryId)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Buscar o crear categoría...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.selectedCategoryId != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.onCategorySelected(null);
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
            errorText: _searchError,
          ),
          onChanged: (_) => _onSearchChanged(),
        ),
        const SizedBox(height: 8),
        if (selectedCategory != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(int.parse(selectedCategory.color!.replaceFirst('#', '0xFF'))),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse(selectedCategory.color!.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(selectedCategory.name),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCategory.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white, size: 20),
                  onPressed: () {
                    widget.onCategorySelected(null);
                    _searchController.clear();
                    _onSearchChanged();
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (_showSearchResults || _filteredCategories.isNotEmpty)
          _buildCategorySuggestions(),
      ],
    );
  }

  Widget _buildCategorySuggestions() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final query = _searchController.text.trim();

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Show existing categories
            ..._filteredCategories.map((category) {
              final isSelected = category.id == widget.selectedCategoryId;
              return ListTile(
                title: Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Color(
                    int.parse(category.color!.replaceFirst('#', '0xFF')),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                onTap: () {
                  widget.onCategorySelected(category.id);
                  _searchController.clear();
                  setState(() {
                    _showSearchResults = false;
                  });
                },
              );
            }).toList(),

            // Show option to create new category if search query exists and no matches
            if (query.isNotEmpty &&
                !_filteredCategories
                    .any((cat) => cat.name.toLowerCase() == query.toLowerCase()))
              ListTile(
                title: Text('Crear "$query"'),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, color: Colors.white, size: 18),
                ),
                onTap: () => _createNewCategory(query),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    // Income categories
    if (name.contains('salario') || name.contains('sueldo')) {
      return Icons.work;
    } else if (name.contains('freelance') || name.contains('freelancer')) {
      return Icons.computer;
    } else if (name.contains('inversión') || name.contains('inversion')) {
      return Icons.trending_up;
    } else if (name.contains('regalo') || name.contains('gift')) {
      return Icons.card_giftcard;
    }
    
    // Expense categories
    else if (name.contains('comida') || name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('transporte') || name.contains('transport')) {
      return Icons.directions_car;
    } else if (name.contains('compra') || name.contains('shopping')) {
      return Icons.shopping_cart;
    } else if (name.contains('entretenimiento') || name.contains('entertainment')) {
      return Icons.movie;
    } else if (name.contains('salud') || name.contains('health')) {
      return Icons.local_hospital;
    } else if (name.contains('vivienda') || name.contains('house')) {
      return Icons.home;
    } else if (name.contains('educación') || name.contains('education')) {
      return Icons.school;
    }
    
    // Default icons
    else if (widget.transactionType == 'income') {
      return Icons.attach_money;
    } else {
      return Icons.money_off;
    }
  }
}

// Extension to add firstWhereOrNull method
extension FirstWhereOrNull<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}