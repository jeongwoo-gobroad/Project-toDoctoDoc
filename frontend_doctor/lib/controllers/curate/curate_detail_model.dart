

class CurateDetailResponse {
  final bool error;
  final String result;
  final CurateDetail content;

  CurateDetailResponse({
    required this.error,
    required this.result,
    required this.content,
  });

  factory CurateDetailResponse.fromJson(Map<String, dynamic> json) {
    return CurateDetailResponse(
      error: json['error'] ?? false,
      result: json['result'] ?? '',
      content: CurateDetail.fromJson(json['content']),
    );
  }
}

class CurateDetail {
  final String id;
  final List<Post> posts;
  final List<AiChat> aiChats;
  final List<dynamic> comments;
  final String date;
  final String createdAt;
  final String user;

  CurateDetail({
    required this.id,
    required this.posts,
    required this.aiChats,
    required this.comments,
    required this.date,
    required this.createdAt,
    required this.user,
  });

  factory CurateDetail.fromJson(Map<String, dynamic> json) {
    return CurateDetail(
      id: json['_id'] ?? '',
      posts: (json['posts'] as List).map((post) => Post.fromJson(post)).toList(),
      aiChats: (json['ai_chats'] as List).map((chat) => AiChat.fromJson(chat)).toList(),
      comments: (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList(),
      date: (json['date']),
      createdAt: (json['createdAt']),
      user: json['user'] ?? '',
    );
  }
}

class Post {
  final String id;
  final String title;
  final String details;
  final String additionalMaterial;
  final String createdAt;
  final String editedAt;
  final String tag;
  final String user;

  Post({
    required this.id,
    required this.title,
    required this.details,
    required this.additionalMaterial,
    required this.createdAt,
    required this.editedAt,
    required this.tag,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      additionalMaterial: json['additional_material'] ?? '',
      createdAt: (json['createdAt']),
      editedAt: (json['editedAt']),
      tag: json['tag'] ?? '',
      user: json['user'] ?? '',
    );
  }
}

class AiChat {
  final String id;
  final List<ChatMessage> response;
  final String user;
  final String chatCreatedAt;
  final String chatEditedAt;
  final String recentMessage;
  final String title;

  AiChat({
    required this.id,
    required this.response,
    required this.user,
    required this.chatCreatedAt,
    required this.chatEditedAt,
    required this.recentMessage,
    required this.title,
  });

  factory AiChat.fromJson(Map<String, dynamic> json) {
    return AiChat(
      id: json['_id'] ?? '',
      response: (json['response'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
      user: json['user'] ?? '',
      chatCreatedAt: (json['chatCreatedAt']),
      chatEditedAt: (json['chatEditedAt']),
      recentMessage: json['recentMessage'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
class Comment {
  final String id;
  final Doctor doctor;
  final String content;
  final String date;
  final String originalId;

  Comment({
    required this.id,
    required this.doctor,
    required this.content,
    required this.date,
    required this.originalId,
  });

  
  factory Comment.fromJson(Map<String, dynamic> json) {
  return Comment(
    id: json['_id'] ?? '',
    doctor: (json['doctor'] != null && json['doctor'] is Map<String, dynamic>)
        ? Doctor.fromJson(json['doctor'])
        : Doctor(
            id: '',
            name: '',
            email: '',
            address: Address(
              postcode: '',
              address: '',
              detailAddress: '',
              extraAddress: '',
              longitude: 0.0,
              latitude: 0.0,
            ),
            phone: '',
          ),
    content: json['content'] ?? '',
    date: json['date'] ?? '',
    originalId: json['originalID'] ?? '',
  );
}
}
class Doctor {
  final String id;
  final String name;
  final String email;
  final Address address;
  final String phone;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: Address.fromJson(json['address']),
      phone: json['phone'] ?? '',
    );
  }
}
class Address {
  final String postcode;
  final String address;
  final String detailAddress;
  final String extraAddress;
  final double longitude;
  final double latitude;

  Address({
    required this.postcode,
    required this.address,
    required this.detailAddress,
    required this.extraAddress,
    required this.longitude,
    required this.latitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postcode: json['postcode'] ?? '',
      address: json['address'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      extraAddress: json['extraAddress'] ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
    );
  }
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }
}