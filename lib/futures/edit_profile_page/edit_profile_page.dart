import 'package:flutter/material.dart';
import 'package:mobile_project/futures/profile_page/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final String phone;
  const EditProfilePage({super.key, required this.phone});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String? _selectedGender; // สำหรับเก็บค่าเพศที่เลือก
  bool _isLoading = true;

  // รายการตัวเลือกเพศ
  final List<String> _genderOptions = ['ชาย', 'หญิง', 'LGBTQ+', 'ไม่ระบุ'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('username', widget.phone)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _birthdayController.text = data['birthday'] ?? '';

          // ตรวจสอบว่าค่าจาก DB ตรงกับตัวเลือกที่มีไหม
          if (_genderOptions.contains(data['gender'])) {
            _selectedGender = data['gender'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("โหลดข้อมูลล้มเหลา: $e")));
      }
    }
  }

  // ฟังก์ชันเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'birthday': _birthdayController.text,
            'gender': _selectedGender,
          })
          .eq('username', widget.phone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(phone: widget.phone),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("บันทึกล้มเหลว: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลส่วนตัว"),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ข้อมูลเบื้องต้น",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _firstNameController,
                              label: "ชื่อ",
                              icon: Icons.person_outline_rounded,
                              validator: (value) =>
                                  value!.isEmpty ? "กรุณาระบุชื่อ" : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: _lastNameController,
                              label: "นามสกุล",
                              icon: Icons.person_outline_rounded,
                              validator: (value) =>
                                  value!.isEmpty ? "กรุณาระบุนามสกุล" : null,
                            ),
                            const SizedBox(height: 15),
                            // วันเกิดแบบใช้ Date Picker
                            TextFormField(
                              controller: _birthdayController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: _buildInputDecoration(
                                "วันเกิด",
                                Icons.cake_outlined,
                                "กดเพื่อเลือกวันที่",
                              ),
                            ),
                            const SizedBox(height: 15),

                            // --- ส่วนของ Dropdown เพศ ---
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _buildInputDecoration(
                                "เพศ",
                                Icons.wc_outlined,
                                null,
                              ),
                              items: _genderOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              validator: (value) =>
                                  value == null ? "กรุณาเลือกเพศ" : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ปุ่มบันทึกสไตล์เดียวกับหน้า Profile
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "บันทึกข้อมูล",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    String? hint,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, icon, null),
      validator: validator,
    );
  }
}
