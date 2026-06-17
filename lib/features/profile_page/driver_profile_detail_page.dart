import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_project/core/utils/image_utils.dart';
import 'package:mobile_project/features/edit_profile_page/edit_profile_page.dart';

class DriverProfileDetailPage extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const DriverProfileDetailPage({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    final firstName = profileData['firstname'] ?? profileData['first_name'];
    final lastName = profileData['lastname'] ?? profileData['last_name'];
    final name = firstName != null
        ? "$firstName ${lastName ?? ''}"
        : profileData['username'] ?? 'Unknown';

    // Format Join Date
    String joinDate = "ก.ค. 2025";
    if (profileData['created_at'] != null) {
      try {
        DateTime parsed = DateTime.parse(profileData['created_at']);
        // Format to Thai short month and year (CE + 543 for BE, or keep CE)
        joinDate = "${_getThaiMonth(parsed.month)} ${parsed.year + 543}";
      } catch (_) {}
    }

    // Get Car Plate
    String carPlate = "";
    if (profileData['drivercar'] != null && profileData['drivercar']['carplate'] != null) {
      carPlate = profileData['drivercar']['carplate'];
    }

    final subtitleText = "เข้าร่วมเมื่อ $joinDate" + (carPlate.isNotEmpty ? " | $carPlate" : " | รวย 1234");

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar
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
                      "โปรไฟล์ของฉัน",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              username: profileData['username'] ?? '',
                              phoneno: profileData['phoneno'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C1C1E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
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

                // 2. Profile Info Card
                Container(
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
                        backgroundImage: profileData['regisimagepath'] != null
                            ? NetworkImage(ImageUtils.getProfileImageUrl(profileData['regisimagepath']))
                            : null,
                        child: profileData['regisimagepath'] == null
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
                            Text(
                              subtitleText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Rating Summary Card (การให้คะแนน 56 ครั้งล่าสุด)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "การให้คะแนน 56 ครั้งล่าสุด",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Left Rating Score
                          Column(
                            children: const [
                              Text(
                                "5.00",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "คะแนนคนขับ",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          // Right Progress Bars
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingRow(5, 56, 1.0),
                                const SizedBox(height: 4),
                                _buildRatingRow(4, 0, 0.0),
                                const SizedBox(height: 4),
                                _buildRatingRow(3, 0, 0.0),
                                const SizedBox(height: 4),
                                _buildRatingRow(2, 0, 0.0),
                                const SizedBox(height: 4),
                                _buildRatingRow(1, 0, 0.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. รีวิวที่ได้รับ (Reviews) Title
                const Text(
                  "รีวิวที่ได้รับ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Empty State / Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.visibility_outlined, size: 20, color: Colors.black54),
                          SizedBox(width: 8),
                          Text(
                            "มีเพียงคุณเท่านั้นที่เห็นหน้านี้",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "ผู้โดยสารแนะนำให้คุณปรับปรุงในเรื่องต่อไปนี้",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.search_rounded,
                        size: 56,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "ยังไม่มีรายงาน",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "เมื่อให้บริการโดยสารมากขึ้น คุณจะได้รับข้อเสนอแนะเกี่ยวกับการปรับปรุงบริการของตัวเอง",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(int starCount, int reviewCount, double percentage) {
    return Row(
      children: [
        Text(
          "$starCount",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFD1D1D6),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text(
            "$reviewCount",
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _getThaiMonth(int month) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
