import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final String? imageUrl;
  final List<String> labels;
  final bool isDeleted;
  final String? signatureUrl;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.imageUrl,
    this.labels = const [],
    this.isDeleted = false,
    this.signatureUrl,
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
      isFavorite: data['isFavorite'] ?? false,
      isArchived: data['isArchived'] ?? false,
      imageUrl: data['imageUrl'],
      labels: List<String>.from(data['labels'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
      signatureUrl: data['signatureUrl'],
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
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'imageUrl': imageUrl,
      'labels': labels,
      'isDeleted': isDeleted,
      'signatureUrl': signatureUrl,
    };
  }

  Note copyWith({
    String? title,
    String? content,
    int? color,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    String? imageUrl,
    List<String>? labels,
    bool? isDeleted,
    String? signatureUrl,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      imageUrl: imageUrl ?? this.imageUrl,
      labels: labels ?? this.labels,
      isDeleted: isDeleted ?? this.isDeleted,
      signatureUrl: signatureUrl ?? this.signatureUrl,
    );
  }
}
