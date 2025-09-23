import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/work_location.dart';
import '../../../presentation/providers/work_location_provider.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/repositories/work_location_repository.dart';
import '../../../domain/usecases/work_location/create_work_location_usecase.dart';

final workLocationFormProvider = StateNotifierProvider<WorkLocationFormNotifier, WorkLocationFormState>((ref) {
  return WorkLocationFormNotifier();
});

class WorkLocationFormNotifier extends StateNotifier<WorkLocationFormState> {
  WorkLocationFormNotifier() : super(WorkLocationFormState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void selectFrequentLocation(WorkLocation location) {
    state = state.copyWith(
      selectedLocation: location,
      name: location.name,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedLocation: null);
  }
}

class WorkLocationFormState {
  final String name;
  final WorkLocation? selectedLocation;

  WorkLocationFormState({
    this.name = '',
    this.selectedLocation,
  });

  WorkLocationFormState copyWith({
    String? name,
    WorkLocation? selectedLocation,
  }) {
    return WorkLocationFormState(
      name: name ?? this.name,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

class WorkLocationFormScreen extends ConsumerStatefulWidget {
  final int userId;

  const WorkLocationFormScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<WorkLocationFormScreen> createState() => _WorkLocationFormScreenState();
}

class _WorkLocationFormScreenState extends ConsumerState<WorkLocationFormScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFrequentLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadFrequentLocations() async {
    final provider = ref.read(workLocationProvider.notifier);
    await provider.loadFrequentWorkLocations(widget.userId);
  }

  void _selectFrequentLocation(WorkLocation location) {
    ref.read(workLocationFormProvider.notifier).selectFrequentLocation(location);
    setState(() {
      _nameController.text = location.name;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the name from the controller or state
      final name = _nameController.text.trim();
      
      // Create database helper and repository
      final dbHelper = DatabaseHelper.instance;
      final repository = WorkLocationRepositoryImpl(dbHelper: dbHelper);
      final useCase = CreateWorkLocationUsecase(repository);

      // Create work location entity
      final now = DateTime.now();
      final workLocation = WorkLocation(
        userId: widget.userId,
        name: name,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      // Execute use case
      await useCase.execute(workLocation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lugar de trabajo registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al registrar el lugar de trabajo: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(workLocationFormProvider);
    final workLocationProviderState = ref.watch(workLocationProvider);
    final frequentLocations = workLocationProviderState.frequentWorkLocations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Lugar de Trabajo'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Registrar Lugar de Trabajo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Registra tu lugar de trabajo diario',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del lugar',
                    hintText: 'Ej: Oficina central, Casa del cliente, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: formState.selectedLocation == null && _nameController.text.isNotEmpty
                        ? const Icon(Icons.add_location, color: Colors.blue)
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el nombre del lugar';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    // Additional validation for new locations
                    if (formState.selectedLocation == null && value.trim().isNotEmpty) {
                      // Check if this is a new location (not in frequent locations)
                      final isFrequent = frequentLocations.any((loc) => loc.name == value.trim());
                      if (!isFrequent) {
                        // Show indication that this is a new location
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Clear selection when user types manually
                    if (formState.selectedLocation != null && value != formState.selectedLocation!.name) {
                      ref.read(workLocationFormProvider.notifier).clearSelection();
                    }
                    ref.read(workLocationFormProvider.notifier).updateName(value);
                  },
                ),
                const SizedBox(height: 8),
                if (formState.selectedLocation == null && _nameController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Nuevo lugar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 24),
                if (frequentLocations.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lugares frecuentes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'o escribe uno nuevo',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: frequentLocations.length,
                      itemBuilder: (context, index) {
                        final location = frequentLocations[index];
                        final isSelected = formState.selectedLocation?.id == location.id;
                        
                        return GestureDetector(
                          onTap: () => _selectFrequentLocation(location),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).primaryColor 
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.location_on,
                                  size: 18,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  location.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Colors.white : Colors.grey[800],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrar Lugar de Trabajo',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}