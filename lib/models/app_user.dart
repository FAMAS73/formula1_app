class AppUser {
  final String id;
  final String email;
  final List<String> followedTeams;
  final List<String> followedDrivers;
    final String role; // Added to handle user role


  AppUser({
    required this.id,
    required this.email,
    required this.followedTeams,
    required this.followedDrivers,
    this.role = 'user',

  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      email: data['email'] as String? ?? '',
      followedTeams: List<String>.from(data['followedTeams'] ?? []),
      followedDrivers: List<String>.from(data['followedDrivers'] ?? []),
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'followedTeams': followedTeams,
      'followedDrivers': followedDrivers,
    };
  }
}
