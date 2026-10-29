import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';
export 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';

extension BankAccountEntityUiExtension on BankAccountEntity {
  Color get cardStartColor => BankUiHelper.colorsForBank(bankCode).$1;
  Color get cardEndColor => BankUiHelper.colorsForBank(bankCode).$2;
}

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

class BankUiHelper {
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

  static (Color, Color) colorsForBank(String bankCode) {
    switch (bankCode.toUpperCase()) {
      case 'COMB':
        return (const Color(0xFF0F3E8F), const Color(0xFF071F47));
      case 'SAMP':
        return (const Color(0xFFC2410C), const Color(0xFF7C2D12));
      case 'HNB':
        return (const Color(0xFFB45309), const Color(0xFF78350F));
      case 'BOC':
        return (const Color(0xFFCA8A04), const Color(0xFF713F12));
      case 'NTB':
        return (const Color(0xFF047857), const Color(0xFF064E3B));
      case 'SEYB':
        return (const Color(0xFF4338CA), const Color(0xFF312E81));
      case 'PEOP':
        return (const Color(0xFF854D0E), const Color(0xFF422006));
      case 'DFCC':
        return (const Color(0xFFBE123C), const Color(0xFF881337));
      default:
        return (const Color(0xFF1E3A8A), const Color(0xFF0F172A));
    }
  }
}
