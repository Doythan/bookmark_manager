import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../services/bookmark_provider.dart';

class CategoryAutocomplete extends ConsumerStatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const CategoryAutocomplete({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  ConsumerState<CategoryAutocomplete> createState() =>
      _CategoryAutocompleteState();
}

class _CategoryAutocompleteState extends ConsumerState<CategoryAutocomplete> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? 'General');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        // General이 없으면 추가
        final allCategories = {'General', ...categories}.toList();

        return Autocomplete<String>(
          initialValue: TextEditingValue(text: _controller.text),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return allCategories;
            }

            // 입력값과 매칭되는 카테고리 필터링
            return allCategories.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            _controller.text = selection;
            widget.onChanged(selection);
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController fieldController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // 외부 controller와 동기화
                fieldController.text = _controller.text;
                fieldController.selection = _controller.selection;

                return TextFormField(
                  controller: fieldController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: '카테고리',
                    hintText: '카테고리를 입력하거나 선택하세요',
                    prefixIcon: const Icon(Icons.category),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () {
                        // 포커스를 주면 자동으로 옵션 표시
                        focusNode.requestFocus();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _controller.text = value;
                    widget.onChanged(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '카테고리를 입력하세요';
                    }
                    return null;
                  },
                );
              },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      width: 300,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: options.length + 1,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          // 마지막 항목: "새 카테고리 만들기"
                          if (index == options.length) {
                            return ListTile(
                              leading: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                '새 카테고리: "${_controller.text}"',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                onSelected(_controller.text);
                              },
                            );
                          }

                          // 기존 카테고리 목록
                          final String option = options.elementAt(index);
                          return ListTile(
                            leading: Icon(
                              option == 'General'
                                  ? Icons.folder_special
                                  : Icons.folder,
                              color: option == 'General'
                                  ? AppColors.primary
                                  : Colors.grey[600],
                            ),
                            title: Text(option),
                            trailing: option == 'General'
                                ? const Chip(
                                    label: Text(
                                      '기본',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  )
                                : null,
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
        );
      },
      loading: () => TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: '카테고리',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: widget.onChanged,
      ),
      error: (_, __) => TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: '카테고리',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
