class UserDto {
  final String username;
  final String phoneno;
  final String password;

  UserDto({required this.username, required this.phoneno, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'phoneno': phoneno,
      'password': password,
    };
  }

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['username'] ?? '',
      phoneno: json['phoneno'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
