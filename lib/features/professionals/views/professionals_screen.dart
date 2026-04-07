import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfessionalsScreen extends StatelessWidget {
  const ProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).findProfessionals),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: L.of(context).searchDoctors,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryChip(label: 'All', isSelected: true),
                _CategoryChip(label: 'OB-GYN'),
                _CategoryChip(label: 'Pediatrician'),
                _CategoryChip(label: 'Midwife'),
                _CategoryChip(label: 'Doula'),
                _CategoryChip(label: 'Lactation'),
                _CategoryChip(label: 'Therapist'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Featured
          Text('Recommended for You', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          const _DoctorCard(
            name: 'Dr. Amara Khan',
            specialty: 'OB-GYN',
            rating: 4.9,
            reviews: 234,
            nextAvailable: 'Tomorrow, 10:00 AM',
            isVerified: true,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const _DoctorCard(
            name: 'Dr. Maria Santos',
            specialty: 'Pediatrician',
            rating: 4.8,
            reviews: 189,
            nextAvailable: 'Wed, Apr 9, 2:00 PM',
            isVerified: true,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          const _DoctorCard(
            name: 'Lisa Chen, CNM',
            specialty: 'Certified Nurse Midwife',
            rating: 5.0,
            reviews: 97,
            nextAvailable: 'Thu, Apr 10, 11:00 AM',
            isVerified: true,
            color: AppColors.stagePrePregnancy,
          ),
          const SizedBox(height: 12),
          const _DoctorCard(
            name: 'Rachel Adams',
            specialty: 'Lactation Consultant (IBCLC)',
            rating: 4.9,
            reviews: 156,
            nextAvailable: 'Available now — video call',
            isVerified: true,
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          const _DoctorCard(
            name: 'Dr. James Okafor',
            specialty: 'Pediatric Sleep Specialist',
            rating: 4.7,
            reviews: 78,
            nextAvailable: 'Fri, Apr 11, 9:00 AM',
            isVerified: true,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String nextAvailable;
  final bool isVerified;
  final Color color;

  const _DoctorCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.nextAvailable,
    required this.isVerified,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    name.split(' ').last[0],
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(specialty, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.accent),
                          const SizedBox(width: 3),
                          Text(
                            '$rating',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            ' ($reviews reviews)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    nextAvailable,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Book'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
