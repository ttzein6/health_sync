part of 'health_data_bloc.dart';

abstract class HealthDataState {}

class HealthDataInitial extends HealthDataState {}

class HealthDataLoading extends HealthDataState {}

class HealthDataLoaded extends HealthDataState {
  final List<HealthData> healthData;
  HealthDataLoaded(this.healthData);
}

class HealthDataError extends HealthDataState {
  final String error;
  HealthDataError(this.error);
}
