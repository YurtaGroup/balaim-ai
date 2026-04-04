import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/emergency_data.dart';

class EmergencyReferenceScreen extends StatelessWidget {
  const EmergencyReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('When to Call the Doctor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Critical banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.emergency,
                    color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trust your gut',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'If something feels wrong, call your doctor. '
                        'It\'s always better to ask.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Urgency legend
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Urgency.values.map((u) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: u.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: u.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: u.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        u.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: u.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Categories
          ...EmergencyData.categories.map((cat) => _CategorySection(cat: cat)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final EmergencyCategory cat;
  const _CategorySection({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Icon(cat.icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(cat.title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        ...cat.signs.map((s) => _SignCard(sign: s)),
      ],
    );
  }
}

class _SignCard extends StatelessWidget {
  final EmergencySign sign;
  const _SignCard({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: sign.urgency.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sign.urgency.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: sign.urgency.color,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sign.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sign.description,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
