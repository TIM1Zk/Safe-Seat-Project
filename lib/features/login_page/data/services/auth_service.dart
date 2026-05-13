import 'package:mobile_project/core/network/api_service.dart';
import '../models/user_dto.dart';

class AuthService {
  Future<UserDto?> login(String username, String password) async {
    try {
      final response = await ApiService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return UserDto.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
