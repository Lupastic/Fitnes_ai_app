// lib/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}', // Более гибкая обработка имени
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}