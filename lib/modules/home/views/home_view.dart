import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../voucher/views/voucher_form_view.dart';
import '../../accounts/views/accounts_view.dart';
import '../../knowledge/views/knowledge_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(HomeController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                'home_title'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
              background: _AppBarBackground(colorScheme: colorScheme),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  Obx(() => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.calendar_month,
                                color: colorScheme.primary, size: 22),
                          ),
                          title: Text('home_period'.tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          trailing: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: controller.currentPeriod.value,
                              underline: const SizedBox(),
                              items: controller.availablePeriods
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) controller.setPeriod(v);
                              },
                            ),
                          ),
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Summary cards
                  Obx(() {
                    final summary = controller.summary.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.receipt_long,
                            label: 'home_voucher_count'.tr,
                            value: '${summary.voucherCount}',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_upward,
                            label: 'home_debit_total'.tr,
                            value: controller.formatAmount(summary.totalDebit),
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),

                  Obx(() {
                    final summary = controller.summary.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_downward,
                            label: 'home_credit_total'.tr,
                            value:
                                controller.formatAmount(summary.totalCredit),
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: summary.isBalanced
                                ? Icons.check_circle
                                : Icons.warning,
                            label: 'home_balance_status'.tr,
                            value: summary.isBalanced
                                ? 'home_balanced'.tr
                                : 'home_unbalanced'.tr,
                            color: summary.isBalanced
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    );
                  }),

                  // Unbalanced warning
                  Obx(() {
                    final s = controller.summary.value;
                    if (s.voucherCount > 0 && !s.isBalanced) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade100,
                                Colors.orange.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.shade200),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.warning_amber,
                                    color: Colors.orange.shade700,
                                    size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('home_check_unbalanced'.tr,
                                    style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 28),

                  // Quick actions
                  Text('快捷操作',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_box_rounded,
                          label: 'home_quick_voucher'.tr,
                          color: colorScheme.primary,
                          onTap: () =>
                              Get.to(() => const VoucherFormView()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.account_balance_rounded,
                          label: 'home_quick_accounts'.tr,
                          color: const Color(0xFF14B8A6),
                          onTap: () => Get.to(() => const AccountsView()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.menu_book_rounded,
                          label: 'home_quick_knowledge'.tr,
                          color: const Color(0xFF8B5CF6),
                          onTap: () =>
                              Get.to(() => const KnowledgeView()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AppBarBackground({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                Color.lerp(
                    colorScheme.primary, colorScheme.secondary, 0.4)!,
                colorScheme.secondaryContainer,
              ],
            ),
          ),
        ),
        // Decorative top-right circle
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        // Decorative bottom-left circle
        Positioned(
          bottom: -80,
          left: -50,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Small decorative dots
        Positioned(
          top: 50,
          right: 60,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: 40,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 50,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        // Bottom wave
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 30),
            painter: _WavePainter(colorScheme: colorScheme),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final ColorScheme colorScheme;
  _WavePainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.25, 0, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shadowColor: color.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
