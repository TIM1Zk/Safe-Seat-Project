class UserProfile {
  final String username;
  final String firstName;
  final String lastName;
  final String birthday;
  final String gender;
  final String phoneNo;

  UserProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.gender,
    required this.phoneNo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      birthday: json['birthday']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      phoneNo: json['phoneno']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'gender': gender,
      'phoneno': phoneNo,
    };
  }
}
