import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool isSatelliteMode = false;
  bool isMapReady = false;



  Position? _currentPosition;
  String _currentAddress = "กำลังดึงข้อมูลที่อยู่พิกัด GPS ปัจจุบัน...";


  List<Marker> _markers = [];
  String? _selectedPlaceName;
  String? _selectedPlaceAddress;

  @override
  void initState() {
    super.initState();
    _initLocation();
    
    // ตั้งค่าสถานะแผนที่พร้อมในบิลด์ถัดไป
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isMapReady = true;
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }


  Future<void> _initLocation() async {
    try {
      debugPrint("[SafeSeat Mapbox] Checking location services...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "โปรดเปิด GPS และยอมรับสิทธิ์ในการระบุพิกัด";
        });
        return;
      }

      debugPrint("[SafeSeat Mapbox] Checking permission status...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("[SafeSeat Mapbox] Requesting permission...");
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

        // ดึงตำแหน่งประวัติล่าสุดแบบรวดเร็ว
        Position? position = await Geolocator.getLastKnownPosition();
        
        // ดึงตำแหน่งสดด้วยความแม่นยำต่ำเพื่อความชัวร์และเร็วสูงสุดบน Emulator
        position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 4),
          ),
        );

        String address = "พิกัด: " + position.latitude.toStringAsFixed(5) + ", " + position.longitude.toStringAsFixed(5);

        if (mounted) {
          setState(() {
            _currentPosition = position;
            _currentAddress = address;
          });

          // ย้ายกล้องไปที่ตำแหน่งจริงของเครื่องทันที
          _moveToCoordinates(position.latitude, position.longitude, zoom: 15);
          _addDriverMarkerAt(position.latitude, position.longitude, showSnackBar: false);
        }
      } else {
        setState(() {
          _currentAddress = "ไม่ได้สิทธิ์การเข้าถึงตำแหน่งที่อยู่";
        });
      }
    } catch (e) {
      debugPrint("[SafeSeat Mapbox] Error in _initLocation: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "เกิดข้อผิดพลาดในการโหลดตำแหน่ง";
        });
      }
    }
  }

  void _moveToCoordinates(double lat, double lon, {double zoom = 15}) {
    if (!isMapReady) return;
    _mapController.move(LatLng(lat, lon), zoom);
  }

  void _addDriverMarkerAt(double lat, double lon, {bool showSnackBar = true}) async {
    final address = "พิกัด: " + lat.toStringAsFixed(5) + ", " + lon.toStringAsFixed(5);
    
    setState(() {
      _selectedPlaceName = "คุณ (คนขับ Safe Seat)";
      _selectedPlaceAddress = address;
      _currentAddress = address;
      
      _markers = [
        Marker(
          point: LatLng(lat, lon),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              _showMarkerDetails("คุณ (คนขับ Safe Seat)", address);
            },
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 48,
            ),
          ),
        )
      ];
    });

    _moveToCoordinates(lat, lon, zoom: 15);

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ระบุพิกัดตำแหน่งของคุณสำเร็จที่ (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: "ตกลง",
            textColor: const Color(0xFF7CE5FF),
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showMarkerDetails(String name, String address) {
    setState(() {
      _selectedPlaceName = name;
      _selectedPlaceAddress = address;
    });
  }


  void _zoomIn() {
    _moveToCoordinates(
      _mapController.camera.center.latitude,
      _mapController.camera.center.longitude,
      zoom: _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _moveToCoordinates(
      _mapController.camera.center.latitude,
      _mapController.camera.center.longitude,
      zoom: _mapController.camera.zoom - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF7CE5FF);
    
    // ใช้แผนที่มาตรฐานของ OpenStreetMap
    final String openMapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

    return Scaffold(
      appBar: AppBar(
        title: const Text("แผนที่และค้นหาร้านอาหาร"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _addDriverMarkerAt(_currentPosition!.latitude, _currentPosition!.longitude, showSnackBar: true);
              } else {
                _initLocation();
              }
            },
            tooltip: "ดึงตำแหน่งปัจจุบัน",
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. ตัวแสดงผลแผนที่ Open-source ผ่าน flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.7563, 100.5018), // กรุงเทพฯ เป็นค่าเริ่มต้น
              initialZoom: 12.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              // โหลดแผ่นระนาบภาพแผนที่ Open-source Tiles
              TileLayer(
                urlTemplate: openMapUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.mobile_project',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              
              // โดมแสดงมาร์กเกอร์ / ปักหมุด
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // 2. แถบแสดงที่อยู่ปัจจุบันแบบพรีเมียม (Glassmorphism Bottom Address Card)
          Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0x1A7CE5FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF7CE5FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "ตำแหน่งและพิกัดปัจจุบันของคุณ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. ป้ายแสดงรายละเอียด Marker เมื่อถูกสัมผัสแตะ (Marker Info Bubble Popup)
          if (_selectedPlaceName != null)
            Positioned(
              bottom: 220,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CE5FF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Color(0xFF1E1E1E), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedPlaceName!,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedPlaceAddress != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _selectedPlaceAddress!,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 11,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF1E1E1E), size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _selectedPlaceName = null;
                          _selectedPlaceAddress = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          // 4. ปุ่มปักหมุดกลับมาตำแหน่งคนขับ (ด้านล่างขวา)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: "btn_marker",
              onPressed: () {
                if (_currentPosition != null) {
                  _addDriverMarkerAt(_currentPosition!.latitude, _currentPosition!.longitude, showSnackBar: true);
                } else {
                  _initLocation();
                }
              },
              backgroundColor: accentColor,
              foregroundColor: const Color(0xFF121212),
              icon: const Icon(Icons.my_location_rounded),
              label: const Text(
                "ตำแหน่งของฉัน",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 5. แผงเครื่องมือซูมและการตั้งค่าสไตล์ (ด้านขวาบน)
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                _buildCircleButton(
                  icon: Icons.add,
                  tooltip: "ซูมเข้า",
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 12),
                _buildCircleButton(
                  icon: Icons.remove,
                  tooltip: "ซูมออก",
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF7CE5FF)),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
