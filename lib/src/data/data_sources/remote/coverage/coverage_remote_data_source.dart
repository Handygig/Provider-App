import 'package:provider_app/src/data/models/coverage/working_hours_coverage_model.dart';

abstract class CoverageRemoteDataSource {
  Future<WorkingHoursCoverageModel> getCoverage();
  Future<WorkingHoursCoverageModel> updateCoverage(
      WorkingHoursCoverageModel coverage);
  Future<bool> toggleAvailability(bool isAvailable);
}
