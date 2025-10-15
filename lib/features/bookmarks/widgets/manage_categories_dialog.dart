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

  // 삭제 확인 다이얼로그
  Future<void> _confirmDelete(String category) async {
    final bookmarkService = ref.read(bookmarkServiceProvider);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) return;

    // 해당 카테고리의 북마크 개수 조회
    final counts = await bookmarkService.getCategoryCounts(currentUser.uid);
    final bookmarkCount = counts[category] ?? 0;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말 "$category" 카테고리를 삭제하시겠습니까?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bookmarkCount > 0
                          ? '이 카테고리의 북마크 $bookmarkCount개가\nGeneral 카테고리로 이동됩니다.'
                          : '이 카테고리에는 북마크가 없습니다.',
                      style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _deleteCategory(category);
  }

  // 카테고리 삭제 실행
  Future<void> _deleteCategory(String category) async {
    try {
      final bookmarkService = ref.read(bookmarkServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) return;

      await bookmarkService.deleteCategoryForUser(currentUser.uid, category);

      if (mounted) {
        Fluttertoast.showToast(
          msg: '카테고리가 삭제되었습니다',
          backgroundColor: AppColors.success,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: AppColors.error,
        );
      }
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
                                  '기본 카테고리 (수정/삭제 불가)',
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
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _startEditing(category),
                                      tooltip: '이름 변경',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () => _confirmDelete(category),
                                      tooltip: '삭제',
                                    ),
                                  ],
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
                      '💡 팁: 북마크 추가 시 새 카테고리를 바로 만들 수 있어요!\n카테고리를 삭제하면 북마크는 General로 이동됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                        height: 1.4,
                      ),
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
