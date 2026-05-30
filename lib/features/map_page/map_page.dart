import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool isSatelliteMode = false;
  bool isMapReady = false;

  // โทเคนสาธารณะของ Mapbox สำหรับเรียกใช้งานแผนที่ความละเอียดสูง (ดึงจาก secrets.json ผ่าน --dart-define-from-file)
  static const String _mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  // คีย์ SerpApi สำหรับเรียกค้นหาผ่าน Google Maps Engine (ดึงจาก secrets.json ผ่าน --dart-define-from-file)
  static const String _serpApiKey = String.fromEnvironment(
    'SERP_API_KEY',
    defaultValue: '',
  );

  Position? _currentPosition;
  String _currentAddress = "กำลังดึงข้อมูลที่อยู่พิกัด GPS ปัจจุบัน...";

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<String> _getAddressFromCoords(double lat, double lon) async {
    try {
      final dio = Dio();
      final url = "https://api.mapbox.com/geocoding/v5/mapbox.places/$lon,$lat.json?access_token=$_mapboxAccessToken&language=th";
      debugPrint("[SafeSeat Mapbox] Calling Mapbox Reverse Geocoding API: $url");
      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['features'] != null && (data['features'] as List).isNotEmpty) {
          final firstFeature = data['features'][0];
          return firstFeature['place_name'] ?? "ไม่พบข้อมูลที่อยู่";
        }
      }
    } catch (e) {
      debugPrint("[SafeSeat Mapbox] Mapbox Geocoding Error: $e");
    }
    return "ไม่สามารถดึงข้อมูลที่อยู่ได้";
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

        String address = await _getAddressFromCoords(position.latitude, position.longitude);

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
    final address = await _getAddressFromCoords(lat, lon);
    
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

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final dio = Dio();
      String url = "https://serpapi.com/search?engine=google_maps&q=${Uri.encodeComponent(query)}&api_key=$_serpApiKey";
      
      if (_currentPosition != null && 
          _currentPosition!.latitude >= 5.0 && _currentPosition!.latitude <= 21.0 &&
          _currentPosition!.longitude >= 97.0 && _currentPosition!.longitude <= 106.0) {
        url += "&ll=@${_currentPosition!.latitude},${_currentPosition!.longitude},14z";
      }
      
      debugPrint("[SafeSeat Map] Search SerpApi Google Maps: $url");
      final response = await dio.get(url);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['local_results'] != null) {
          setState(() {
            _searchResults = data['local_results'];
          });
        } else {
          setState(() {
            _searchResults = [];
          });
        }
      }
    } catch (e) {
      debugPrint("[SafeSeat Search] Map Search Error: $e");
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectSearchedPlace(dynamic place) {
    FocusScope.of(context).unfocus();
    
    final String name = place['title'] ?? "สถานที่ค้นหา";
    final String address = place['address'] ?? "ไม่ระบุที่อยู่";
    
    final coords = place['gps_coordinates'];
    final double? lat = coords != null && coords['latitude'] != null 
        ? double.tryParse(coords['latitude'].toString()) 
        : null;
    final double? lon = coords != null && coords['longitude'] != null 
        ? double.tryParse(coords['longitude'].toString()) 
        : null;

    if (lat == null || lon == null) return;

    debugPrint("[SafeSeat Search] Selected searched place: $name ($lat, $lon)");

    setState(() {
      _searchResults = [];
      _searchController.text = name;
      _selectedPlaceName = name;
      _selectedPlaceAddress = address;
      _currentAddress = address;

      _markers = [
        Marker(
          point: LatLng(lat, lon),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              _showMarkerDetails(name, address);
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

    _moveToCoordinates(lat, lon, zoom: 16);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("พบสถานที่: $name และเลื่อนแผนที่ปักหมุดแล้ว"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1E1E),
        action: SnackBarAction(
          label: "ตกลง",
          textColor: const Color(0xFF7CE5FF),
          onPressed: () {},
        ),
      ),
    );
  }

  void _toggleMapStyle() {
    setState(() {
      isSatelliteMode = !isSatelliteMode;
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
    
    // กำหนดสไตล์แผนที่จากผู้ให้บริการ Open-source (ฟรี 100% ไม่ต้องใช้ API Key / บัตรเครดิต)
    // - โหมดดาวเทียม: ใช้ Esri World Imagery (ภาพถ่ายดาวเทียมความละเอียดสูง)
    // - โหมดปกติ: ใช้ CartoDB Dark Matter (ธีมมืดหรูหราเข้ากับโทนสีหลักของแอป SafeSeat)
    final String openMapUrl = isSatelliteMode
        ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
        : "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png";

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
                  icon: isSatelliteMode ? Icons.map_rounded : Icons.satellite_alt_rounded,
                  tooltip: isSatelliteMode ? "แสดงแผนที่ถนน" : "แสดงแผนที่ดาวเทียม",
                  onPressed: _toggleMapStyle,
                ),
                const SizedBox(height: 12),
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

          // 6. กล่องค้นหาสถานที่แบบพรีเมียม (Premium Search Bar Overlay จาก Longdo Search REST API)
          Positioned(
            top: 20,
            left: 20,
            right: 90, // เว้นช่องว่างขวาหลบปุ่มกลมด้านขวาบน
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // กล่องค้นหาหลัก
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "ค้นหาสถานที่หรือจุดหมาย...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF7CE5FF)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white60),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CE5FF)),
                                    ),
                                  ),
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) {
                      _searchPlaces(val);
                    },
                  ),
                ),

                // ตารางแสดงผลรายการค้นหาแบบเลื่อนได้ (Search Results Suggestion Card)
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withOpacity(0.08),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final place = _searchResults[index];
                          final name = place['title'] ?? "ไม่ระบุชื่อ";
                          final address = place['address'] ?? "ไม่ระบุที่อยู่";

                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined, color: Color(0xFF7CE5FF)),
                            title: Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              address,
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchedPlace(place),
                          );
                        },
                      ),
                    ),
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
