import 'package:equatable/equatable.dart';

class BankAccountEntity extends Equatable {
  final String id;
  final String bankName;
  final String bankCode;
  final String accountHolderName;
  final String accountNumber;
  final String branchName;
  final String branchCode;
  final String accountType; // 'Savings' | 'Current'
  final bool isPrimary;

  const BankAccountEntity({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.accountHolderName,
    required this.accountNumber,
    required this.branchName,
    this.branchCode = '',
    this.accountType = 'Savings',
    this.isPrimary = false,
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

  BankAccountEntity copyWith({
    String? id,
    String? bankName,
    String? bankCode,
    String? accountHolderName,
    String? accountNumber,
    String? branchName,
    String? branchCode,
    String? accountType,
    bool? isPrimary,
  }) {
    return BankAccountEntity(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      accountType: accountType ?? this.accountType,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bankName,
        bankCode,
        accountHolderName,
        accountNumber,
        branchName,
        branchCode,
        accountType,
        isPrimary,
      ];
}
