import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category.dart' as entity;
import '../../data/models/category.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final int userId;
  final entity.Category? category;
  final Function(entity.Category) onSave;

  const CategoryFormScreen({
    Key? key,
    required this.userId,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _type;
  late Color _selectedColor;
  String? _selectedIcon;

  // Predefined colors for categories
  final List<Color> _colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
  ];

  // Predefined icons for categories
  final List<String> _iconOptions = [
    'food',
    'transport',
    'shopping',
    'entertainment',
    'health',
    'salary',
    'gift',
    'home',
    'education',
    'business',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );
    _type = widget.category?.type ?? 'expense';
    _selectedColor = _getColorFromHex(widget.category?.color) ?? Colors.blue;
    _selectedIcon = widget.category?.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Nueva Categoría' : 'Editar Categoría'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: categoryProvider.isSubmitting
                ? null
                : () {
                    _saveCategory(categoryProvider);
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
              // Name input
              _buildNameField(),
              
              const SizedBox(height: 16),
              
              // Type selector
              _buildTypeSelector(),
              
              const SizedBox(height: 16),
              
              // Color selector
              _buildColorSelector(),
              
              const SizedBox(height: 16),
              
              // Icon selector
              _buildIconSelector(),
              
              const SizedBox(height: 24),
              
              // Save button
              _buildSaveButton(categoryProvider),
              
              // Error message
              if (categoryProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    categoryProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre de la categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese un nombre para la categoría';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Ingreso'),
                leading: Radio<String>(
                  value: 'income',
                  groupValue: _type,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                      });
                    }
                  },
                ),
                onTap: () {
                  setState(() {
                    _type = 'income';
                  });
                },
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Gasto'),
                leading: Radio<String>(
                  value: 'expense',
                  groupValue: _type,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                      });
                    }
                  },
                ),
                onTap: () {
                  setState(() {
                    _type = 'expense';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: _selectedColor == color
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ícono', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _iconOptions.map((iconName) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = iconName;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _selectedIcon == iconName
                      ? _selectedColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: _selectedIcon == iconName
                      ? Border.all(color: _selectedColor, width: 2)
                      : null,
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: _selectedColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(CategoryProvider categoryProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: categoryProvider.isSubmitting
            ? null
            : () {
                _saveCategory(categoryProvider);
              },
        child: categoryProvider.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(widget.category == null ? 'Crear Categoría' : 'Actualizar Categoría'),
      ),
    );
  }

  void _saveCategory(CategoryProvider categoryProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final colorHex = _getColorHex(_selectedColor);

    try {
      entity.Category? result;
      
      if (widget.category == null) {
        // Create new category
        result = await categoryProvider.createCategory(
          userId: widget.userId,
          name: name,
          type: _type,
          color: colorHex,
          icon: _selectedIcon,
        );
      } else {
        // Update existing category
        final updatedCategory = Category(
          id: widget.category!.id,
          userId: widget.category!.userId,
          name: name,
          type: _type,
          color: colorHex,
          icon: _selectedIcon,
          createdAt: widget.category!.createdAt,
          isSystemCategory: widget.category!.isSystemCategory,
        );
        
        final success = await categoryProvider.updateCategory(updatedCategory);
        if (success) {
          result = updatedCategory;
        }
      }

      if (result != null) {
        if (mounted) {
          widget.onSave(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoría guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la categoría: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
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
      case 'gift':
        return Icons.card_giftcard;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      case 'business':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    
    // Remove the # if present
    hexColor = hexColor.replaceAll('#', '');
    
    // Ensure it's a valid hex color
    if (hexColor.length != 6) return Colors.blue;
    
    // Parse and return the color
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }
}