import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category.dart' as entity;
import 'category_form_screen.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  final int userId;

  const CategoryManagementScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider).loadCategories(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryFormScreen(
                    userId: widget.userId,
                    onSave: (category) {
                      ref.read(categoryProvider).loadCategories(widget.userId);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.error != null
              ? Center(child: Text('Error: ${categoryProvider.error}'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(categoryProvider).loadCategories(widget.userId);
                  },
                  child: _buildCategoryList(categoryProvider),
                ),
    );
  }

  Widget _buildCategoryList(CategoryProvider categoryProvider) {
    final groupedCategories = categoryProvider.groupCategoriesByType();
    
    return ListView(
      children: [
        ..._buildCategorySection('Ingresos', groupedCategories['income'] ?? []),
        const Divider(),
        ..._buildCategorySection('Gastos', groupedCategories['expense'] ?? []),
      ],
    );
  }

  List<Widget> _buildCategorySection(String title, List<entity.Category> categories) {
    if (categories.isEmpty) {
      return [
        ListTile(
          title: Text(title),
          subtitle: const Text('No hay categorías'),
        ),
      ];
    }

    return [
      ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...categories.map((category) => _buildCategoryItem(category)).toList(),
    ];
  }

  Widget _buildCategoryItem(entity.Category category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildCategoryIcon(category),
        title: Text(category.name),
        trailing: category.isSystemCategory
            ? const Icon(Icons.lock, size: 16, color: Colors.grey)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryFormScreen(
                            userId: widget.userId,
                            category: category,
                            onSave: (updatedCategory) {
                              ref.read(categoryProvider).loadCategories(widget.userId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () {
                      _confirmDeleteCategory(category);
                    },
                  ),
                ],
              ),
        onTap: category.isSystemCategory
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryFormScreen(
                      userId: widget.userId,
                      category: category,
                      onSave: (updatedCategory) {
                        ref.read(categoryProvider).loadCategories(widget.userId);
                      },
                    ),
                  ),
                );
              },
      ),
    );
  }

  Widget _buildCategoryIcon(entity.Category category) {
    // You can customize this based on your icon system
    if (category.icon != null && category.icon!.isNotEmpty) {
      // If you're using a specific icon library, implement it here
      return Icon(
        _getIconData(category.icon!),
        color: _getColorFromHex(category.color),
      );
    } else {
      // Default icon based on category type
      return Icon(
        category.type == 'income' ? Icons.trending_up : Icons.trending_down,
        color: _getColorFromHex(category.color) ?? 
               (category.type == 'income' ? Colors.green : Colors.red),
      );
    }
  }

  IconData _getIconData(String iconName) {
    // Map icon names to actual IconData
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'salary':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  Color? _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    
    // Remove the # if present
    hexColor = hexColor.replaceAll('#', '');
    
    // Ensure it's a valid hex color
    if (hexColor.length != 6) return null;
    
    // Parse and return the color
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  void _confirmDeleteCategory(entity.Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar categoría'),
          content: Text('¿Está seguro de que desea eliminar la categoría "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await ref
                    .read(categoryProvider)
                    .deleteCategory(category.id!);
                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoría eliminada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error al eliminar la categoría: ${ref.read(categoryProvider).error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}