import 'dart:convert';

class Memo {
  String id;
  User user;
  String doctor;
  int color;
  DateTime updatedAt;

  Memo({
    required this.id,
    required this.user,
    required this.doctor,
    required this.color,
    required this.updatedAt,
  });

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['_id'],
      user: User.fromJson(json['user']),
      doctor: json['doctor'],
      color: json['color'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class User {
  String id;
  String usernick;

  User({
    required this.id,
    required this.usernick,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      usernick: json['usernick'],
    );
  }
}