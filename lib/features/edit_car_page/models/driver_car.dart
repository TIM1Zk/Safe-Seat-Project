import 'dart:convert';

class DriverCar {
  final String carBrand;
  final String carModel;
  final String carColor;
  final String carPlate;
  final String carImagePath;

  DriverCar({
    required this.carBrand,
    required this.carModel,
    required this.carColor,
    required this.carPlate,
    required this.carImagePath,
  });

  String? get frontImagePath {
    try {
      if (carImagePath.startsWith('{')) {
        final Map<String, dynamic> decoded = jsonDecode(carImagePath);
        if (decoded.containsKey('front') && decoded['front'] != null) {
          return decoded['front'].toString();
        }
      }
    } catch (_) {}
    return carImagePath.isNotEmpty && !carImagePath.startsWith('{') ? carImagePath : null;
  }

  String? get sideImagePath {
    try {
      if (carImagePath.startsWith('{')) {
        final Map<String, dynamic> decoded = jsonDecode(carImagePath);
        if (decoded.containsKey('side') && decoded['side'] != null) {
          return decoded['side'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  factory DriverCar.fromJson(Map<String, dynamic> json) {
    return DriverCar(
      carBrand: json['carbrand'] ?? '',
      carModel: json['carmodel'] ?? '',
      carColor: json['carcolor'] ?? '',
      carPlate: json['carplate'] ?? '',
      carImagePath: json['carimagepath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbrand': carBrand,
      'carmodel': carModel,
      'carcolor': carColor,
      'carplate': carPlate,
      'carimagepath': carImagePath,
    };
  }
}
