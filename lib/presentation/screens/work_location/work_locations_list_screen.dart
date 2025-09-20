import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/work_location.dart';
import '../../../presentation/providers/work_location_riverpod_provider.dart';
import 'work_location_form_screen.dart';

class WorkLocationsListScreen extends ConsumerStatefulWidget {
  final int userId;

  const WorkLocationsListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<WorkLocationsListScreen> createState() => _WorkLocationsListScreenState();
}

class _WorkLocationsListScreenState extends ConsumerState<WorkLocationsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load work locations after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkLocations();
    });
  }

  Future<void> _loadWorkLocations() async {
    final provider = ref.read(workLocationProvider.notifier);
    await provider.loadWorkLocations(widget.userId);
  }

  Future<void> _refreshWorkLocations() async {
    await _loadWorkLocations();
  }

  Future<void> _navigateToAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkLocationFormScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      // Refresh the list if a new location was added
      _refreshWorkLocations();
    }
  }

  Future<void> _navigateToEditLocation(WorkLocation location) async {
    // For now, we'll just show a form with the location name pre-filled
    // A full edit functionality could be implemented later
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkLocationFormScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      // Refresh the list if a location was updated
      _refreshWorkLocations();
    }
  }

  void _deleteLocation(WorkLocation location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar lugar de trabajo'),
          content: Text('¿Estás seguro de que quieres eliminar "${location.name}"?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final provider = ref.read(workLocationProvider.notifier);
                  final success = await provider.deleteWorkLocation(
                    location.id!,
                    widget.userId,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lugar de trabajo eliminado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al eliminar el lugar de trabajo'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workLocationState = ref.watch(workLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Lugares de Trabajo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWorkLocations,
        child: Builder(
          builder: (context) {
            if (workLocationState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (workLocationState.workLocations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no has registrado lugares de trabajo',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el botón + para agregar tu primer lugar',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Group locations by date (most recent first)
            final groupedLocations = <String, List<WorkLocation>>{};
            for (var location in workLocationState.workLocations) {
              final dateKey = '${location.date.year}-${location.date.month}-${location.date.day}';
              if (!groupedLocations.containsKey(dateKey)) {
                groupedLocations[dateKey] = [];
              }
              groupedLocations[dateKey]!.add(location);
            }

            // Sort the keys (dates) in descending order
            final sortedKeys = groupedLocations.keys.toList()
              ..sort((a, b) {
                // Parse dates and compare
                final aParts = a.split('-');
                final bParts = b.split('-');
                final aDate = DateTime(int.parse(aParts[0]), int.parse(aParts[1]), int.parse(aParts[2]));
                final bDate = DateTime(int.parse(bParts[0]), int.parse(bParts[1]), int.parse(bParts[2]));
                return bDate.compareTo(aDate); // Descending order
              });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final dateKey = sortedKeys[index];
                final locations = groupedLocations[dateKey]!;
                
                // Parse the date key to display a readable date
                final dateParts = dateKey.split('-');
                final date = DateTime(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                );
                
                final formattedDate = _formatDate(date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      ...locations.map((location) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(location.name),
                          subtitle: Text(
                            '${location.date.hour}:${location.date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _navigateToEditLocation(location),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteLocation(location),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLocation,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateWithoutTime = DateTime(date.year, date.month, date.day);

    if (dateWithoutTime == today) {
      return 'Hoy';
    } else if (dateWithoutTime == yesterday) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}