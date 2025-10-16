import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
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

class _AddBookmarkDialogState extends ConsumerState<AddBookmarkDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // 수정 모드면 기존 값으로 초기화
    _urlController = TextEditingController(text: widget.bookmark?.url ?? '');
    _titleController = TextEditingController(
      text: widget.bookmark?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.bookmark?.description ?? '',
    );
    _selectedCategory = widget.bookmark?.category ?? '';
  }

  @override
  void dispose() {
    _animationController.dispose();
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

      final category = _selectedCategory.trim().isEmpty
          ? 'General'
          : _selectedCategory.trim();

      if (widget.bookmark == null) {
        // 새 북마크 추가
        final newBookmark = Bookmark(
          id: '',
          userId: currentUser.uid,
          url: _urlController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: category,
          createdAt: now,
          updatedAt: now,
        );

        await bookmarkService.addBookmark(newBookmark);

        if (mounted) {
          await _animationController.reverse();
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
          category: category,
          updatedAt: now,
        );

        await bookmarkService.updateBookmark(updatedBookmark);

        if (mounted) {
          await _animationController.reverse();
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더 (그라데이션 배경)
                _buildHeader(isEditMode),

                // 폼 내용
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // URL 입력
                          _buildTextField(
                            controller: _urlController,
                            label: AppStrings.url,
                            hint: 'https://example.com',
                            icon: Icons.link_rounded,
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
                          const SizedBox(height: 20),

                          // 제목 입력
                          _buildTextField(
                            controller: _titleController,
                            label: AppStrings.title,
                            hint: '북마크 제목을 입력하세요',
                            icon: Icons.title_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldsRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 설명 입력
                          _buildTextField(
                            controller: _descriptionController,
                            label: '${AppStrings.description} (선택)',
                            hint: '북마크에 대한 설명을 입력하세요',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),

                          // 카테고리
                          CategoryAutocomplete(
                            initialValue: _selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // 버튼들
                          _buildButtons(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? Icons.edit_rounded : Icons.bookmark_add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? AppStrings.editBookmark : AppStrings.addBookmark,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditMode ? '북마크 정보 수정' : '새로운 북마크 추가',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // 닫기 버튼
          IconButton(
            onPressed: () async {
              await _animationController.reverse();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // 입력 필드
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        // 취소 버튼
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    await _animationController.reverse();
                    Navigator.pop(context);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.border, width: 1.5),
            ),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 저장 버튼
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.save,
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
