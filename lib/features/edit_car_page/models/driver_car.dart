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
