import 'package:flutter/material.dart';
import 'package:mobile_project/features/profile_page/profile_page.dart';
import 'package:mobile_project/features/edit_car_page/controllers/edit_car_controller.dart';

class EditCarPage extends StatefulWidget {
  final String username;
  final String phoneno;
  const EditCarPage({super.key, required this.username, required this.phoneno});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  late EditCarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditCarController(username: widget.username);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (_controller.driverCar != null && _brandController.text.isEmpty) {
      // โหลดข้อมูลรถปัจจุบันมาแสดงในช่องกรอกข้อมูลครั้งแรก
      _brandController.text = _controller.driverCar!.carBrand;
      _modelController.text = _controller.driverCar!.carModel;
      _colorController.text = _controller.driverCar!.carColor;
      _plateController.text = _controller.driverCar!.carPlate;
    }

    if (_controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
      _controller.errorMessage = null; // เคลียร์ข้อความแจ้งเตือนความผิดพลาด
    }
  }

  Future<void> _updateCar() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.updateCarDetails(
      carBrand: _brandController.text.trim(),
      carModel: _modelController.text.trim(),
      carColor: _colorController.text.trim(),
      carPlate: _plateController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("บันทึกข้อมูลรถยนต์เรียบร้อยแล้ว!"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // นำกลับไปยังหน้าโปรไฟล์และรีเฟรชข้อมูลใหม่
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
    const accentColor = Color(0xFF7CE5FF); // Frosted Blue
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลรถยนต์"),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading && _brandController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- ส่วนหัวแสดงไอคอนรถยนต์พรีเมียม ---
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 60,
                      color: accentColor,
                    ),
                  ),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ข้อมูลยานพาหนะ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _brandController,
                            label: "ยี่ห้อรถยนต์",
                            icon: Icons.branding_watermark_outlined,
                            validator: (value) => value!.isEmpty ? "กรุณากรอกยี่ห้อรถยนต์" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _modelController,
                            label: "รุ่นรถยนต์",
                            icon: Icons.format_list_bulleted_rounded,
                            validator: (value) => value!.isEmpty ? "กรุณากรอกรุ่นรถยนต์" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _colorController,
                            label: "สีรถยนต์",
                            icon: Icons.color_lens_outlined,
                            validator: (value) => value!.isEmpty ? "กรุณากรอกสีรถยนต์" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _plateController,
                            label: "ทะเบียนรถยนต์",
                            icon: Icons.badge_outlined,
                            validator: (value) => value!.isEmpty ? "กรุณากรอกทะเบียนรถยนต์" : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _controller.isLoading ? null : _updateCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: const Color(0xFF121212),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Color(0xFF121212), strokeWidth: 3),
                          )
                        : const Text(
                            "บันทึกข้อมูลรถยนต์",
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
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
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(label, icon),
      validator: validator,
    );
  }
}
