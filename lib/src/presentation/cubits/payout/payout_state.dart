import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';

abstract class PayoutState extends Equatable {
  const PayoutState();

  @override
  List<Object?> get props => [];
}

class PayoutInitial extends PayoutState {
  const PayoutInitial();
}

class PayoutLoading extends PayoutState {
  const PayoutLoading();
}

class PayoutLoaded extends PayoutState {
  final List<BankAccountEntity> accounts;
  final BankAccountEntity? primaryAccount;

  const PayoutLoaded(this.accounts, {this.primaryAccount});

  @override
  List<Object?> get props => [accounts, primaryAccount];
}

class PayoutActionSuccess extends PayoutState {
  final String message;

  const PayoutActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PayoutError extends PayoutState {
  final String message;

  const PayoutError(this.message);

  @override
  List<Object?> get props => [message];
}
