import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WithdrawWalletPage extends StatefulWidget {
  final String phone;

  const WithdrawWalletPage({super.key, required this.phone});

  @override
  State<WithdrawWalletPage> createState() => _WithdrawWalletPageState();
}

class _WithdrawWalletPageState extends State<WithdrawWalletPage> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double _currentBalance = 0.0;
  String _selectedMethod = 'ธนาคาร (Bank Transfer)';

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('wallet!inner(balance)')
          .eq('username', widget.phone)
          .single();

      final wallet = data['wallet'];
      setState(() {
        if (wallet is List && wallet.isNotEmpty) {
          _currentBalance = (wallet[0]['balance'] ?? 0).toDouble();
        } else if (wallet is Map) {
          _currentBalance = (wallet['balance'] ?? 0).toDouble();
        }
      });
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่ถูกต้อง')),
      );
      return;
    }

    if (amount > _currentBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยอดเงินคงเหลือไม่เพียงพอ')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get profile and wallet ID
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('id, wallet!inner(id)')
          .eq('username', widget.phone)
          .single();

      final profileId = profileData['id'];
      final walletId = (profileData['wallet'] as List)[0]['id'];

      // 2. Perform withdrawal (Update balance)
      await Supabase.instance.client
          .from('wallet')
          .update({'balance': _currentBalance - amount})
          .eq('id', walletId);

      // 3. Record transaction
      await Supabase.instance.client.from('transactions').insert({
        'profile_id': profileId,
        'amount': amount,
        'type': 'withdraw',
        'status': 'success',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ถอนเงินสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ถอนเงิน"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "ยอดเงินที่ถอนได้",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_currentBalance.toStringAsFixed(2)} บาท",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "จำนวนเงินที่ต้องการถอน",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: "บาท",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "กรุณาระบุจำนวนเงิน";
                        final val = double.tryParse(value);
                        if (val == null || val <= 0)
                          return "จำนวนเงินไม่ถูกต้อง";
                        if (val > _currentBalance) return "ยอดเงินไม่เพียงพอ";
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "ช่องทางการรับเงิน",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      items:
                          [
                            'ธนาคาร (Bank Transfer)',
                            'PromptPay (พร้อมเพย์)',
                            'TrueMoney Wallet',
                          ].map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMethod = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleWithdraw,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "ยืนยันการถอนเงิน",
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
