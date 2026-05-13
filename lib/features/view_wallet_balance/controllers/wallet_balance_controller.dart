import 'package:flutter/material.dart';
import 'package:mobile_project/core/network/api_service.dart';

class WalletBalanceController extends ChangeNotifier {
  double balance = 0.0;
  bool isLoading = true;
  String? errorMessage;

  final String phone;

  WalletBalanceController({required this.phone}) {
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/wallets/$phone/balance');
      if (response.statusCode == 200 && response.data != null) {
        balance = (response.data['balance'] ?? 0).toDouble();
      } else {
        errorMessage = "Failed to load balance";
      }
    } catch (e) {
      errorMessage = "Error loading balance: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
