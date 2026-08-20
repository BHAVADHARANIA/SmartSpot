import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../utils/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final active = provider.active.length;
    final completed = provider.completed.length;
    final archived = provider.archived.length;
    final total = active + completed + archived;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: total == 0
          ? Center(child: Text('Create some reminders to see insights', style: TextStyle(color: Colors.grey.shade600)))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reminder status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(value: active.toDouble(), color: AppTheme.primary, title: '$active', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          PieChartSectionData(value: completed.toDouble(), color: AppTheme.accent, title: '$completed', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          PieChartSectionData(value: archived.toDouble(), color: Colors.grey.shade400, title: '$archived', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    children: [
                      _Legend(color: AppTheme.primary, label: 'Active ($active)'),
                      _Legend(color: AppTheme.accent, label: 'Completed ($completed)'),
                      _Legend(color: Colors.grey.shade400, label: 'Archived ($archived)'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
