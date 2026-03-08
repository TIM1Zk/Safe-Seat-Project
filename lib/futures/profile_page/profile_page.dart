import 'package:flutter/material.dart';
import 'package:mobile_project/futures/edit_profile_page/edit_profile_page.dart';
import 'package:mobile_project/futures/view_wallet_balance/view_wallet_balance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  final String phone;

  const ProfilePage({super.key, required this.phone});

  // ฟังก์ชันดึงข้อมูลจาก Supabase
  Future<Map<String, dynamic>> getProfileData() async {
    return await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('username', phone)
        .single();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ข้อมูลส่วนตัว",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getProfileData(),
        builder: (context, snapshot) {
          // 1. ระหว่างรอข้อมูล (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. ถ้าเกิดข้อผิดพลาด (Error)
          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          }

          // 3. เมื่อได้ข้อมูลมาแล้ว (Success)
          final data = snapshot.data!;

          return SingleChildScrollView(
            // ใช้เพื่อให้หน้าจอเลื่อนได้ถ้าข้อมูลเยอะ
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ส่วนรูปโปรไฟล์ ---
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                // --- แสดงข้อมูล: ชื่อ-นามสกุล ---
                const Text(
                  "ชื่อ-นามสกุล:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${data['first_name']} ${data['last_name']}",
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(), // เส้นคั่นบรรทัด
                const SizedBox(height: 15),

                // --- แสดงข้อมูล: วันเกิด ---
                const Text(
                  "วันเกิด:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data['birthday'] ?? "ไม่ระบุ",
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(),
                const SizedBox(height: 15),

                // --- แสดงข้อมูล: เบอร์โทรศัพท์ ---
                const Text(
                  "เบอร์โทรศัพท์:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data['username'].toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(),
                const SizedBox(height: 15),

                // --- แสดงข้อมูล: เพศ ---
                const Text(
                  "เพศ:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data['gender'] ?? "ไม่ระบุ",
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(),

                const SizedBox(height: 40),

                // --- ส่วนปุ่มกระเป๋าเงิน ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletBalancePage(phone: phone),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "กระเป๋าเงินของฉัน",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // สีส้มสำหรับ Wallet
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- ปุ่มแก้ไขข้อมูล ---
                SizedBox(
                  width: double.infinity, // ทำให้ปุ่มกว้างเต็มหน้าจอ
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            phone: phone,
                          ), // เรียกชื่อ Class ตรงๆ เลย
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "แก้ไขข้อมูลส่วนตัว",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15), // เว้นระยะห่างระหว่างปุ่มนิดหน่อย
                // --- ปุ่มออกจากระบบ ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    // ใช้ OutlinedButton เพื่อให้ดูไม่ทึบเท่าปุ่มแก้ไข
                    onPressed: () async {
                      // 1. สั่ง Logout จากระบบ Supabase
                      await Supabase.instance.client.auth.signOut();

                      // 2. เด้งกลับไปที่หน้า Login และล้างประวัติหน้าจอทั้งหมด
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "ออกจากระบบ",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red), // เส้นขอบสีแดง
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
