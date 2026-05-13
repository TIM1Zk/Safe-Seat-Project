import 'package:flutter/material.dart';
import 'package:mobile_project/core/network/api_service.dart';
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
      final response = await ApiService.get('/wallets/${widget.phone}/transactions');

      if (response.statusCode == 200) {
        setState(() {
          _transactions = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load transactions");
      }
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
        title: const Text("ประวัติการทำรายการ"),
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
          Icon(Icons.history, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            "ยังไม่มีประวัติการทำรายการ",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
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
            color: isWithdraw ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWithdraw ? Icons.call_made : Icons.call_received,
            color: isWithdraw ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          isWithdraw ? "ถอนเงิน" : "เติมเงิน",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
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
