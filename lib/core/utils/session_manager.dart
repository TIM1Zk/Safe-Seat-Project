import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUsername = 'username';
  static const String _keyPhoneNo = 'phoneno';

  /// บันทึกข้อมูลเซสชันผู้ใช้ (username และ phoneno) เมื่อเข้าสู่ระบบสำเร็จ
  static Future<void> saveSession(String username, String phoneNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPhoneNo, phoneNo);
  }

  /// ดึงข้อมูล username ที่บันทึกไว้
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// ดึงข้อมูลเบอร์โทรศัพท์ที่บันทึกไว้
  static Future<String?> getPhoneNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNo);
  }

  /// ตรวจสอบว่าผู้ใช้เคยเข้าสู่ระบบค้างไว้หรือไม่
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    return username != null && username.isNotEmpty;
  }

  /// ลบข้อมูลเซสชันทั้งหมดเมื่อผู้ใช้กดออกจากระบบ
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPhoneNo);
  }
}
