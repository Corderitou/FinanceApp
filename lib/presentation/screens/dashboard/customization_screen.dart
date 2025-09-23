import 'package:flutter/material.dart';
import '../widgets/dashboard_widget.dart';

class DashboardCustomizationScreen extends StatefulWidget {
  final List<DashboardWidget> currentWidgets;
  final Function(List<DashboardWidget>) onSave;

  const DashboardCustomizationScreen({
    Key? key,
    required this.currentWidgets,
    required this.onSave,
  }) : super(key: key);

  @override
  _DashboardCustomizationScreenState createState() => _DashboardCustomizationScreenState();
}

class _DashboardCustomizationScreenState extends State<DashboardCustomizationScreen> {
  late List<DashboardWidget> _widgets;
  final List<DashboardWidget> _availableWidgets = [
    // These would be predefined widget templates
    SummaryCardWidget(
      id: 'income_summary',
      title: 'Income Summary',
      value: '\$0.00',
      description: 'Monthly income',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
    SummaryCardWidget(
      id: 'expense_summary',
      title: 'Expense Summary',
      value: '\$0.00',
      description: 'Monthly expenses',
      icon: Icons.trending_down,
      color: Colors.red,
    ),
    // Add more widget templates here
  ];

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.currentWidgets);
  }

  void _addWidget(DashboardWidget widget) {
    setState(() {
      _widgets.add(widget);
    });
  }

  void _removeWidget(int index) {
    setState(() {
      _widgets.removeAt(index);
    });
  }

  void _moveWidget(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _widgets.removeAt(oldIndex);
      _widgets.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_widgets);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current widgets
          Expanded(
            child: ReorderableListView(
              onReorder: _moveWidget,
              children: [
                for (int index = 0; index < _widgets.length; index++)
                  Card(
                    key: ValueKey(_widgets[index].id),
                    child: ListTile(
                      title: Text(_widgets[index].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeWidget(index),
                      ),
                      leading: const Icon(Icons.drag_handle),
                    ),
                  ),
              ],
            ),
          ),
          // Available widgets
          const Divider(),
          Container(
            height: 150,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Widgets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _availableWidgets.map((widget) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 4),
                              Text(widget.title, textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () => _addWidget(widget),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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