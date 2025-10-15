import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/services/auth_provider.dart';
import '../models/bookmark.dart';
import '../services/bookmark_provider.dart';
import 'category_autocomplete.dart';

class AddBookmarkDialog extends ConsumerStatefulWidget {
  final Bookmark? bookmark; // null이면 추가, 있으면 수정

  const AddBookmarkDialog({super.key, this.bookmark});

  @override
  ConsumerState<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends ConsumerState<AddBookmarkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 수정 모드면 기존 값으로 초기화
    _urlController = TextEditingController(text: widget.bookmark?.url ?? '');
    _titleController = TextEditingController(
      text: widget.bookmark?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.bookmark?.description ?? '',
    );
    _selectedCategory = widget.bookmark?.category ?? 'General';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bookmarkService = ref.read(bookmarkServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        throw '로그인이 필요합니다';
      }

      final now = DateTime.now();

      if (widget.bookmark == null) {
        // 새 북마크 추가
        final newBookmark = Bookmark(
          id: '', // Firestore가 자동 생성
          userId: currentUser.uid,
          url: _urlController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory.trim(),
          createdAt: now,
          updatedAt: now,
        );

        await bookmarkService.addBookmark(newBookmark);

        if (mounted) {
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: AppStrings.bookmarkAdded,
            backgroundColor: AppColors.success,
          );
        }
      } else {
        // 기존 북마크 수정
        final updatedBookmark = widget.bookmark!.copyWith(
          url: _urlController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory.trim(),
          updatedAt: now,
        );

        await bookmarkService.updateBookmark(updatedBookmark);

        if (mounted) {
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: AppStrings.bookmarkUpdated,
            backgroundColor: AppColors.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.bookmark != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 제목
                  Text(
                    isEditMode
                        ? AppStrings.editBookmark
                        : AppStrings.addBookmark,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // URL 입력
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: AppStrings.url,
                      hintText: 'https://example.com',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldsRequired;
                      }
                      if (!value.startsWith('http://') &&
                          !value.startsWith('https://')) {
                        return 'http:// 또는 https://로 시작해야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 제목 입력
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: AppStrings.title,
                      hintText: '북마크 제목을 입력하세요',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.fieldsRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 설명 입력 (선택사항)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.description} (선택)',
                      hintText: '북마크에 대한 설명을 입력하세요',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // 카테고리 선택 (Autocomplete로 변경!)
                  CategoryAutocomplete(
                    initialValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 취소 버튼
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(AppStrings.cancel),
                      ),
                      const SizedBox(width: 12),

                      // 저장 버튼
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppStrings.save,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
