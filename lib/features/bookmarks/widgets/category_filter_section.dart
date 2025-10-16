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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // 스크롤 가능한 카테고리 칩들
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      // 전체 버튼
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedCategory == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                null;
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
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
                                    category;
                              } else {
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
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

                      // 스크롤 끝 여백
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              // 우측 고정 관리 버튼
              Container(
                margin: const EdgeInsets.only(right: 12, left: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 22),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ManageCategoriesDialog(),
                    );
                  },
                  tooltip: '카테고리 관리',
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
