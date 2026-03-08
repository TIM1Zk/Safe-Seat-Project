import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class WalletHistoryPage extends StatefulWidget {
  final String phone;

  const WalletHistoryPage({super.key, required this.phone});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      // 1. Get profile ID
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('username', widget.phone)
          .single();

      final profileId = profileData['id'];

      // 2. Fetch transactions
      final data = await Supabase.instance.client
          .from('transactions')
          .select('*')
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);

      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('โหลดข้อมูลล้มเหลว: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ประวัติการทำรายการ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  return _buildTransactionCard(tx);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "ยังไม่มีประวัติการทำรายการ",
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final bool isWithdraw = tx['type'] == 'withdraw';
    final DateTime createdAt = DateTime.parse(tx['created_at']).toLocal();
    final String formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(createdAt);
    final double amount = (tx['amount'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isWithdraw ? Colors.red[50] : Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWithdraw ? Icons.call_made : Icons.call_received,
            color: isWithdraw ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          isWithdraw ? "ถอนเงิน" : "เติมเงิน",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${isWithdraw ? '-' : '+'}${amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: isWithdraw ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              tx['status'] == 'success' ? "สำเร็จ" : "รอดำเนินการ",
              style: TextStyle(
                color: tx['status'] == 'success' ? Colors.green : Colors.orange,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
