import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';
import 'package:provider_app/src/domain/usecases/services/managed_services_usecases.dart';
import 'package:provider_app/src/presentation/cubits/services/managed_services_state.dart';

class ManagedServicesCubit extends Cubit<ManagedServicesState> {
  final GetManagedServicesUseCase getServicesUseCase;
  final GetAvailableCatalogUseCase getCatalogUseCase;
  final UpdateManagedServicesUseCase updateServicesUseCase;
  final RequestCustomCategoryUseCase requestCustomCategoryUseCase;

  List<ServiceSkillEntity> _services = const [];
  List<ServiceSkillEntity> _catalog = const [];

  ManagedServicesCubit({
    required this.getServicesUseCase,
    required this.getCatalogUseCase,
    required this.updateServicesUseCase,
    required this.requestCustomCategoryUseCase,
  }) : super(const ManagedServicesInitial());

  List<ServiceSkillEntity> get allServices => _services;
  List<ServiceSkillEntity> get activeServices =>
      _services.where((s) => s.isEnabled).toList();
  List<ServiceSkillEntity> get catalog => _catalog;

  String get activeServicesSummary {
    final activeTitles = activeServices.map((s) => s.category).toList();
    if (activeTitles.isEmpty) return 'No Active Services';
    return activeTitles.join(', ');
  }

  Future<void> loadCatalog() async {
    final catalogResult = await getCatalogUseCase(NoParams());
    catalogResult.fold(
      (_) {},
      (catalogList) {
        _catalog = catalogList;
        emit(ManagedServicesLoaded(
          services: List.unmodifiable(_services),
          catalog: List.unmodifiable(_catalog),
        ));
      },
    );
  }

  Future<bool> saveServices(List<ServiceSkillEntity> services) async {
    _services = services;
    emit(ManagedServicesLoaded(
      services: List.unmodifiable(_services),
      catalog: List.unmodifiable(_catalog),
    ));

    final result = await updateServicesUseCase(services);
    return result.fold(
      (failure) {
        emit(ManagedServicesError(failure.errorMessage));
        return false;
      },
      (savedList) {
        _services = savedList;
        emit(ManagedServicesLoaded(
          services: List.unmodifiable(_services),
          catalog: List.unmodifiable(_catalog),
        ));
        return true;
      },
    );
  }

  Future<void> loadServices({bool silent = false}) async {
    if (!silent) {
      emit(const ManagedServicesLoading());
    }

    final servicesResult = await getServicesUseCase(NoParams());
    final catalogResult = await getCatalogUseCase(NoParams());

    servicesResult.fold(
      (failure) => emit(ManagedServicesError(failure.errorMessage)),
      (servicesList) {
        _services = servicesList;
        catalogResult.fold(
          (_) {
            emit(ManagedServicesLoaded(
              services: List.unmodifiable(_services),
              catalog: List.unmodifiable(_catalog),
            ));
          },
          (catalogList) {
            _catalog = catalogList;
            emit(ManagedServicesLoaded(
              services: List.unmodifiable(_services),
              catalog: List.unmodifiable(_catalog),
            ));
          },
        );
      },
    );
  }

  Future<bool> toggleService(String serviceId, bool isEnabled) async {
    final updated = _services.map((s) {
      if (s.id == serviceId) {
        return s.copyWith(isEnabled: isEnabled);
      }
      return s;
    }).toList();

    _services = updated;
    emit(ManagedServicesLoaded(
      services: List.unmodifiable(_services),
      catalog: List.unmodifiable(_catalog),
    ));

    final result = await updateServicesUseCase(updated);
    return result.fold(
      (failure) {
        emit(ManagedServicesError(failure.errorMessage));
        return false;
      },
      (savedList) {
        _services = savedList;
        emit(ManagedServicesLoaded(
          services: List.unmodifiable(_services),
          catalog: List.unmodifiable(_catalog),
        ));
        return true;
      },
    );
  }

  Future<bool> updateServiceRate(String serviceId, double newRate) async {
    final updated = _services.map((s) {
      if (s.id == serviceId) {
        return s.copyWith(baseRatePerHour: newRate);
      }
      return s;
    }).toList();

    _services = updated;
    emit(ManagedServicesLoaded(
      services: List.unmodifiable(_services),
      catalog: List.unmodifiable(_catalog),
    ));

    final result = await updateServicesUseCase(updated);
    return result.isRight();
  }

  Future<bool> requestCategory({
    required String name,
    required String notes,
  }) async {
    final result = await requestCustomCategoryUseCase(
      RequestCustomCategoryParams(categoryName: name, notes: notes),
    );
    return result.fold(
      (failure) {
        emit(ManagedServicesError(failure.errorMessage));
        return false;
      },
      (_) {
        emit(const ManagedServicesActionSuccess(
            'Category request submitted successfully'));
        emit(ManagedServicesLoaded(
          services: List.unmodifiable(_services),
          catalog: List.unmodifiable(_catalog),
        ));
        return true;
      },
    );
  }
}
