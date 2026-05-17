class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final UserRole role;
  final double rating;
  final int completedJobs;
  final int totalReviews;
  final List<String> skills;
  final bool isVerified;
  final double walletBalance;
  final double latitude;
  final double longitude;
  final DateTime joinedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    required this.role,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.totalReviews = 0,
    this.skills = const [],
    this.isVerified = false,
    this.walletBalance = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.joinedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    double? rating,
    int? completedJobs,
    int? totalReviews,
    List<String>? skills,
    bool? isVerified,
    double? walletBalance,
    double? latitude,
    double? longitude,
    DateTime? joinedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      totalReviews: totalReviews ?? this.totalReviews,
      skills: skills ?? this.skills,
      isVerified: isVerified ?? this.isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

enum UserRole {
  worker,
  poster,
  both,
}
