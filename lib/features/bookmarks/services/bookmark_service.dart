import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bookmark.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookmarks';

  // 사용자의 북마크 스트림 (실시간)
  Stream<List<Bookmark>> getBookmarksStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Bookmark.fromFirestore(doc))
              .toList();
        });
  }

  // 북마크 추가
  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      await _firestore.collection(_collection).add(bookmark.toFirestore());
    } catch (e) {
      throw '북마크 추가 중 오류가 발생했습니다: $e';
    }
  }

  // 북마크 수정
  Future<void> updateBookmark(Bookmark bookmark) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(bookmark.id)
          .update(bookmark.toFirestore());
    } catch (e) {
      throw '북마크 수정 중 오류가 발생했습니다: $e';
    }
  }

  // 북마크 삭제
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _firestore.collection(_collection).doc(bookmarkId).delete();
    } catch (e) {
      throw '북마크 삭제 중 오류가 발생했습니다: $e';
    }
  }

  // 카테고리별 북마크 가져오기
  Stream<List<Bookmark>> getBookmarksByCategory(
    String userId,
    String category,
  ) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Bookmark.fromFirestore(doc))
              .toList();
        });
  }

  // 북마크 검색
  Stream<List<Bookmark>> searchBookmarks(String userId, String query) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final bookmarks = snapshot.docs
              .map((doc) => Bookmark.fromFirestore(doc))
              .toList();

          // 클라이언트 측 검색 (Firestore는 full-text search 미지원)
          return bookmarks.where((bookmark) {
            final titleMatch = bookmark.title.toLowerCase().contains(
              query.toLowerCase(),
            );
            final urlMatch = bookmark.url.toLowerCase().contains(
              query.toLowerCase(),
            );
            final descMatch = bookmark.description.toLowerCase().contains(
              query.toLowerCase(),
            );
            return titleMatch || urlMatch || descMatch;
          }).toList();
        });
  }

  // 사용자의 모든 카테고리 가져오기
  Future<List<String>> getCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      throw '카테고리 조회 중 오류가 발생했습니다: $e';
    }
  }
}
