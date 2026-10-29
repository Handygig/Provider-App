import 'package:flutter/material.dart';

class BankAccountModel {
  final String id;
  final String bankName;
  final String bankCode;
  final String accountHolderName;
  final String accountNumber;
  final String branchName;
  final String branchCode;
  final String accountType; // 'Savings' | 'Current'
  final bool isPrimary;
  final Color cardStartColor;
  final Color cardEndColor;

  const BankAccountModel({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.accountHolderName,
    required this.accountNumber,
    required this.branchName,
    this.branchCode = '',
    this.accountType = 'Savings',
    this.isPrimary = false,
    this.cardStartColor = const Color(0xFF1E3A8A),
    this.cardEndColor = const Color(0xFF0F172A),
  });

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• •••• $lastFour';
  }

  String get shortMasked {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• $lastFour';
  }

  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? bankCode,
    String? accountHolderName,
    String? accountNumber,
    String? branchName,
    String? branchCode,
    String? accountType,
    bool? isPrimary,
    Color? cardStartColor,
    Color? cardEndColor,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      accountType: accountType ?? this.accountType,
      isPrimary: isPrimary ?? this.isPrimary,
      cardStartColor: cardStartColor ?? this.cardStartColor,
      cardEndColor: cardEndColor ?? this.cardEndColor,
    );
  }

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    final bankName = json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '';
    final bankCode = json['bank_code']?.toString() ?? json['bankCode']?.toString() ?? _deriveBankCode(bankName);
    final (startColor, endColor) = _colorsForBank(bankCode);

    return BankAccountModel(
      id: json['id']?.toString() ?? '',
      bankName: bankName,
      bankCode: bankCode,
      accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? json['branchName']?.toString() ?? '',
      branchCode: json['routing_number']?.toString() ?? json['routingNumber']?.toString() ?? '',
      accountType: 'Savings',
      isPrimary: json['is_default'] == true || json['is_default'] == 1 || json['isPrimary'] == true,
      cardStartColor: startColor,
      cardEndColor: endColor,
    );
  }

  static String _deriveBankCode(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('commercial')) return 'COMB';
    if (lower.contains('sampath')) return 'SAMP';
    if (lower.contains('hatton') || lower.contains('hnb')) return 'HNB';
    if (lower.contains('ceylon') || lower.contains('boc')) return 'BOC';
    if (lower.contains('nations') || lower.contains('ntb')) return 'NTB';
    if (lower.contains('seylan')) return 'SEYB';
    if (lower.contains('people')) return 'PEOP';
    if (lower.contains('dfcc')) return 'DFCC';
    return 'BANK';
  }

  static (Color, Color) _colorsForBank(String code) {
    switch (code.toUpperCase()) {
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
