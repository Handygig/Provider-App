import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';

abstract class CoverageState extends Equatable {
  const CoverageState();

  @override
  List<Object?> get props => [];
}

class CoverageInitial extends CoverageState {
  const CoverageInitial();
}

class CoverageLoading extends CoverageState {
  const CoverageLoading();
}

class CoverageLoaded extends CoverageState {
  final WorkingHoursCoverageEntity coverage;

  const CoverageLoaded(this.coverage);

  @override
  List<Object?> get props => [coverage];
}

class CoverageActionSuccess extends CoverageState {
  final String message;

  const CoverageActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CoverageError extends CoverageState {
  final String message;

  const CoverageError(this.message);

  @override
  List<Object?> get props => [message];
}
