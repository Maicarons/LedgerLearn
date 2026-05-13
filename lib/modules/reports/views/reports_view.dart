import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('reports_title'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCard(
            icon: Icons.balance,
            title: 'reports_trial_balance'.tr,
            subtitle: 'reports_trial_balance_hint'.tr,
            color: colorScheme.primary,
            onTap: () => Get.toNamed('/reports/trial-balance'),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.trending_up,
            title: 'reports_income_statement'.tr,
            subtitle: 'reports_income_hint'.tr,
            color: Colors.teal,
            onTap: () => Get.toNamed('/reports/income-statement'),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.account_balance,
            title: 'reports_balance_sheet'.tr,
            subtitle: 'reports_balance_hint'.tr,
            color: Colors.indigo,
            onTap: () => Get.toNamed('/reports/balance-sheet'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
