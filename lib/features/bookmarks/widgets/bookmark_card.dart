import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../models/bookmark.dart';

class BookmarkCard extends StatefulWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final urlType = UrlLauncherHelper.detectUrlType(widget.bookmark.url);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          elevation: _isHovered ? 8 : 0,
          borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.black.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? AppColors.elevatedShadow
                  : AppColors.softShadow,
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    _buildHeader(urlType),
                    const SizedBox(height: 4),

                    // 설명
                    if (widget.bookmark.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildDescription(),
                    ],

                    const SizedBox(height: 12),

                    // 하단
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UrlType urlType) {
    return Row(
      children: [
        // URL 타입 아이콘 (항상 표시)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: urlType != UrlType.general
                ? LinearGradient(
                    colors: [
                      UrlLauncherHelper.getColor(urlType)!.withOpacity(0.2),
                      UrlLauncherHelper.getColor(urlType)!.withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.secondaryLight.withOpacity(0.15),
                      AppColors.secondaryLight.withOpacity(0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            urlType != UrlType.general
                ? UrlLauncherHelper.getIcon(urlType)
                : Icons.language_rounded, // 기본 웹 아이콘
            size: 18,
            color: urlType != UrlType.general
                ? UrlLauncherHelper.getColor(urlType)
                : AppColors.secondaryLight,
          ),
        ),

        const SizedBox(width: 12),

        // 제목
        Expanded(
          child: Text(
            widget.bookmark.title,
            style: AppTextStyles.h4.copyWith(fontSize: 17, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 12),

        // 액션 메뉴
        _buildActionMenu(),
      ],
    );
  }

  Widget _buildActionMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton(
        icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Text('URL 복사', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text('수정', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '삭제',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'copy') {
            Clipboard.setData(ClipboardData(text: widget.bookmark.url));
            Fluttertoast.showToast(
              msg: 'URL이 복사되었습니다',
              backgroundColor: AppColors.success,
            );
          } else if (value == 'edit') {
            widget.onEdit();
          } else if (value == 'delete') {
            widget.onDelete();
          }
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.bookmark.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // 카테고리 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.bookmark.category,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
