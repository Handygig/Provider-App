import 'package:provider_app/src/data/models/services/service_skill_model.dart';

abstract class ManagedServicesRemoteDataSource {
  Future<List<ServiceSkillModel>> getServices();
  Future<List<ServiceSkillModel>> getAvailableCatalog();
  Future<List<ServiceSkillModel>> updateServices(List<ServiceSkillModel> services);
  Future<void> requestCustomCategory({
    required String categoryName,
    required String notes,
  });
}
