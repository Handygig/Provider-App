import 'package:flutter/material.dart';

/// Provider account type:
/// 1. [individual]: Full unrestricted provider app (direct jobs, payouts/withdrawals,
///    licence verification, bank details, skills management, coverage selection).
/// 2. [company]: Access-controlled service provider app under a service providing company.
///    (can do job workflow: quote, start, complete jobs; can only view earned money;
///    cannot withdraw money; no licence verification, bank details, skills management,
///    or coverage selection; only does company-assigned jobs).
enum ProviderType {
  individual,
  company,
}

extension ProviderTypeExtension on ProviderType {
  String get label {
    switch (this) {
      case ProviderType.individual:
        return 'Individual Provider';
      case ProviderType.company:
        return 'Company Provider';
    }
  }

  String get shortTag {
    switch (this) {
      case ProviderType.individual:
        return 'Individual Pro';
      case ProviderType.company:
        return 'Company Staff';
    }
  }

  String get description {
    switch (this) {
      case ProviderType.individual:
        return 'Independent contractor with full access to direct quotes, withdrawals & profile settings';
      case ProviderType.company:
        return 'Under company employment with access control: company-dispatched jobs & earnings view';
    }
  }
}

class ProviderSessionService extends ChangeNotifier {
  static final ProviderSessionService _instance =
      ProviderSessionService._internal();
  factory ProviderSessionService() => _instance;
  static ProviderSessionService get instance => _instance;

  ProviderSessionService._internal();

  ProviderType _providerType = ProviderType.individual;
  final String _providerName = 'Alex Perera';
  String _companyName = 'Apex Home Solutions Pvt Ltd';
  String _companyId = 'CMP-8821';
  String _staffId = 'PRO-4091';
  final String _companyRegNo = 'PV-00249182';

  // Getters
  ProviderType get providerType => _providerType;
  bool get isIndividual => _providerType == ProviderType.individual;
  bool get isCompanyProvider => _providerType == ProviderType.company;

  String get providerName => _providerName;
  String get companyName => _companyName;
  String get companyId => _companyId;
  String get staffId => _staffId;
  String get companyRegNo => _companyRegNo;

  // -------------------------------------------------------------
  // Access-Controlled Capability Flags
  // -------------------------------------------------------------

  /// Both individual and company providers execute the job workflow:
  /// quote, start, do jobs, finish jobs, extra items, customer chat.
  bool get canDoJobWorkflow => true;

  /// Individual can withdraw money to bank account.
  /// Company provider can only view earned money; withdrawals are managed by company payroll.
  bool get canWithdrawMoney => isIndividual;

  /// Individual needs to verify licences / submit KYC documents.
  /// Company provider does NOT verify licences (compliance is handled by parent company).
  bool get requiresLicenceVerification => isIndividual;

  /// Individual provides bank details for direct payouts.
  /// Company provider does NOT provide bank details (paid through company).
  bool get canProvideBankDetails => isIndividual;

  /// Individual manages skills and service offerings.
  /// Company provider does NOT manage skills (assigned by company).
  bool get canManageSkills => isIndividual;

  /// Individual selects coverage areas and radius.
  /// Company provider does NOT select coverage areas (dispatched by company).
  bool get canSelectCoverageAreas => isIndividual;

  /// Company provider only does jobs assigned by company.
  bool get isCompanyAssignedOnly => isCompanyProvider;

  // -------------------------------------------------------------
  // Mutators & Mode Switchers
  // -------------------------------------------------------------

  void setProviderType(ProviderType type) {
    if (_providerType != type) {
      _providerType = type;
      notifyListeners();
    }
  }

  void switchToIndividual() {
    _providerType = ProviderType.individual;
    notifyListeners();
  }

  void switchToCompany({
    String? companyName,
    String? companyId,
    String? staffId,
  }) {
    _providerType = ProviderType.company;
    if (companyName != null && companyName.isNotEmpty) {
      _companyName = companyName;
    }
    if (companyId != null && companyId.isNotEmpty) {
      _companyId = companyId;
    }
    if (staffId != null && staffId.isNotEmpty) {
      _staffId = staffId;
    }
    notifyListeners();
  }

  void toggleProviderType() {
    if (_providerType == ProviderType.individual) {
      switchToCompany();
    } else {
      switchToIndividual();
    }
  }
}
