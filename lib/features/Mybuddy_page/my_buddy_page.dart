import 'dart:async';
import 'package:mobile_project/core/utils/image_utils.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';

class MyBuddyPage extends StatefulWidget {
  final String currentUsername;
  const MyBuddyPage({super.key, required this.currentUsername});

  @override
  State<MyBuddyPage> createState() => _MyBuddyPageState();
}

class _MyBuddyPageState extends State<MyBuddyPage> {
  Map<String, dynamic>? _buddyTeam;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchActiveBuddy();
    // Poll every 5 seconds to check if the other person left the team
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchActiveBuddy();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchActiveBuddy() async {
    try {
      final response = await ApiService.get('/buddy-team/active/${widget.currentUsername}');
      if (response.statusCode == 200) {
        if (response.data == null || 
            response.data.toString().isEmpty || 
            response.data.toString() == "null" ||
            (response.data is Map && (response.data as Map).isEmpty)) {
          // If we previously had a team and now we don't, it means the other person left
          if (_buddyTeam != null && mounted) {
            _pollingTimer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('บัดดี้ของคุณออกจากทีมแล้ว')),
            );
            Navigator.pop(context); // Go back to SearchBuddyPage
          } else if (mounted) {
            setState(() {
              _buddyTeam = null;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _buddyTeam = response.data;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching active buddy: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveTeam() async {
    if (_buddyTeam == null) return;
    
    // Pop the confirmation dialog first
    Navigator.pop(context);

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.put('/buddy-team/reject/${_buddyTeam!['buddyteamid']}', data: {});
      
      // Pop the loading dialog
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        if (mounted) {
          _pollingTimer?.cancel();
          // Pop the MyBuddyPage to return to SearchBuddyPage
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to leave team: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      // Pop the loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving team: $e')),
        );
      }
      debugPrint("Error leaving team: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // หาว่าใครคือคู่หู (คนที่ไม่ใช่เรา)
    Map<String, dynamic>? buddyProfile;
    if (_buddyTeam != null) {
      if (_buddyTeam!['leaderid'].toString().toLowerCase() == widget.currentUsername.toLowerCase()) {
        buddyProfile = _buddyTeam!['follower'];
      } else {
        buddyProfile = _buddyTeam!['leader'];
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("My Buddy", style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E1E1E)),
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buddyTeam == null
              ? _buildNoBuddyView(colorScheme)
              : _buildBuddyDetailsView(buddyProfile, colorScheme),
    );
  }

  Widget _buildNoBuddyView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 80, color: Colors.black26),
          const SizedBox(height: 20),
          const Text(
            "You don't have a buddy yet",
            style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Go to search and find someone nearby!",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyDetailsView(Map<String, dynamic>? profile, ColorScheme colorScheme) {
    if (profile == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withOpacity(0.8), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundImage: NetworkImage(ImageUtils.getProfileImageUrl(profile['regisimagepath'])),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${profile['firstname']} ${profile['lastname']}",
                  style: const TextStyle(color: Color(0xFF1E1E1E), fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_buddyTeam?['leaderid']?.toString().toLowerCase() == profile['username']?.toString().toLowerCase())
                        ? const Color(0xFFF59E0B) // Amber for Leader
                        : const Color(0xFF3B82F6), // Blue for Follower
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (_buddyTeam?['leaderid']?.toString().toLowerCase() == profile['username']?.toString().toLowerCase())
                        ? "Leader (หัวหน้าทีม)"
                        : "Follower (ผู้ช่วย/ผู้ตาม)",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "@${profile['username']}",
                  style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.chat, "Chat", colorScheme.primary, () {}),
                    const SizedBox(width: 20),
                    _buildActionButton(Icons.phone, "Call", Colors.green, () {}),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Leave Team?"),
                    content: const Text("Are you sure you want to cancel this buddy team?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                      TextButton(onPressed: _leaveTeam, child: const Text("Yes, Leave", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Leave Team", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color == const Color(0xFF7CE5FF) ? Colors.blue : color),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
