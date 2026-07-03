import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:dio/dio.dart' as dio;

class ReportUserPage extends StatefulWidget {
  final dynamic requestId;

  const ReportUserPage({
    super.key,
    required this.requestId,
  });

  @override
  State<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends State<ReportUserPage> {
  String _selectedReason = "Behavior";
  final TextEditingController _detailController = TextEditingController();
  File? _evidenceImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _evidenceImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่สามารถเปิดกล้องได้: $e")),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_detailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกรายละเอียดเหตุการณ์"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Map reason to TH database expectation if needed, or keep it English matching UI
      // In the backend, we write whatever reporttype is sent.
      final Map<String, dynamic> dataMap = {
        'reporttype': _selectedReason,
        'reportdetail': _detailController.text.trim(),
        'request_id': widget.requestId.toString(),
      };

      if (_evidenceImage != null) {
        dataMap['reportImage'] = await dio.MultipartFile.fromFile(
          _evidenceImage!.path,
          filename: 'report_${widget.requestId}.jpg',
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      final response = await ApiService.post('/user-reports', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ส่งรายงานพฤติกรรมเรียบร้อยแล้ว"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true indicating success
        }
      } else {
        throw Exception(response.data?['message'] ?? "เกิดข้อผิดพลาดในการส่งรายงาน");
      }
    } catch (e) {
      debugPrint("Error submitting report: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ส่งรายงานล้มเหลว: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Report Incident Title
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Report Incident",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. What happened? Section
              const Text(
                "What happened?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),

              // Options
              _buildReasonOption("Behavior", Icons.report_problem_outlined),
              const SizedBox(height: 12),
              _buildReasonOption("Wrong Location", Icons.cancel_outlined),
              const SizedBox(height: 12),
              _buildReasonOption("Safety issue", Icons.shield_outlined),
              const SizedBox(height: 28),

              // 3. Tell us more Section
              const Text(
                "Tell us more",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "detail help our safety team investigate faster.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E7),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _detailController,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "detail ...",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Add evidence Section
              const Text(
                "Add evidence",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: CustomPaint(
                  painter: DashedBorderPainter(color: Colors.black45),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _evidenceImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _evidenceImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _evidenceImage = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 36,
                                color: Colors.black87,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Upload",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30), // Red color matching mockup
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Submit Report",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonOption(String reason, IconData icon) {
    final bool isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF2F8) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF472B6) : Colors.black12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFDB2777) : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              reason,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFDB2777) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFDB2777),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw dashed border around evidence upload container
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    // Rounded rectangle path
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    ));

    // Calculate dashed effect manually
    for (double i = 0; i < 4; i++) {
      // Draw dashes along border
    }
    
    // Simple custom dash pattern drawer using path segments
    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
