import 'package:flutter/material.dart';
import 'package:mobile_project/futures/withdraw_wallet_page/withdraw_wallet.dart';
import 'package:mobile_project/futures/view_wallet_history/view_wallet_history.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletBalancePage extends StatefulWidget {
  final String phone;

  const WalletBalancePage({super.key, required this.phone});

  @override
  State<WalletBalancePage> createState() => _WalletBalancePageState();
}

class _WalletBalancePageState extends State<WalletBalancePage> {
  // ฟังก์ชันดึงข้อมูลยอดเงินจาก Supabase
  Future<double> getWalletBalance() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('wallet!inner(balance)')
        .eq('username', widget.phone)
        .single();

    final wallet = data['wallet'];
    if (wallet is List && wallet.isNotEmpty) {
      return (wallet[0]['balance'] ?? 0).toDouble();
    } else if (wallet is Map) {
      return (wallet['balance'] ?? 0).toDouble();
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "กระเป๋าเงินของฉัน",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: FutureBuilder<double>(
          future: getWalletBalance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text("เกิดข้อผิดพลาด: ${snapshot.error}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text("ลองอีกครั้ง"),
                    ),
                  ],
                ),
              );
            }

            final balance = snapshot.data ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนแสดงยอดเงิน (Card สวยๆ) ---
                  Card(
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ยอดเงินคงเหลือ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                balance.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "บาท",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- ส่วนเมนูจัดการกระเป๋าเงิน (Placeholder) ---
                  const Text(
                    "รายการจัดการ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildMenuButton(
                    icon: Icons.history,
                    title: "ประวัติการทำรายการ",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WalletHistoryPage(phone: widget.phone),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "ถอนเงิน",
                    color: Colors.redAccent,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WithdrawWalletPage(phone: widget.phone),
                        ),
                      );
                      if (result == true) {
                        // Refresh the balance if withdrawal was successful
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
