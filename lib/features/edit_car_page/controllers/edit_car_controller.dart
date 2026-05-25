import 'package:flutter/material.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:mobile_project/features/edit_car_page/models/driver_car.dart';

class EditCarController extends ChangeNotifier {
  DriverCar? driverCar;
  bool isLoading = true;
  String? errorMessage;

  final String username;

  EditCarController({required this.username}) {
    fetchCarDetails();
  }

  /// ดึงข้อมูลรถยนต์ปัจจุบันของผู้ใช้
  Future<void> fetchCarDetails() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/$username');
      if (response.statusCode == 200 && response.data != null) {
        final carJson = response.data['drivercar'];
        if (carJson != null) {
          driverCar = DriverCar.fromJson(carJson);
        } else {
          errorMessage = "ไม่พบข้อมูลรถยนต์ของคนขับ";
        }
      } else {
        errorMessage = "ไม่พบข้อมูลโปรไฟล์คนขับ";
      }
    } catch (e) {
      errorMessage = "ดึงข้อมูลรถยนต์ไม่สำเร็จ: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// อัปเดตข้อมูลรถยนต์ไปยังระบบหลังบ้าน
  Future<bool> updateCarDetails({
    required String carBrand,
    required String carModel,
    required String carColor,
    required String carPlate,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedData = {
        'drivercar': {
          'carbrand': carBrand,
          'carmodel': carModel,
          'carcolor': carColor,
          'carplate': carPlate,
        }
      };

      final response = await ApiService.put('/users/$username', data: updatedData);

      if (response.statusCode == 200 && response.data != null) {
        final carJson = response.data['drivercar'];
        if (carJson != null) {
          driverCar = DriverCar.fromJson(carJson);
        }
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "แก้ไขข้อมูลรถยนต์ไม่สำเร็จ";
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "แก้ไขข้อมูลรถยนต์ไม่สำเร็จ: $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
