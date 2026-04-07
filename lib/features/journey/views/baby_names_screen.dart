import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/baby_names_data.dart';
import '../providers/baby_names_provider.dart';

class BabyNamesScreen extends ConsumerWidget {
  const BabyNamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(babyNamesFilterProvider);
    final favorites = ref.watch(favoriteNamesProvider);
    final favNotifier = ref.read(favoriteNamesProvider.notifier);
    final filterNotifier = ref.read(babyNamesFilterProvider.notifier);

    var results = BabyNamesData.filter(
      gender: filter.gender,
      origin: filter.origin,
      search: filter.search,
    );
    if (filter.favoritesOnly) {
      results = results.where((n) => favorites.contains(n.id)).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(L.of(context).babyNames),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              filter.favoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: filter.favoritesOnly ? AppColors.primary : null,
            ),
            onPressed: () => filterNotifier.update(
              (s) => s.copyWith(favoritesOnly: !s.favoritesOnly),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => filterNotifier.update((s) => s.copyWith(search: v)),
              decoration: InputDecoration(
                hintText: 'Search name or meaning...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Gender filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: filter.gender == null,
                  onTap: () =>
                      filterNotifier.update((s) => s.copyWith(clearGender: true)),
                ),
                _FilterChip(
                  label: 'Boys',
                  isSelected: filter.gender == NameGender.boy,
                  onTap: () => filterNotifier.update(
                    (s) => s.copyWith(gender: NameGender.boy),
                  ),
                ),
                _FilterChip(
                  label: 'Girls',
                  isSelected: filter.gender == NameGender.girl,
                  onTap: () => filterNotifier.update(
                    (s) => s.copyWith(gender: NameGender.girl),
                  ),
                ),
                _FilterChip(
                  label: 'Unisex',
                  isSelected: filter.gender == NameGender.unisex,
                  onTap: () => filterNotifier.update(
                    (s) => s.copyWith(gender: NameGender.unisex),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Origin filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All origins',
                  isSelected: filter.origin == null,
                  onTap: () =>
                      filterNotifier.update((s) => s.copyWith(clearOrigin: true)),
                ),
                ...NameOrigin.values.map(
                  (o) => _FilterChip(
                    label: o.label,
                    isSelected: filter.origin == o,
                    onTap: () =>
                        filterNotifier.update((s) => s.copyWith(origin: o)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${results.length} name${results.length == 1 ? '' : 's'}',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: results.isEmpty
                ? _EmptyState(favoritesOnly: filter.favoritesOnly)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: results.length,
                    itemBuilder: (_, i) => _NameTile(
                      babyName: results[i],
                      isFavorite: favorites.contains(results[i].id),
                      onToggleFavorite: () => favNotifier.toggle(results[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NameTile extends StatelessWidget {
  final BabyName babyName;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _NameTile({
    required this.babyName,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  Color get _genderColor {
    switch (babyName.gender) {
      case NameGender.boy:
        return AppColors.secondary;
      case NameGender.girl:
        return AppColors.primary;
      case NameGender.unisex:
        return AppColors.accent;
    }
  }

  String get _genderLabel {
    switch (babyName.gender) {
      case NameGender.boy:
        return 'Boy';
      case NameGender.girl:
        return 'Girl';
      case NameGender.unisex:
        return 'Unisex';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _genderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                babyName.name.substring(0, 1),
                style: TextStyle(
                  color: _genderColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        babyName.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _genderColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _genderLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _genderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        babyName.origin.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  babyName.meaning,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.primary : AppColors.textHint,
            ),
            onPressed: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool favoritesOnly;
  const _EmptyState({required this.favoritesOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              favoritesOnly ? Icons.favorite_border : Icons.search_off,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              favoritesOnly
                  ? 'No favorites yet\nTap the heart to save names you love'
                  : 'No names match your filters',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
