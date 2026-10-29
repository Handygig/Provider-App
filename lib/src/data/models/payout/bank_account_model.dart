import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.id,
    required super.bankName,
    required super.bankCode,
    required super.accountHolderName,
    required super.accountNumber,
    required super.branchName,
    super.branchCode = '',
    super.accountType = 'Savings',
    super.isPrimary = false,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    final bankName =
        json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '';
    final bankCode = json['bank_code']?.toString() ??
        json['bankCode']?.toString() ??
        deriveBankCode(bankName);

    return BankAccountModel(
      id: json['id']?.toString() ?? '',
      bankName: bankName,
      bankCode: bankCode,
      accountHolderName: json['account_holder_name']?.toString() ??
          json['accountHolderName']?.toString() ??
          '',
      accountNumber: json['account_number']?.toString() ??
          json['accountNumber']?.toString() ??
          '',
      branchName: json['branch_name']?.toString() ??
          json['branchName']?.toString() ??
          '',
      branchCode: json['routing_number']?.toString() ??
          json['routingNumber']?.toString() ??
          '',
      accountType: 'Savings',
      isPrimary: json['is_default'] == true ||
          json['is_default'] == 1 ||
          json['isPrimary'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'branch_name': branchName,
      'routing_number': branchCode,
      'is_default': isPrimary,
    };
  }

  static String deriveBankCode(String name) {
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
}
