class CareerPath {
  final String id;
  final String title;
  final String description;
  final String? file;
  final DateTime createdAt;
  final DateTime updatedAt;

  CareerPath({
    required this.id,
    required this.title,
    required this.description,
    this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CareerPath.fromJson(Map<String, dynamic> json) {
    return CareerPath(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      file: json['file'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file': file,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Helper getters for UI compatibility
  String? get imageUrl => file;
  List<String> get skills => [];
  List<String> get courses => [];
} 