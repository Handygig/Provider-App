import 'package:flutter/material.dart';
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

  // Supported Banks
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

  // User's added bank accounts
  final List<BankAccountModel> _accounts = [
    const BankAccountModel(
      id: 'acc_01',
      bankName: 'Commercial Bank of Ceylon',
      bankCode: 'COMB',
      accountHolderName: 'Alex Perera',
      accountNumber: '800214594210',
      branchName: 'Kollupitiya Branch',
      branchCode: '042',
      accountType: 'Savings',
      isPrimary: true,
      cardStartColor: Color(0xFF1E3A8A),
      cardEndColor: Color(0xFF0F172A),
    ),
    const BankAccountModel(
      id: 'acc_02',
      bankName: 'Sampath Bank PLC',
      bankCode: 'SAMP',
      accountHolderName: 'Alex Perera',
      accountNumber: '100458291039',
      branchName: 'Bambalapitiya Branch',
      branchCode: '018',
      accountType: 'Current',
      isPrimary: false,
      cardStartColor: Color(0xFFC2410C),
      cardEndColor: Color(0xFF431407),
    ),
  ];

  String _payoutSchedule = 'Weekly (Every Monday)';
  double _minimumThreshold = 25.00; // in USD / equivalent in LKR
  bool _instantPayoutEnabled = true;

  // Getters
  List<BankAccountModel> get accounts => List.unmodifiable(_accounts);

  BankAccountModel? get primaryAccount {
    try {
      return _accounts.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return _accounts.isNotEmpty ? _accounts.first : null;
    }
  }

  String get payoutSchedule => _payoutSchedule;
  double get minimumThreshold => _minimumThreshold;
  bool get instantPayoutEnabled => _instantPayoutEnabled;

  String get primaryAccountSummary {
    final primary = primaryAccount;
    if (primary == null) return 'No Bank Account Linked';
    return '${primary.bankName} ${primary.shortMasked}';
  }

  // Actions
  void addAccount(BankAccountModel newAccount) {
    if (newAccount.isPrimary || _accounts.isEmpty) {
      // Set all existing to non-primary
      for (int i = 0; i < _accounts.length; i++) {
        _accounts[i] = _accounts[i].copyWith(isPrimary: false);
      }
      _accounts.insert(0, newAccount.copyWith(isPrimary: true));
    } else {
      _accounts.add(newAccount);
    }
    notifyListeners();
  }

  void updateAccount(BankAccountModel updatedAccount) {
    final index = _accounts.indexWhere((a) => a.id == updatedAccount.id);
    if (index != -1) {
      if (updatedAccount.isPrimary) {
        for (int i = 0; i < _accounts.length; i++) {
          _accounts[i] = _accounts[i].copyWith(isPrimary: false);
        }
      }
      _accounts[index] = updatedAccount;
      notifyListeners();
    }
  }

  bool deleteAccount(String id) {
    if (_accounts.length <= 1) {
      // Keep at least one account
      return false;
    }

    final toRemove = _accounts.firstWhere((a) => a.id == id);
    _accounts.removeWhere((a) => a.id == id);

    // If the removed account was primary, make the first one primary
    if (toRemove.isPrimary && _accounts.isNotEmpty) {
      _accounts[0] = _accounts[0].copyWith(isPrimary: true);
    }

    notifyListeners();
    return true;
  }

  void setPrimary(String id) {
    for (int i = 0; i < _accounts.length; i++) {
      if (_accounts[i].id == id) {
        _accounts[i] = _accounts[i].copyWith(isPrimary: true);
      } else {
        _accounts[i] = _accounts[i].copyWith(isPrimary: false);
      }
    }
    notifyListeners();
  }

  void updatePayoutSchedule(String schedule) {
    _payoutSchedule = schedule;
    notifyListeners();
  }

  void updateMinimumThreshold(double threshold) {
    _minimumThreshold = threshold;
    notifyListeners();
  }

  void toggleInstantPayout(bool enabled) {
    _instantPayoutEnabled = enabled;
    notifyListeners();
  }
}
