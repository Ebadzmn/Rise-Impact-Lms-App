class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String phone;
  final String location;
  final String gender;
  final String dateOfBirth;
  final int totalPoints;
  final int streakCurrent;
  final int streakLongest;
  final bool onboardingCompleted;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.phone,
    required this.location,
    required this.gender,
    required this.dateOfBirth,
    required this.totalPoints,
    required this.streakCurrent,
    required this.streakLongest,
    required this.onboardingCompleted,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Handling nested "data" if present
    final data = json['data'] ?? json;
    final streak = data['streak'] ?? {};
    
    return ProfileModel(
      id: (data['_id'] ?? data['id'])?.toString() ?? '',
      name: data['name']?.toString() ?? 'User',
      email: data['email']?.toString() ?? '',
      profilePicture: data['profilePicture']?.toString() ?? '',
      phone: data['phone']?.toString() ?? 'Not provided',
      location: data['location']?.toString() ?? 'Unknown',
      gender: data['gender']?.toString() ?? 'Other',
      dateOfBirth: data['dateOfBirth']?.toString() ?? '',
      totalPoints: int.tryParse(data['totalPoints']?.toString() ?? '0') ?? 0,
      streakCurrent: int.tryParse(streak['current']?.toString() ?? '0') ?? 0,
      streakLongest: int.tryParse(streak['longest']?.toString() ?? '0') ?? 0,
      onboardingCompleted: (data['onboardingCompleted'] == true ||
          data['onboardingCompleted']?.toString().toLowerCase() == 'true'),
    );
  }
}

class BadgeResponseModel {
  final List<BadgeModel> badges;
  final int totalBadges;
  final int earnedBadges;

  BadgeResponseModel({
    required this.badges,
    required this.totalBadges,
    required this.earnedBadges,
  });

  factory BadgeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return BadgeResponseModel(
      badges: (data['badges'] as List? ?? [])
          .map((e) => BadgeModel.fromJson(e))
          .toList(),
      totalBadges: int.tryParse(data['totalBadges']?.toString() ?? '0') ?? 0,
      earnedBadges: int.tryParse(data['earnedBadges']?.toString() ?? '0') ?? 0,
    );
  }
}

class BadgeModel {
  final String name;
  final String iconName;
  final String earnedAt;

  BadgeModel({
    required this.name,
    required this.iconName,
    required this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      name: json['name']?.toString() ?? 'Unknown Badge',
      iconName: json['iconName']?.toString() ?? '',
      earnedAt: json['earnedAt']?.toString() ?? '',
    );
  }
}
