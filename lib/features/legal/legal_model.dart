class LegalModel {
  final String title;
  final String slug;
  final String id;

  LegalModel({
    required this.title,
    required this.slug,
    required this.id,
  });

  factory LegalModel.fromJson(Map<String, dynamic> json) {
    return LegalModel(
      title: json['title']?.toString() ?? 'Unnamed Document',
      slug: json['slug']?.toString() ?? '',
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    );
  }
}

class LegalDetailModel {
  final String title;
  final String content;
  final String updatedAt;

  LegalDetailModel({
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory LegalDetailModel.fromJson(Map<String, dynamic> json) {
    dynamic payload = json['data'] ?? json;
    
    // If the data is returned as a list, take the first item
    if (payload is List && payload.isNotEmpty) {
      payload = payload.first;
    }
    
    // Ensure we have a map to work with
    final Map<String, dynamic> data = payload is Map ? Map<String, dynamic>.from(payload) : {};
    
    return LegalDetailModel(
      title: data['title']?.toString() ?? 'Legal Document',
      content: data['content']?.toString() ?? '',
      updatedAt: data['updatedAt']?.toString() ?? data['updated_at']?.toString() ?? '',
    );
  }
}
