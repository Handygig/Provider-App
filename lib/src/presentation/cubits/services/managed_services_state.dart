import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';

abstract class ManagedServicesState extends Equatable {
  const ManagedServicesState();

  @override
  List<Object?> get props => [];
}

class ManagedServicesInitial extends ManagedServicesState {
  const ManagedServicesInitial();
}

class ManagedServicesLoading extends ManagedServicesState {
  const ManagedServicesLoading();
}

class ManagedServicesLoaded extends ManagedServicesState {
  final List<ServiceSkillEntity> services;
  final List<ServiceSkillEntity> catalog;

  const ManagedServicesLoaded({
    required this.services,
    this.catalog = const [],
  });

  @override
  List<Object?> get props => [services, catalog];
}

class ManagedServicesActionSuccess extends ManagedServicesState {
  final String message;

  const ManagedServicesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ManagedServicesError extends ManagedServicesState {
  final String message;

  const ManagedServicesError(this.message);

  @override
  List<Object?> get props => [message];
}
