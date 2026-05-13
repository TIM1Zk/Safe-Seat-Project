class UserProfile {
  final String username;
  final String firstName;
  final String lastName;
  final String birthday;
  final String gender;

  UserProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthday: json['birthday'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'gender': gender,
    };
  }
}
