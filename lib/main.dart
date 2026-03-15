import 'package:flutter/material.dart';
import 'package:mobile_project/futures/login_page/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ฟังก์ชัน main ตัวนอกสุดต้องเป็น async
Future<void> main() async {
  // 1. ต้องมีบรรทัดนี้เพื่อให้เรียกใช้ Plugin ต่างๆ ได้ถูกต้อง
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase ให้เสร็จก่อนเริ่มรันแอป
  await Supabase.initialize(
    url: 'https://msqlhwflchydxibzfrxq.supabase.co',
    anonKey: 'sb_publishable_Ar5FwALxoPXnW970x3KKqA_RpzxHJ0F',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Seat Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}
