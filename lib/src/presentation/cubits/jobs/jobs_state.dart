import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  final List<JobEntity> allJobs;
  final JobCategory selectedCategory;
  final String searchQuery;
  final JobEntity? activeJobDetails;

  const JobsLoaded({
    required this.allJobs,
    this.selectedCategory = JobCategory.toQuote,
    this.searchQuery = '',
    this.activeJobDetails,
  });

  List<JobEntity> get filteredJobs {
    return allJobs.where((j) {
      if (j.status != selectedCategory) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return j.serviceTitle.toLowerCase().contains(q) ||
            j.customerName.toLowerCase().contains(q) ||
            j.category.toLowerCase().contains(q) ||
            j.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  int countForCategory(JobCategory category) {
    return allJobs.where((j) => j.status == category).length;
  }

  JobsLoaded copyWith({
    List<JobEntity>? allJobs,
    JobCategory? selectedCategory,
    String? searchQuery,
    JobEntity? activeJobDetails,
  }) {
    return JobsLoaded(
      allJobs: allJobs ?? this.allJobs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      activeJobDetails: activeJobDetails ?? this.activeJobDetails,
    );
  }

  @override
  List<Object?> get props =>
      [allJobs, selectedCategory, searchQuery, activeJobDetails];
}

class JobsActionSuccess extends JobsState {
  final String message;

  const JobsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}
