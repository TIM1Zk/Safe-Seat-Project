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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light background
      appBar: AppBar(
        title: const Text("เข้าสู่ระบบ"),
        elevation: 0, // Flat app bar
      ),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- Header Section ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Safe Seat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "ยินดีต้อนรับกลับมา",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Form Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: formKey,
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: phonenumbercontroller,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: "หมายเลขโทรศัพท์",
                                  prefixIcon: const Icon(Icons.phone_iphone),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? "กรุณาระบุหมายเลขโทรศัพท์"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordcontroller,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "รหัสผ่าน",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? "กรุณาระบุรหัสผ่าน" : null,
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _handleLogin,
                                child: const Text("เข้าสู่ระบบ"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Footer Section ---
                  TextButton(
                    onPressed: () {}, // Add registration logic if needed
                    child: Text(
                      "ยังไม่มีบัญชีผู้ใช้? ลงทะเบียนที่นี่",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
