abstract class DashboardWidget {
  final String id;
  final String title;
  final int rowSpan;
  final int columnSpan;

  DashboardWidget({
    required this.id,
    required this.title,
    this.rowSpan = 1,
    this.columnSpan = 1,
  });

  Widget build(BuildContext context);
}

class SummaryCardWidget extends DashboardWidget {
  final String value;
  final String description;
  final IconData icon;
  final Color color;

  SummaryCardWidget({
    required String id,
    required String title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  }) : super(id: id, title: title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartWidget extends DashboardWidget {
  final List<ChartData> data;

  ChartWidget({
    required String id,
    required String title,
    required this.data,
  }) : super(id: id, title: title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: entry.value.color,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Text(data[index].label);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentTransactionsWidget extends DashboardWidget {
  final List<Transaction> transactions;

  RecentTransactionsWidget({
    required String id,
    required String title,
    required this.transactions,
  }) : super(id: id, title: title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    title: Text(transaction.description ?? 'Unnamed Transaction'),
                    subtitle: Text(
                      '${transaction.date.toString().split(' ').first} • ${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.type == 'income' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsWidget extends DashboardWidget {
  final List<QuickAction> actions;

  QuickActionsWidget({
    required String id,
    required String title,
    required this.actions,
  }) : super(id: id, title: title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((action) {
                return ElevatedButton.icon(
                  onPressed: action.onPressed,
                  icon: Icon(action.icon, size: 16),
                  label: Text(action.label),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

// Extension to use BarChart from fl_chart
extension BarChart on Widget {
  // This is just a placeholder to satisfy the compiler
  // In reality, we would import and use the fl_chart package
}