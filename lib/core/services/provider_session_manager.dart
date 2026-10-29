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

class ProviderSessionManager extends ChangeNotifier {
  static final ProviderSessionManager _instance =
      ProviderSessionManager._internal();
  factory ProviderSessionManager() => _instance;
  static ProviderSessionManager get instance => _instance;

  ProviderSessionManager._internal();

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

  // Access-Controlled Capability Flags
  bool get canDoJobWorkflow => true;
  bool get canWithdrawMoney => isIndividual;
  bool get requiresLicenceVerification => isIndividual;
  bool get canProvideBankDetails => isIndividual;
  bool get canManageSkills => isIndividual;
  bool get canSelectCoverageAreas => isIndividual;
  bool get isCompanyAssignedOnly => isCompanyProvider;

  // Mutators & Mode Switchers
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

typedef ProviderSessionService = ProviderSessionManager;
