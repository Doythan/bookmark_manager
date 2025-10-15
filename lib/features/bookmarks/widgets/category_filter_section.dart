import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../services/bookmark_provider.dart';
import 'manage_categories_dialog.dart';

class CategoryFilterSection extends ConsumerWidget {
  const CategoryFilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        // General 추가
        final allCategories = {'General', ...categories}.toList();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 전체 버튼
                FilterChip(
                  label: const Text('전체'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selectedCategory == null
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),

                // 카테고리 버튼들
                ...allCategories.map((category) {
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        } else {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  );
                }),

                // 카테고리 관리 버튼
                const SizedBox(width: 4),
                ActionChip(
                  avatar: const Icon(
                    Icons.settings,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    '관리',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ManageCategoriesDialog(),
                    );
                  },
                  backgroundColor: AppColors.primaryLight,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
