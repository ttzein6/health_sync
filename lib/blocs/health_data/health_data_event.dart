part of 'health_data_bloc.dart';

abstract class HealthDataEvent {}

class LoadHealthData extends HealthDataEvent {}

class AuthorizeHealth extends HealthDataEvent {}

class FetchData extends HealthDataEvent {}
// class AddHealthData extends HealthDataEvent {
//   final HealthData healthData;
//   AddHealthData(this.healthData);
// }
