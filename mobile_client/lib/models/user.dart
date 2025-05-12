class User {
  final String id;
  final String username;
  final bool isAdmin;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.isAdmin,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'isAdmin': isAdmin,
      'token': token,
    };
  }
} 