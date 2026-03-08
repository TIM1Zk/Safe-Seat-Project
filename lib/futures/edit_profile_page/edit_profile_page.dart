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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  bool _isLoading = true;

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
          .single();

      setState(() {
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _birthdayController.text = data['birthday'] ?? '';
        _genderController.text = data['gender'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("โหลดข้อมูลล้มเหลว: $e")));
    }
  }

  Future<void> _updateProfile() async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'birthday': _birthdayController.text,
            'gender': _genderController.text,
          })
          .eq('username', widget.phone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว!")),
        );

        // กลับไปหน้า Profile โดยส่งเบอร์โทรกลับไปด้วย
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfilePage(phone: widget.phone), // ใส่ widget.phone ให้ถูกต้อง
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("บันทึกล้มเหลว: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แก้ไขข้อมูลส่วนตัว",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ชื่อ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(controller: _firstNameController),
                  const SizedBox(height: 20),
                  const Text(
                    "นามสกุล",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(controller: _lastNameController),
                  const SizedBox(height: 20),
                  const Text(
                    "วันเกิด",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _birthdayController,
                    decoration: const InputDecoration(
                      hintText: "เช่น 01/01/1990",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "เพศ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(controller: _genderController),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "บันทึกข้อมูล",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
