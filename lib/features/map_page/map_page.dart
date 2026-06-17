import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_project/core/network/api_service.dart';
import 'package:mobile_project/core/utils/session_manager.dart';
import 'package:mobile_project/features/profile_page/profile_page.dart';
import 'package:mobile_project/features/view_wallet_balance/view_wallet_balance.dart';
import 'package:mobile_project/features/Listdriverreport_page/Listdriverreport_page.dart';
import 'package:mobile_project/features/searchbuddy_page/searchbuddy_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool isSatelliteMode = false;
  bool isMapReady = false;
  bool isOnline = false;
  bool _isLeader = true;
  bool _isLoadingLeaderStatus = true;
  int? _buddyTeamId;
  Timer? _locationUpdateTimer;
  RealtimeChannel? _teamChannel;
  StreamSubscription<List<Map<String, dynamic>>>? _teamStatusSubscription;
  bool _isJobOfferOpen = false;

  Position? _currentPosition;
  String _currentAddress = "กำลังดึงข้อมูลที่อยู่พิกัด GPS ปัจจุบัน...";


  List<Marker> _markers = [];
  String? _selectedPlaceName;
  String? _selectedPlaceAddress;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _checkLeaderStatus();
    _startLocationUpdater();
    
    // ตั้งค่าสถานะแผนที่พร้อมในบิลด์ถัดไป
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isMapReady = true;
      });
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _teamChannel?.unsubscribe();
    _teamStatusSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkLeaderStatus() async {
    try {
      String? username = await SessionManager.getUsername();
      if (username != null) {
        final response = await ApiService.get('/buddy-team/active/$username');
        if (response.statusCode == 200 && response.data != null && response.data.toString().isNotEmpty && response.data.toString() != "null") {
          final data = response.data;
          if (data is Map && data.isNotEmpty) {
            String leaderId = data['leaderid'].toString().toLowerCase();
            int? teamId;
            if (data['buddyteamid'] != null) {
              teamId = int.tryParse(data['buddyteamid'].toString());
            }
            if (mounted) {
              setState(() {
                _isLeader = (leaderId == username.toLowerCase());
                _buddyTeamId = teamId;
              });
              if (_buddyTeamId != null) {
                _setupRealtimeListeners(_buddyTeamId!);
              }
            }
          } else {
             if (mounted) setState(() => _isLeader = true);
          }
        } else {
           if (mounted) setState(() => _isLeader = true);
        }
      }
    } catch (e) {
       debugPrint("Error checking leader status: $e");
       if (mounted) setState(() => _isLeader = true);
    } finally {
       if (mounted) setState(() => _isLoadingLeaderStatus = false);
    }
  }

  void _setupRealtimeListeners(int teamId) {
    final supabase = Supabase.instance.client;
    
    // 1. Listen for Broadcast (New Job Offers)
    _teamChannel = supabase.channel('team_room_$teamId');
    _teamChannel!.onBroadcast(
      event: 'new_job_dispatched',
      callback: (payload) {
        if (payload != null) {
          _showNewJobOfferDialog(payload);
        }
      },
    ).subscribe();

    // 2. Listen for Team Status changes (if partner accepts job)
    _teamStatusSubscription = supabase
        .from('buddyteam')
        .stream(primaryKey: ['buddyteamid'])
        .eq('buddyteamid', teamId)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final team = data.first;
        if (team['teamstatus'] == 'Busy') {
          // If status is Busy, meaning the job was accepted
          _closeJobOfferDialog();
        }
      }
    });
  }

  void _startLocationUpdater() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // If we don't have a team ID yet, periodically check it
      if (_buddyTeamId == null) {
        await _checkLeaderStatus();
      }

      // Only Leader updates location, and only when matched
      if (_isLeader && _buddyTeamId != null) {
        try {
          Position? position;
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            );
          } catch (e) {
            debugPrint("Failed to get current position in timer: $e");
          }

          // Fallback to last known position if current position fetch fails
          position ??= await Geolocator.getLastKnownPosition();

          if (position != null) {
            if (mounted) {
              setState(() {
                _currentPosition = position;
                _currentAddress = "พิกัด: ${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}";
              });
            }

            await Supabase.instance.client
                .from('buddyteam')
                .update({
                  'currentloclat': position.latitude,
                  'currentloclng': position.longitude,
                })
                .eq('buddyteamid', _buddyTeamId!);
          }
        } catch (e) {
          debugPrint("Failed to update team location: $e");
        }
      }
    });
  }

  Future<void> _forceUpdateLocation() async {
    if (!_isLeader) {
      debugPrint("Not a leader. Cannot update GPS.");
      return;
    }
    if (_buddyTeamId == null) {
      debugPrint("BuddyTeamId is null. Cannot update GPS.");
      return;
    }
    
    // พยายามดึงพิกัดใหม่ถ้ายังไม่มี
    if (_currentPosition == null) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        debugPrint("Failed to fetch GPS during force update: $e");
        return;
      }
    }

    if (_currentPosition != null) {
      try {
        await Supabase.instance.client
            .from('buddyteam')
            .update({
              'currentloclat': _currentPosition!.latitude,
              'currentloclng': _currentPosition!.longitude,
            })
            .eq('buddyteamid', _buddyTeamId!);
        debugPrint("Forced GPS update to DB successful.");
      } catch (e) {
        debugPrint("Failed to force update team location: $e");
      }
    }
  }

  void _showNewJobOfferDialog(Map<String, dynamic> payload) {
    if (_isJobOfferOpen) return; // Prevent multiple dialogs
    
    setState(() {
      _isJobOfferOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("งานใหม่เข้า!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ราคา: ${payload['requestfee'] ?? 0} บาท"),
              const SizedBox(height: 8),
              Text("ระยะทาง: ${payload['reqdistance'] ?? 0} กม."),
              const SizedBox(height: 8),
              if (payload['note'] != null && payload['note'].toString().isNotEmpty)
                Text("หมายเหตุ: ${payload['note']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isJobOfferOpen = false;
                });
              },
              child: const Text("ปฏิเสธ"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isJobOfferOpen = false;
                });
                _acceptTeamJob(payload['requestid']);
              },
              child: const Text("รับงาน"),
            ),
          ],
        );
      },
    );
  }

  void _closeJobOfferDialog() {
    if (_isJobOfferOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _isJobOfferOpen = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("บัดดี้ของคุณรับงานนี้แล้ว กำลังเข้าสู่โหมดนำทาง")),
      );
    }
  }

  Future<void> _acceptTeamJob(dynamic requestId) async {
    try {
      if (_buddyTeamId == null) return;
      
      final response = await ApiService.post('/buddy-team/accept-job', data: {
        'request_id': requestId,
        'buddy_team_id': _buddyTeamId,
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'รับงานสำเร็จ')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'รับงานไม่สำเร็จ (อาจมีคนรับไปแล้ว)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์')),
        );
      }
    }
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

  Widget _buildOnlineOfflineButton() {
    return GestureDetector(
      onTap: () async {
        if (!_isLoadingLeaderStatus && !_isLeader) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("เฉพาะหัวหน้าทีมเท่านั้นที่สามารถกด Online ได้")),
          );
          return;
        }

        if (!isOnline) { // กำลังจะเปิด Online
          if (_buddyTeamId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("กรุณาจับคู่เพื่อนร่วมทางก่อนเข้าสู่สถานะออนไลน์")),
            );
            String? username = await SessionManager.getUsername();
            if (username != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchbuddyPage(currentUsername: username),
                ),
              );
            }
            return;
          }
        }

        setState(() {
          isOnline = !isOnline;
        });
        if (isOnline) {
          _forceUpdateLocation();
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: isOnline ? const Color(0xFF22C55E) : const Color(0xFF1E1F22),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.power_settings_new,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isOnline ? "ONLINE" : "OFFLINE",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyButton() {
    return GestureDetector(
      onTap: () async {
        String? username = await SessionManager.getUsername();
        if (username != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchbuddyPage(currentUsername: username),
            ),
          );
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.people_alt_outlined,
          color: Colors.black,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ใช้แผนที่มาตรฐานของ OpenStreetMap
    final String openMapUrl = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

    return Scaffold(
      body: Stack(
        children: [
          // 1. แผนที่ Fullscreen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.7563, 100.5018), // กรุงเทพฯ เป็นค่าเริ่มต้น
              initialZoom: 12.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: openMapUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.mobile_project',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // 2. ป้ายแสดงรายละเอียด Marker เมื่อถูกสัมผัสแตะ
          if (_selectedPlaceName != null)
            Positioned(
              bottom: 120,
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

          // 3. ปุ่มเข็มทิศ / ตำแหน่งปัจจุบัน (ขวาล่างด้านบนปุ่ม Offline)
          Positioned(
            bottom: 120,
            right: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentPosition != null) {
                  _addDriverMarkerAt(_currentPosition!.latitude, _currentPosition!.longitude, showSnackBar: true);
                } else {
                  _initLocation();
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: 0.785398, // หมุนเอียง 45 องศาให้ชี้บนขวา
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),

          // 4. แถบปุ่ม Offline/Online และ ปุ่มค้นหา Buddy (ด้านล่างสุดของ Stack)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOnlineOfflineButton(),
                const SizedBox(width: 16),
                _buildBuddyButton(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // แท็บ Home ในปัจจุบัน
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF7CE5FF),
        unselectedItemColor: Colors.white60,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) async {
          if (index == 0) return; // อยู่หน้า Home แล้วไม่ต้องทำอะไร
          String? username = await SessionManager.getUsername();
          if (username == null) return;

          if (index == 1) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletBalancePage(username: username),
                ),
              );
            }
          } else if (index == 2) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListDriverReportPage(username: username),
                ),
              );
            }
          } else if (index == 3) {
            String? phoneNo = await SessionManager.getPhoneNo();
            if (phoneNo != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(username: username, phoneno: phoneNo),
                ),
              );
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: "Activity",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
