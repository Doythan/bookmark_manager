import 'package:bookmark_manager/core/utils/url_launcher_helper.dart';
import 'package:bookmark_manager/features/bookmarks/models/bookmark.dart';
import 'package:bookmark_manager/features/bookmarks/widgets/bookmark_search_delegate.dart';
import 'package:bookmark_manager/features/bookmarks/widgets/category_filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/services/auth_provider.dart';
import '../services/bookmark_provider.dart';
import '../widgets/add_bookmark_dialog.dart';
import '../widgets/bookmark_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myBookmarks),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // 검색 버튼
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: BookmarkSearchDelegate());
            },
          ),
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터
          const CategoryFilterSection(),
          const Divider(height: 1),

          // 북마크 목록
          Expanded(
            child: bookmarksAsync.when(
              data: (bookmarks) {
                // 카테고리 필터링
                final filteredBookmarks = selectedCategory == null
                    ? bookmarks
                    : bookmarks
                          .where((b) => b.category == selectedCategory)
                          .toList();

                if (filteredBookmarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noBookmarks,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아래 + 버튼을 눌러 북마크를 추가해보세요!',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = filteredBookmarks[index];
                    return BookmarkCard(
                      bookmark: bookmark,
                      onTap: () => _openBookmark(context, bookmark),
                      onEdit: () => _editBookmark(context, ref, bookmark),
                      onDelete: () => _deleteBookmark(context, ref, bookmark),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '북마크를 불러올 수 없습니다',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookmarkDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _openBookmark(BuildContext context, Bookmark bookmark) async {
    await UrlLauncherHelper.openUrl(bookmark.url, context);
  }

  void _showAddBookmarkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddBookmarkDialog(),
    );
  }

  void _editBookmark(BuildContext context, WidgetRef ref, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(bookmark: bookmark),
    );
  }

  Future<void> _deleteBookmark(
    BuildContext context,
    WidgetRef ref,
    Bookmark bookmark,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('북마크 삭제'),
        content: const Text('이 북마크를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final bookmarkService = ref.read(bookmarkServiceProvider);
        await bookmarkService.deleteBookmark(bookmark.id);

        if (context.mounted) {
          Fluttertoast.showToast(
            msg: AppStrings.bookmarkDeleted,
            backgroundColor: AppColors.success,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: e.toString(),
            backgroundColor: AppColors.error,
          );
        }
      }
    }
  }
}
