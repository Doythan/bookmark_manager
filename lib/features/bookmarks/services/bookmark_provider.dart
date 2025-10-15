import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // ← StateProvider 사용 위해

import '../../auth/services/auth_provider.dart';
import '../models/bookmark.dart';
import 'bookmark_service.dart';

// BookmarkService Provider
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

// 북마크 스트림 Provider
final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  return bookmarkService.getBookmarksStream(currentUser.uid);
});

// 카테고리 목록 Provider (Stream으로 변경!) ✅
final categoriesProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final bookmarksAsync = ref.watch(bookmarksStreamProvider);

  // 북마크 Stream에서 카테고리 추출
  return bookmarksAsync.when(
    data: (bookmarks) {
      // 중복 제거 및 정렬
      final categories = bookmarks
          .map((bookmark) => bookmark.category)
          .toSet()
          .toList();

      categories.sort();

      // Stream으로 반환
      return Stream.value(categories);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// 선택된 카테고리 Provider (필터링용)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 필터링된 북마크 Provider
final filteredBookmarksProvider = Provider<List<Bookmark>>((ref) {
  final bookmarksAsync = ref.watch(bookmarksStreamProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return bookmarksAsync.when(
    data: (bookmarks) {
      if (selectedCategory == null) {
        return bookmarks;
      }
      return bookmarks.where((b) => b.category == selectedCategory).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// 검색어 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 검색된 북마크 Provider
final searchedBookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  final query = ref.watch(searchQueryProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  if (query.isEmpty) {
    return bookmarkService.getBookmarksStream(currentUser.uid);
  }

  return bookmarkService.searchBookmarks(currentUser.uid, query);
});
