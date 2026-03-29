class PostModel {
  final String id;
  final String title;
  final String content;
  final String? image;
  final AuthorModel author;
  final String? courseName;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.author,
    this.courseName,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      image: json['image']?.toString(),
      author: AuthorModel.fromJson(json['author'] ?? {}),
      courseName: json['course'] is Map
          ? json['course']['title']?.toString()
          : json['course']?.toString(),
      likesCount: json['likesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AuthorModel {
  final String id;
  final String name;
  final String? profilePicture;

  AuthorModel({required this.id, required this.name, this.profilePicture});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      profilePicture: json['profilePicture']?.toString(),
    );
  }
}

class PostDetailsModel {
  final String id;
  final String title;
  final String content;
  final String? image;
  final AuthorModel author;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<ReplyModel> replies;

  PostDetailsModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.author,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.createdAt,
    required this.replies,
  });

  factory PostDetailsModel.fromJson(Map<String, dynamic> json) {
    var replyList = json['replies'] as List? ?? [];
    return PostDetailsModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      image: json['image']?.toString(),
      author: AuthorModel.fromJson(json['author'] ?? {}),
      likesCount: json['likesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      replies: replyList.map((e) => ReplyModel.fromJson(e)).toList(),
    );
  }
}

class ReplyModel {
  final String id;
  final String content;
  final AuthorModel author;
  final DateTime createdAt;
  final List<ReplyModel> children;

  ReplyModel({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.children,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    var childrenList = json['children'] as List? ?? [];
    return ReplyModel(
      id: json['_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      author: AuthorModel.fromJson(json['author'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      children: childrenList.map((e) => ReplyModel.fromJson(e)).toList(),
    );
  }
}
