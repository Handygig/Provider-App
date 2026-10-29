import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/domain/models/bank_account_model.dart';

class BankOption {
  final String name;
  final String code;
  final Color startColor;
  final Color endColor;
  final IconData icon;

  const BankOption({
    required this.name,
    required this.code,
    required this.startColor,
    required this.endColor,
    this.icon = Icons.account_balance_rounded,
  });
}

class PayoutService extends ChangeNotifier {
  static final PayoutService _instance = PayoutService._internal();
  factory PayoutService() => _instance;
  static PayoutService get instance => _instance;

  PayoutService._internal();

  Dio get _dio => sl<Dio>();

  // Supported Banks in Sri Lanka
  static const List<BankOption> supportedBanks = [
    BankOption(
      name: 'Commercial Bank of Ceylon',
      code: 'COMB',
      startColor: Color(0xFF0F3E8F),
      endColor: Color(0xFF071F47),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'Sampath Bank PLC',
      code: 'SAMP',
      startColor: Color(0xFFC2410C),
      endColor: Color(0xFF7C2D12),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'Hatton National Bank (HNB)',
      code: 'HNB',
      startColor: Color(0xFFB45309),
      endColor: Color(0xFF78350F),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'Bank of Ceylon (BOC)',
      code: 'BOC',
      startColor: Color(0xFFCA8A04),
      endColor: Color(0xFF713F12),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'Nations Trust Bank (NTB)',
      code: 'NTB',
      startColor: Color(0xFF047857),
      endColor: Color(0xFF064E3B),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'Seylan Bank',
      code: 'SEYB',
      startColor: Color(0xFF4338CA),
      endColor: Color(0xFF312E81),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'People\'s Bank',
      code: 'PEOP',
      startColor: Color(0xFF854D0E),
      endColor: Color(0xFF422006),
      icon: Icons.account_balance_rounded,
    ),
    BankOption(
      name: 'DFCC Bank',
      code: 'DFCC',
      startColor: Color(0xFFBE123C),
      endColor: Color(0xFF881337),
      icon: Icons.account_balance_rounded,
    ),
  ];

  bool _isLoading = false;
  String? _errorMessage;
  List<BankAccountModel> _accounts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BankAccountModel> get accounts => List.unmodifiable(_accounts);

  BankAccountModel? get primaryAccount {
    try {
      return _accounts.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return _accounts.isNotEmpty ? _accounts.first : null;
    }
  }

  String get primaryAccountSummary {
    final primary = primaryAccount;
    if (primary == null) return 'No Bank Account Linked';
    return '${primary.bankName} ${primary.shortMasked}';
  }

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(AppEndpoints.providerPayoutAccounts);
      final dynamic body = response.data;
      final List<dynamic> list;
      if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }

      _accounts = list
          .whereType<Map<String, dynamic>>()
          .map((item) => BankAccountModel.fromJson(item))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> addAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  }) async {
    try {
      await _dio.post(
        AppEndpoints.providerPayoutAccounts,
        data: {
          'bank_name': bankName,
          'branch_name': branchName,
          'account_holder_name': accountHolderName,
          'account_number': accountNumber,
          if (routingNumber != null && routingNumber.isNotEmpty)
            'routing_number': routingNumber,
          if (swiftCode != null && swiftCode.isNotEmpty)
            'swift_code': swiftCode,
          'is_default': isDefault,
        },
      );
      await fetchAccounts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount({
    required String id,
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
  }) async {
    try {
      await _dio.put(
        '${AppEndpoints.providerPayoutAccounts}/$id',
        data: {
          'bank_name': bankName,
          'branch_name': branchName,
          'account_holder_name': accountHolderName,
          'account_number': accountNumber,
          if (routingNumber != null && routingNumber.isNotEmpty)
            'routing_number': routingNumber,
          if (swiftCode != null && swiftCode.isNotEmpty)
            'swift_code': swiftCode,
        },
      );
      await fetchAccounts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setPrimary(String id) async {
    try {
      await _dio.put('${AppEndpoints.providerPayoutAccounts}/$id/default');
      await fetchAccounts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    try {
      await _dio.delete('${AppEndpoints.providerPayoutAccounts}/$id');
      await fetchAccounts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
