import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/models/health_data.dart';

import 'package:health_sync/repositories/health_data_repository.dart';
part 'health_data_event.dart';
part 'health_data_state.dart';

class HealthDataBloc extends Bloc<HealthDataEvent, HealthDataState> {
  final HealthDataRepository healthDataRepository;

  HealthDataBloc(this.healthDataRepository) : super(HealthDataInitial()) {
    on<HealthDataEvent>(
      (event, emit) async {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        if (event is LoadHealthData) {
          emit(HealthDataLoading());
          try {
            final healthData =
                await healthDataRepository.getHealthData(userId).first;
            emit(HealthDataLoaded(healthData));
          } catch (e) {
            emit(HealthDataError(e.toString()));
          }
        } else if (event is AddHealthData) {
          try {
            await healthDataRepository.addHealthData(userId, event.healthData);
          } catch (e) {
            emit(HealthDataError(e.toString()));
          }
        }
      },
    );
  }
}
