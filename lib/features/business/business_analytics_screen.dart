import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessAnalyticsScreen extends StatelessWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Sales Growth', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3000, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4200, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3800, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5100, color: Theme.of(context).primaryColor)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
