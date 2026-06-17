class UserProfile {
  final String username;
  final String firstName;
  final String lastName;
  final String birthday;
  final String gender;
  final String phoneNo;
  final String email;
  final String carBrand;
  final String carModel;
  final String carPlate;

  UserProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.gender,
    required this.phoneNo,
    required this.email,
    required this.carBrand,
    required this.carModel,
    required this.carPlate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username']?.toString() ?? '',
      firstName: json['firstname']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName: json['lastname']?.toString() ?? json['last_name']?.toString() ?? '',
      birthday: json['birthday']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      phoneNo: json['phoneno']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      carBrand: json['drivercar']?['carbrand']?.toString() ?? '',
      carModel: json['drivercar']?['carmodel']?.toString() ?? '',
      carPlate: json['drivercar']?['carplate']?.toString() ?? '',
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
      'email': email,
      'car_brand': carBrand,
      'car_model': carModel,
      'car_plate': carPlate,
    };
  }
}
