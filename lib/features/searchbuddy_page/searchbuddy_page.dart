import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_project/core/network/api_service.dart';
import '../Mybuddy_page/my_buddy_page.dart';

class SearchbuddyPage extends StatefulWidget {
  final String currentUsername;
  const SearchbuddyPage({super.key, required this.currentUsername});

  @override
  State<SearchbuddyPage> createState() => _SearchbuddyPageState();
}

class _SearchbuddyPageState extends State<SearchbuddyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<dynamic> _buddies = [];
  List<dynamic> _pendingRequests = []; 
  bool _isLoading = false;
  Timer? _debounce;
  Timer? _refreshTimer;

  final List<String> _categories = ['All', 'Nearby'];

  @override
  void initState() {
    super.initState();
    _fetchBuddies();
    _fetchPendingRequests();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchPendingRequests();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final response = await ApiService.get('/buddy-team/pending/${widget.currentUsername}');
      if (response.statusCode == 200) {
        setState(() {
          _pendingRequests = response.data is List ? response.data : [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending requests: $e");
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      final response = await ApiService.put('/buddy-team/accept/$requestId', data: {});
      if (response.statusCode == 200) {
        _fetchPendingRequests();
        _fetchBuddies();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Accepted buddy request!')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error accepting request: $e");
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      final response = await ApiService.put('/buddy-team/reject/$requestId', data: {});
      if (response.statusCode == 200) {
        _fetchPendingRequests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rejected buddy request')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error rejecting request: $e");
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition();
  }

  void _showRequestsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text("Buddy Requests", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text("Requests expire after 5 minutes", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              Expanded(
                child: _pendingRequests.isEmpty
                    ? const Center(child: Text("No pending requests", style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: _pendingRequests.length,
                        itemBuilder: (context, index) {
                          final req = _pendingRequests[index];
                          final sender = req['sender'] ?? {};
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: NetworkImage(sender['regisimagepath'] ?? 'https://i.pravatar.cc/150')),
                            title: Text(sender['username'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                            subtitle: const Text("Wants to be your buddy", style: TextStyle(color: Colors.white54, fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () async { await _acceptRequest(req['buddyteamid']); setModalState(() {}); if (_pendingRequests.isEmpty) Navigator.pop(context); }),
                                IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () async { await _rejectRequest(req['buddyteamid']); setModalState(() {}); if (_pendingRequests.isEmpty) Navigator.pop(context); }),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchBuddies({String query = ''}) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> params = {
        if (query.isNotEmpty) 'search': query,
        if (_selectedCategory != 'All') 'category': _selectedCategory.toLowerCase(),
        'exclude': widget.currentUsername,
      };
      if (_selectedCategory == 'Nearby') {
        final position = await _determinePosition();
        if (position != null) {
          params['lat'] = position.latitude.toString();
          params['lng'] = position.longitude.toString();
          params['radius'] = '2';
        }
      }
      final response = await ApiService.get('/users', queryParameters: params);
      if (response.statusCode == 200) {
        setState(() => _buddies = response.data is List ? response.data : []);
      }
    } catch (e) {
      debugPrint("Error fetching buddies: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchBuddies(query: query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [colorScheme.primary.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Find Your Buddy", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text("Connect with people nearby", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildIconBtn(Icons.group, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyBuddyPage(currentUsername: widget.currentUsername))).then((_) => _fetchPendingRequests());
                                }, colorScheme),
                                const SizedBox(width: 12),
                                _buildNotificationBtn(colorScheme),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSearchBar(colorScheme),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = category);
                                _fetchBuddies(query: _searchController.text);
                              },
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                              backgroundColor: colorScheme.surface,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else if (_buddies.isEmpty)
                  SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_search_rounded, size: 80, color: Colors.white24), const SizedBox(height: 16), Text("No buddies found", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white54))])) )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) => _buildBuddyCard(_buddies[index], colorScheme), childCount: _buddies.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle, border: Border.all(color: colorScheme.primary.withOpacity(0.2))),
        child: Icon(icon, color: colorScheme.primary),
      ),
    );
  }

  Widget _buildNotificationBtn(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _showRequestsSheet,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle, border: Border.all(color: colorScheme.primary.withOpacity(0.2))),
            child: Icon(Icons.notifications_none, color: colorScheme.primary),
          ),
          if (_pendingRequests.isNotEmpty)
            Positioned(
              right: 0, top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text('${_pendingRequests.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextField(
        controller: _searchController, onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search by name or interest...", hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          suffixIcon: IconButton(icon: Icon(Icons.tune, color: colorScheme.primary, size: 20), onPressed: () => _fetchBuddies(query: _searchController.text)),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildBuddyCard(Map<String, dynamic> buddy, ColorScheme colorScheme) {
    final name = buddy['firstname'] != null ? "${buddy['firstname']} ${buddy['lastname'] ?? ''}" : buddy['username'] ?? 'Unknown';
    final image = buddy['regisimagepath'] ?? 'https://i.pravatar.cc/150';
    final distance = buddy['distance'] ?? 'Nearby';

    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colorScheme.primary.withOpacity(0.1))),
      child: Row(
        children: [
          CircleAvatar(radius: 35, backgroundImage: NetworkImage(image)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)), Text(distance, style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 6),
                Text(buddy['bio'] ?? "No bio available", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: BorderSide(color: colorScheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("View Profile"))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: () => _sendRequest(buddy['username']), style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Send Request"))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest(String receiverUsername) async {
    try {
      final response = await ApiService.post('/buddy-team', data: {'sender_id': widget.currentUsername, 'receiver_id': receiverUsername});
      if (response.statusCode == 201 && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent! Wait for 5 minutes.')));
    } catch (e) {
      debugPrint("Error sending request: $e");
    }
  }
}
