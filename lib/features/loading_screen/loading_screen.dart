import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_project/core/utils/session_manager.dart';
import 'package:mobile_project/features/map_page/map_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // แสดงหน้าจอโหลดเดอร์อย่างน้อย 3 วินาทีเพื่อให้ดูพรีเมียม
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // ตรวจสอบว่าเคยเข้าสู่ระบบไว้หรือไม่
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (isLoggedIn) {
      final username = await SessionManager.getUsername();
      final phoneno = await SessionManager.getPhoneNo();
      
      if (mounted && username != null && phoneno != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MapPage(),
          ),
        );
        return;
      }
    }

    // หากยังไม่เคยเข้าสู่ระบบ ให้นำไปหน้า Login
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF7CE5FF); // Frosted Blue

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D), // Black
              Color(0xFF1E1E1E), // Deep Charcoal
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon (Driver Themed)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.drive_eta_rounded,
                size: 90,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 35),
            // App Title
            const Text(
              'Safe Seat',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
                shadows: [
                  Shadow(
                    blurRadius: 15.0,
                    color: Colors.black45,
                    offset: Offset(3.0, 3.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'DRIVER EDITION',
              style: TextStyle(
                fontSize: 16,
                color: accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 80),
            // Loading Indicator (Frosted Blue)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              strokeWidth: 3.5,
            ),
          ],
        ),
      ),
    );
  }
}
