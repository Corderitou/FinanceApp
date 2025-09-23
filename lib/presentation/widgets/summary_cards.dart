import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialSummaryCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  final double savingsRate;

  const FinancialSummaryCards({
    Key? key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.savingsRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Income',
                value: '\$${totalIncome.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                iconColor: Colors.white,
                backgroundColor: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Total Expenses',
                value: '\$${totalExpenses.toStringAsFixed(2)}',
                icon: Icons.trending_down,
                iconColor: Colors.white,
                backgroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SummaryCard(
          title: 'Net Savings',
          value: '\$${netSavings.toStringAsFixed(2)}',
          subtitle: 'Savings Rate: ${(savingsRate * 100).toStringAsFixed(1)}%',
          icon: Icons.savings,
          iconColor: Colors.white,
          backgroundColor: Colors.blue.shade700,
        ),
      ],
    );
  }
}