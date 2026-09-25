import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/practice_service.dart';
import '../controllers/practice_controller.dart';

class WrongBookView extends GetView<WrongBookController> {
  const WrongBookView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(WrongBookController());
    final service = Get.find<PracticeService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('practice_wrong_book'.tr),
        actions: [
          IconButton(
            tooltip: 'practice_clear_wrong'.tr,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await Get.dialog<bool>(
                AlertDialog(
                  title: Text('confirm'.tr),
                  content: Text('practice_clear_wrong_confirm'.tr),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('cancel'.tr)),
                    FilledButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('confirm'.tr)),
                  ],
                ),
              );
              if (ok == true) await c.clear();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (c.items.isEmpty) {
          return Center(
            child: Text('practice_wrong_empty'.tr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.items.length,
          itemBuilder: (context, i) {
            final a = c.items[i];
            final scenario = service.byId(a.scenarioId);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text(scenario?.titleKey.tr ?? a.scenarioId),
                subtitle: Text(
                  '${a.at.year}-${a.at.month.toString().padLeft(2, '0')}-${a.at.day.toString().padLeft(2, '0')}  ·  '
                  '${a.problems.map((p) => p.tr).join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('practice_your_lines'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        ...a.lines.map((l) => Text(
                              '${l.accountId}  ${l.isDebit ? 'D' : 'C'}  ${(l.amountCents / 100).toStringAsFixed(2)}',
                            )),
                        const SizedBox(height: 8),
                        Text('practice_explanation'.tr,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(scenario?.explanationKey.tr ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
