import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final String userId;
  final String url;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.url,
    required this.title,
    this.description = '',
    this.category = 'General',
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore에서 데이터를 가져올 때
  factory Bookmark.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Bookmark(
      id: doc.id,
      userId: data['userId'] ?? '',
      url: data['url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore에 저장할 때
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'url': url,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // 북마크 수정용 copyWith
  Bookmark copyWith({
    String? id,
    String? userId,
    String? url,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
