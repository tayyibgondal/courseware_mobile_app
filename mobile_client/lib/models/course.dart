class Course {
  final String id;
  final String name;
  final String description;
  final String instructor;
  final String university;
  final String year;
  final List<String> topics;
  final String? imageUrl;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.instructor,
    required this.university,
    required this.year,
    required this.topics,
    this.imageUrl,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      university: json['university'] ?? '',
      year: json['year'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructor': instructor,
      'university': university,
      'year': year,
      'topics': topics,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 