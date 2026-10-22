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
}
