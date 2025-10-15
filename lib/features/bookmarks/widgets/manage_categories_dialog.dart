import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/services/auth_provider.dart';
import '../services/bookmark_provider.dart';

class ManageCategoriesDialog extends ConsumerStatefulWidget {
  const ManageCategoriesDialog({super.key});

  @override
  ConsumerState<ManageCategoriesDialog> createState() =>
      _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState
    extends ConsumerState<ManageCategoriesDialog> {
  String? _editingCategory;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEditing(String category) {
    setState(() {
      _editingCategory = category;
      _editController.text = category;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCategory = null;
      _editController.clear();
    });
  }

  Future<void> _saveEdit(String oldCategory) async {
    final newCategory = _editController.text.trim();

    if (newCategory.isEmpty) {
      Fluttertoast.showToast(
        msg: '카테고리 이름을 입력하세요',
        backgroundColor: AppColors.error,
      );
      return;
    }

    if (newCategory == oldCategory) {
      _cancelEditing();
      return;
    }

    try {
      final bookmarkService = ref.read(bookmarkServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) return;

      await bookmarkService.renameCategoryForUser(
        currentUser.uid,
        oldCategory,
        newCategory,
      );

      _cancelEditing();

      Fluttertoast.showToast(
        msg: '카테고리가 변경되었습니다',
        backgroundColor: AppColors.success,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.folder_special, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    '카테고리 관리',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 카테고리 목록
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  // General을 맨 앞에 추가
                  final allCategories = {'General', ...categories}.toList();

                  if (allCategories.isEmpty) {
                    return const Center(child: Text('카테고리가 없습니다'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: allCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = allCategories[index];
                      final isGeneral = category == 'General';
                      final isEditing = _editingCategory == category;

                      return Card(
                        elevation: 1,
                        child: ListTile(
                          leading: Icon(
                            isGeneral ? Icons.folder_special : Icons.folder,
                            color: isGeneral
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                          title: isEditing
                              ? TextField(
                                  controller: _editController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: '새 카테고리 이름',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (_) => _saveEdit(category),
                                )
                              : Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          subtitle: isGeneral
                              ? const Text(
                                  '기본 카테고리 (수정 불가)',
                                  style: TextStyle(fontSize: 12),
                                )
                              : null,
                          trailing: isGeneral
                              ? const Chip(
                                  label: Text(
                                    '기본',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: AppColors.primaryLight,
                                )
                              : isEditing
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: AppColors.success,
                                      ),
                                      onPressed: () => _saveEdit(category),
                                      tooltip: '저장',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: _cancelEditing,
                                      tooltip: '취소',
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _startEditing(category),
                                  tooltip: '이름 변경',
                                ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('오류: $error')),
              ),
            ),

            const Divider(height: 1),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💡 팁: 북마크 추가 시 새 카테고리를 바로 만들 수 있어요!',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
