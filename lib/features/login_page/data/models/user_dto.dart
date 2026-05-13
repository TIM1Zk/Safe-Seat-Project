class UserDto {
  final String username;
  final String password;

  UserDto({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
