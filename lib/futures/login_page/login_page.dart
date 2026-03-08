import 'package:flutter/material.dart';
import 'package:mobile_project/futures/profile_page/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController phonenumbercontroller;
  late final TextEditingController passwordcontroller;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    phonenumbercontroller = TextEditingController();
    passwordcontroller = TextEditingController();
  }

  @override
  void dispose() {
    phonenumbercontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isloading = true);

    try {
      // 1. Check if user exists with this phone and password
      final data = await Supabase.instance.client
          .from('user')
          .select()
          .eq(
            'username',
            phonenumbercontroller.text.trim(),
          ) // แก้จาก phone เป็น username
          .eq('password', passwordcontroller.text.trim())
          .maybeSingle();

      // ภายในฟังก์ชัน _handleLogin
      if (data != null) {
        if (mounted) {
          // นำทางไปหน้า Profile พร้อมส่งเบอร์โทรไปด้วย
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(phone: phonenumbercontroller.text.trim()),
            ),
          );
        }
      } else {
        throw 'หมายเลขโทรศัพท์หรือรหัสผ่านไม่ถูกต้อง';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เข้าสู่ระบบ", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: phonenumbercontroller,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "หมายเลขโทรศัพท์",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "กรุณาระบุหมายเลขโทรศัพท์" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordcontroller,
                        obscureText: true, // Hide password characters
                        decoration: InputDecoration(
                          labelText: "รหัสผ่าน",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "กรุณาระบุรหัสผ่าน" : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleLogin,
                        child: const Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
