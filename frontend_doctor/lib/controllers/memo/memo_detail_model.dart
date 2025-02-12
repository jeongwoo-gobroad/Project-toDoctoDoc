import 'dart:convert';

class MemoDetail {
  String id;
  User user;
  String doctor;
  int color;
  String memo;
  String details;
  DateTime updatedAt;

  MemoDetail({
    required this.id,
    required this.user,
    required this.doctor,
    required this.color,
    required this.memo,
    required this.details,
    required this.updatedAt,
  });

  factory MemoDetail.fromJson(Map<String, dynamic> json) {
    return MemoDetail(
      id: json['_id'],
      user: User.fromJson(json['user']),
      doctor: json['doctor'],
      color: json['color'],
      memo: json['memo'],
      details: json['details'],
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