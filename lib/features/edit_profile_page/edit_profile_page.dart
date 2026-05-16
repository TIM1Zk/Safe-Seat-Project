import 'package:flutter/material.dart';
import 'package:mobile_project/features/profile_page/profile_page.dart';
import 'package:mobile_project/features/edit_profile_page/controllers/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final String phoneno;
  const EditProfilePage({super.key, required this.username, required this.phoneno});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['ชาย', 'หญิง', 'LGBTQ+', 'ไม่ระบุ'];

  late EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(phone: widget.username);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (_controller.userProfile != null && _firstNameController.text.isEmpty) {
      // Initialize text fields only once when data is loaded
      _firstNameController.text = _controller.userProfile!.firstName;
      _lastNameController.text = _controller.userProfile!.lastName;
      _birthdayController.text = _controller.userProfile!.birthday;
      if (_genderOptions.contains(_controller.userProfile!.gender)) {
        _selectedGender = _controller.userProfile!.gender;
      }
    }
    
    if (_controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage!)),
      );
      // clear error to prevent multiple snackbars
      _controller.errorMessage = null; 
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthday: _birthdayController.text,
      gender: _selectedGender ?? '',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อยแล้ว!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            username: widget.username,
            phoneno: widget.phoneno,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลส่วนตัว"),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _firstNameController,
                            label: "ชื่อ",
                            icon: Icons.person_outline_rounded,
                            validator: (value) => value!.isEmpty ? "กรุณาระบุชื่อ" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _lastNameController,
                            label: "นามสกุล",
                            icon: Icons.person_outline_rounded,
                            validator: (value) => value!.isEmpty ? "กรุณาระบุนามสกุล" : null,
                          ),
                          const SizedBox(height: 15),
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
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: _buildInputDecoration("เพศ", Icons.wc_outlined, null),
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
                            validator: (value) => value == null ? "กรุณาเลือกเพศ" : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _controller.isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF7CE5FF)),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF7CE5FF), width: 2),
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
