part of 'health_data_bloc.dart';

abstract class HealthDataState {}

class HealthDataInitial extends HealthDataState {}

class HealthDataLoading extends HealthDataState {}

class HealthDataAuthorized extends HealthDataState {}

class HealthDataNotAuthorized extends HealthDataState {}

class FetchingHealthData extends HealthDataState {}

class HealthDataLoaded extends HealthDataState {
  final List<HealthDataPoint> healthData;
  final int activeEnergyBurnedToday;
  final int nbOfStepsToday;

  HealthDataLoaded(
      {required this.healthData,
      this.activeEnergyBurnedToday = 0,
      this.nbOfStepsToday = 0});
}

class HealthDataError extends HealthDataState {
  final String error;
  HealthDataError(this.error);
}
