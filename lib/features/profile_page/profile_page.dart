import 'package:mobile_project/core/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_project/features/edit_profile_page/edit_profile_page.dart';
import 'package:mobile_project/features/view_wallet_balance/view_wallet_balance.dart';
import 'package:mobile_project/features/searchbuddy_page/searchbuddy_page.dart';
import 'package:mobile_project/features/Listdriverreport_page/Listdriverreport_page.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:mobile_project/core/utils/session_manager.dart';
import 'package:mobile_project/features/edit_car_page/edit_car_page.dart';
import 'package:mobile_project/features/map_page/map_page.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String phoneno;
  const ProfilePage({super.key, required this.username, required this.phoneno});

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final response = await ApiService.get('/users/$username');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>?>(
          future: getProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("ไม่พบข้อมูลโปรไฟล์"));
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // --- Header Section ---
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Background
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7CE5FF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                      ),
                      // 2. Profile Image
                      Positioned(
                        bottom: -50,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF1E1E1E),
                            backgroundImage: NetworkImage(ImageUtils.getProfileImageUrl(data['regisimagepath'])),
                            onBackgroundImageError: (_, __) {},
                            child: ImageUtils.getProfileImageUrl(data['regisimagepath']).contains('pravatar')
                                ? const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Color(0xFF7CE5FF),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      // 3. Back Button & Title (วางไว้บนสุดเสมอ)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 48,
                                ), // Space to maintain alignment
                                const Text(
                                  "ข้อมูลส่วนตัว",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),
                  Text(
                    "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Info Tiles ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.person_2_rounded,
                          label: "ชื่อผู้ใช้",
                          value: (data['username'] ?? username).toString(),
                        ),
                        _buildInfoTile(
                          icon: Icons.phone_android_rounded,
                          label: "เบอร์โทรศัพท์",
                          value: (data['phoneno'] ?? phoneno).toString(),
                        ),
                        _buildInfoTile(
                          icon: Icons.wc_rounded,
                          label: "เพศ",
                          value: data['gender'] == 1 || data['gender'] == '1'
                              ? 'ชาย'
                              : data['gender'] == 2 || data['gender'] == '2'
                              ? 'ผู้หญิง'
                              : (data['gender'] ?? "ไม่ระบุ").toString(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Car Info Card ---
                  if (data['drivercar'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 8),
                            child: Text(
                              "ข้อมูลรถยนต์",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7CE5FF),
                              ),
                            ),
                          ),
                          _buildInfoTile(
                            icon: Icons.directions_car_filled_rounded,
                            label: "ยี่ห้อและรุ่นรถยนต์",
                            value: "${data['drivercar']['carbrand'] ?? ''} ${data['drivercar']['carmodel'] ?? ''}",
                          ),
                          _buildInfoTile(
                            icon: Icons.color_lens_rounded,
                            label: "สีรถยนต์",
                            value: (data['drivercar']['carcolor'] ?? '').toString(),
                          ),
                          _buildInfoTile(
                            icon: Icons.badge_rounded,
                            label: "ป้ายทะเบียนรถยนต์",
                            value: (data['drivercar']['carplate'] ?? '').toString(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // --- Buttons ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: "กระเป๋าเงินของฉัน",
                          isGradient: true,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WalletBalancePage(username: username),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.person_search_rounded,
                          label: "ค้นหาเพื่อนร่วมทาง (Buddy)",
                          isGradient: true,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchbuddyPage(currentUsername: username),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.map_rounded,
                          label: "แผนที่ของฉัน (Mapbox)",
                          isGradient: true,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.report_problem_rounded,
                          label: "รายงานปัญหาของฉัน",
                          isGradient: true,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDriverReportPage(username: username),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.edit_rounded,
                          label: "แก้ไขข้อมูลส่วนตัว",
                          isGradient: false,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                username: username,
                                phoneno: phoneno,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPremiumButton(
                          context: context,
                          icon: Icons.directions_car_filled_rounded,
                          label: "แก้ไขข้อมูลรถยนต์",
                          isGradient: false,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCarPage(
                                username: username,
                                phoneno: phoneno,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await SessionManager.clearSession();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "ออกจากระบบ",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isGradient,
    required VoidCallback onPressed,
  }) {
    const accentColor = Color(0xFF7CE5FF);
    const secondaryColor = Color(0xFF5580FF);

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isGradient
            ? const LinearGradient(
                colors: [accentColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: !isGradient
            ? Border.all(color: accentColor.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isGradient ? const Color(0xFF0D0D0D) : accentColor,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isGradient ? const Color(0xFF0D0D0D) : accentColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7CE5FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7CE5FF)),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
