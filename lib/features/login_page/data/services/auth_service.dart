import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_dto.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserDto?> login(String username, String password) async {
    try {
      final data = await _client
          .from('user')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();
      
      if (data != null) {
        return UserDto.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
