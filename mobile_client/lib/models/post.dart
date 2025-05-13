import 'dart:convert';

class Post {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? cover;
  final String author;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.cover,
    required this.author,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      cover: json['cover'],
      author: json['author']['_id'] ?? json['author'],
      authorName: json['author']['username'] ?? 'Unknown',
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
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
    };
  }
} 