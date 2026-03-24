import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isPinned;
  final bool isArchived;
  final String? imageUrl;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isArchived = false,
    this.imageUrl,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      color: data['color'] ?? 0xFFFFFFFF,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPinned: data['isPinned'] ?? false,
      isArchived: data['isArchived'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'isArchived': isArchived,
      'imageUrl': imageUrl,
    };
  }

  Note copyWith({
    String? title,
    String? content,
    int? color,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    String? imageUrl,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
