class Book {
  final String id;
  final String title;
  final String author;
  final String summary;
  final String? book;
  final dynamic uploader;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.summary,
    this.book,
    this.uploader,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      summary: json['summary'] ?? '',
      book: json['book'],
      uploader: json['uploader'],
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
      'author': author,
      'summary': summary,
      'book': book,
      'uploader': uploader,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters for UI
  String get description => summary;
  String? get downloadUrl => book;
  String? get coverImageUrl => null; // No cover image in the server model
  String get publisher => 'N/A'; // Not in the server model
  String get year => 'N/A'; // Not in the server model
  List<String> get categories => []; // Not in the server model
} 