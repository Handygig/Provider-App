import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';
import 'package:provider_app/src/domain/usecases/coverage/coverage_usecases.dart';
import 'package:provider_app/src/presentation/cubits/coverage/coverage_state.dart';

class CoverageCubit extends Cubit<CoverageState> {
  final GetCoverageUseCase getCoverageUseCase;
  final UpdateCoverageUseCase updateCoverageUseCase;
  final ToggleAvailabilityUseCase toggleAvailabilityUseCase;

  WorkingHoursCoverageEntity _coverage = const WorkingHoursCoverageEntity();

  CoverageCubit({
    required this.getCoverageUseCase,
    required this.updateCoverageUseCase,
    required this.toggleAvailabilityUseCase,
  }) : super(const CoverageInitial());

  WorkingHoursCoverageEntity get coverage => _coverage;
  bool get isAvailableNow => _coverage.isAvailableNow;

  Future<void> loadCoverage({bool silent = false}) async {
    if (!silent) {
      emit(const CoverageLoading());
    }

    final result = await getCoverageUseCase(NoParams());
    result.fold(
      (failure) => emit(CoverageError(failure.errorMessage)),
      (data) {
        _coverage = data;
        emit(CoverageLoaded(_coverage));
      },
    );
  }

  Future<bool> toggleLiveRadar(bool isAvailable) async {
    final previous = _coverage;
    _coverage = _coverage.copyWith(isAvailableNow: isAvailable);
    emit(CoverageLoaded(_coverage));

    final result = await toggleAvailabilityUseCase(isAvailable);
    return result.fold(
      (failure) {
        _coverage = previous;
        emit(CoverageError(failure.errorMessage));
        emit(CoverageLoaded(_coverage));
        return false;
      },
      (success) {
        emit(CoverageActionSuccess(
            isAvailable ? 'Radar Activated: You are online' : 'You are now offline'));
        emit(CoverageLoaded(_coverage));
        return true;
      },
    );
  }

  Future<bool> saveCoverage(WorkingHoursCoverageEntity newCoverage) async {
    emit(const CoverageLoading());
    final result = await updateCoverageUseCase(newCoverage);
    return result.fold(
      (failure) {
        emit(CoverageError(failure.errorMessage));
        emit(CoverageLoaded(_coverage));
        return false;
      },
      (saved) {
        _coverage = saved;
        emit(const CoverageActionSuccess('Coverage settings saved successfully'));
        emit(CoverageLoaded(_coverage));
        return true;
      },
    );
  }
}
