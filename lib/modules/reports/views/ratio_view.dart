import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ratio_controller.dart';

/// Financial-ratio teaching report.
class RatioView extends GetView<RatioController> {
  const RatioView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.put(RatioController());

    return Scaffold(
      appBar: AppBar(
        title: Text('reports_ratios'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'reports_how_to_read'.tr,
                middleText: 'reports_ratios_hint'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: GetBuilder<RatioController>(
        builder: (c) {
          final r = c.ratios;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ratio_intro'.tr,
                          style: TextStyle(color: colorScheme.outline)),
                      const SizedBox(height: 12),
                      for (final row in r.rows)
                        _RatioTile(
                          label: row.labelKey.tr,
                          value: row.display,
                          hint: row.hintKey.tr,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RatioTile extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  const _RatioTile({
    required this.label,
    required this.value,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(hint,
              style: TextStyle(fontSize: 12, color: colorScheme.outline)),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
