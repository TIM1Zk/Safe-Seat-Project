import 'package:mobile_project/core/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_project/features/Listdriverreport_page/Listdriverreport_page.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:mobile_project/core/utils/session_manager.dart';
import 'package:mobile_project/features/profile_page/driver_profile_detail_page.dart';
import 'package:mobile_project/features/service_summary/service_summary_page.dart';

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
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<Map<String, dynamic>?>(
          future: getProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  "ไม่พบข้อมูลโปรไฟล์",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              );
            }

            final data = snapshot.data!;
            final firstName = data['firstname'] ?? data['first_name'];
            final lastName = data['lastname'] ?? data['last_name'];
            final name = firstName != null 
                ? "$firstName ${lastName ?? ''}"
                : data['username'] ?? username;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Bar (Back Arrow and Title)
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                            size: 26,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    const SizedBox(height: 24),

                    // 2. Profile Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriverProfileDetailPage(profileData: data),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFD1D1D6),
                              backgroundImage: data['regisimagepath'] != null
                                  ? NetworkImage(ImageUtils.getProfileImageUrl(data['regisimagepath']))
                                  : null,
                              child: data['regisimagepath'] == null
                                  ? const Icon(Icons.person, size: 36, color: Color(0xFF5856D6))
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: const [
                                      Icon(Icons.star, color: Colors.amber, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black38,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceSummaryPage(username: username),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "ภาพรวม",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              "รายสัปดาห์",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: const [
                                    Text(
                                      "100.0%",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "อัตราการรับ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: const [
                                    Text(
                                      "100.0%",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "อัตราการยกเลิก",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. บัญชีของฉัน (My Account)
                    const Text(
                      "บัญชีของฉัน",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _buildGridItem(Icons.chat_bubble_outline, "กล่องข้อความ", () {}),
                        _buildGridItem(Icons.calendar_month_outlined, "ตารางรายการ", () {}),
                        _buildGridItem(Icons.lightbulb_outline, "สิ่งที่น่าสนใจ", () {}),
                        _buildGridItem(Icons.error_outline, "ศูนย์ความช่วยเหลือ", () {}),
                        _buildGridItem(Icons.chat_bubble_outline, "ประวัติการรายงาน", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDriverReportPage(username: username),
                            ),
                          );
                        }),
                        _buildGridItem(Icons.chat_bubble_outline, "อื่นๆ", () {}),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 5. ศึกษาวิธีการใช้งาน (Learn to Use)
                    const Text(
                      "ศึกษาวิธีการใช้งาน",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Combined Insights and Academy/Blog Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Top section (Insights)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "เช็กข้อมูลเชิงลึกเกี่ยวกับรูปแบบการขับขี่ของคุณ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          minimumSize: Size.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: const Text("ดูรายงาน", style: TextStyle(fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 64,
                                  color: Color(0xFF007AFF),
                                ),
                              ],
                            ),
                          ),
                          // Bottom section (Academy & Blog)
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF707074),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.school, color: Colors.white, size: 28),
                                  title: const Text(
                                    "Academy",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: const Text(
                                    "แหล่งรวมบทเรียนต่างๆ",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                                  onTap: () {},
                                ),
                                const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
                                ListTile(
                                  leading: const Icon(Icons.article_outlined, color: Colors.white, size: 28),
                                  title: const Text(
                                    "Driver Blog",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: const Text(
                                    "บทความที่เป็นประโยชน์สำหรับพาร์ทเนอร์",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button (Bottom)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
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
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "ออกจากระบบ",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
