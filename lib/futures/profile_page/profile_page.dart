import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_project/futures/edit_profile_page/edit_profile_page.dart';
import 'package:mobile_project/futures/view_wallet_balance/view_wallet_balance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  final String phone;

  const ProfilePage({super.key, required this.phone});

  Future<Map<String, dynamic>?> getProfileData() async {
    return await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('username', phone)
        .maybeSingle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.only(
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
                              border: Border.all(color: Colors.white, width: 4),
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
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                size: 70,
                                color: theme.colorScheme.primary,
                              ),
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
                                    const SizedBox(width: 48), // Space to maintain alignment
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
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Info Tiles ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.phone_android_rounded,
                          label: "เบอร์โทรศัพท์",
                          value: data['username'] ?? phone,
                        ),
                        _buildInfoTile(
                          icon: Icons.cake_rounded,
                          label: "วันเกิด",
                          value: data['birthday'] ?? "ไม่ระบุ",
                        ),
                        _buildInfoTile(
                          icon: Icons.wc_rounded,
                          label: "เพศ",
                          value: data['gender'] ?? "ไม่ระบุ",
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
                        _buildPrimaryButton(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: "กระเป๋าเงินของฉัน",
                          color: Colors.orange[700]!,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WalletBalancePage(phone: phone),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPrimaryButton(
                          context: context,
                          icon: Icons.edit_rounded,
                          label: "แก้ไขข้อมูลส่วนตัว",
                          color: theme.colorScheme.primary,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(phone: phone),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted)
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
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

  Widget _buildPrimaryButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
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
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent),
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
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
