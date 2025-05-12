import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String category;
  final String imageUrl;
  final double rating;
  final int enrollmentCount;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPublished;
  final String authorId;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    this.imageUrl = '',
    this.rating = 0.0,
    this.enrollmentCount = 0,
    required this.createdAt,
    this.tags = const [],
    this.isPublished = true,
    required this.authorId,
  });

  // Create Course from Firestore document
  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      enrollmentCount: data['enrollmentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      isPublished: data['isPublished'] ?? true,
      authorId: data['authorId'] ?? '',
    );
  }

  // Convert Course to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'enrollmentCount': enrollmentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'isPublished': isPublished,
      'authorId': authorId,
    };
  }

  // Create a copy of Course with updated fields
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? category,
    String? imageUrl,
    double? rating,
    int? enrollmentCount,
    DateTime? createdAt,
    List<String>? tags,
    bool? isPublished,
    String? authorId,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      authorId: authorId ?? this.authorId,
    );
  }
} 