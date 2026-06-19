import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_project/features/login_page/login_page.dart';
import 'package:mobile_project/features/loading_screen/loading_screen.dart';
import 'package:mobile_project/core/network/api_service.dart';

// ฟังก์ชัน main ตัวนอกสุดต้องเป็น async
Future<void> main() async {
  // 1. ต้องมีบรรทัดนี้เพื่อให้เรียกใช้ Plugin ต่างๆ ได้ถูกต้อง
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: 'https://qbionbozkvlekpakvstg.supabase.co',
    anonKey: 'sb_publishable_PoMKHC0nz4vb9OmOxZsbkw_aU_K2xts',
  );

  // 3. Initialize API Service configuration
  ApiService.init(baseUrl: 'http://10.0.2.2:3000/api');

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
        fontFamily: 'Kanit',
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7CE5FF), // Frosted Blue
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7CE5FF),
          primary: const Color(0xFF7CE5FF),
          secondary: const Color(0xFF5580FF), // Secondary Blue for depth
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
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
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7CE5FF),
            foregroundColor: const Color(0xFF121212), // High contrast text
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const LoadingScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/loading': (context) => const LoadingScreen(),
      },
    );
  }
}
