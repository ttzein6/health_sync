import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

import 'package:health_sync/repositories/health_data_repository.dart';
import 'package:permission_handler/permission_handler.dart';
part 'health_data_event.dart';
part 'health_data_state.dart';

List<HealthDataType> get types => Platform.isAndroid || Platform.isIOS
    ? [
        HealthDataType.STEPS,
        HealthDataType.WORKOUT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ]
    : [];
List<HealthDataAccess> get permissions =>
    types.map((e) => HealthDataAccess.READ).toList();

class HealthDataBloc extends Bloc<HealthDataEvent, HealthDataState> {
  final HealthDataRepository healthDataRepository;
  List<HealthDataPoint> _healthDataList = [];
  Health health = Health();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  HealthDataBloc(this.healthDataRepository) : super(HealthDataInitial()) {
    on<LoadHealthData>((event, emit) async {
      log("LoadHealthData");
      // emit(HealthDataLoading());

      try {
        health.configure(useHealthConnectIfAvailable: true);
      } catch (e) {
        log("LoadHealthData Configuration Error : $e ");
      }
      log("LoadHealthData Configured ");
      add(AuthorizeHealth());
    });
    on<AuthorizeHealth>((event, emit) async {
      log("AuthorizeHealth");
      await Permission.activityRecognition.request().whenComplete(() async {
        await Permission.location.request().whenComplete(() async {
          bool? hasPermissions =
              await health.hasPermissions(types, permissions: permissions);

          hasPermissions = hasPermissions == false;
          log("AuthorizeHealth Persmi: $hasPermissions");
          bool authorized = false;
          if (!hasPermissions) {
            try {
              authorized = await health.requestAuthorization(types,
                  permissions: permissions);
            } catch (error) {
              debugPrint("Exception in authorize: $error");
            }
          }
          emit(authorized ? HealthDataAuthorized() : HealthDataNotAuthorized());
          add(FetchData());
        });
      });
    });
    on<FetchData>((event, emit) async {
      // setState(() => _state = AppState.FETCHING_DATA);
      emit(FetchingHealthData());
      int activeEnergyBurnedToday = 0;
      int nbOfStepsToday = 0;
      List<HealthDataPoint> stepsData = [];
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      _healthDataList.clear();

      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          types: types,
          startTime: yesterday,
          endTime: now,
        );

        debugPrint('Total number of data points: ${healthData.length}. '
            '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');

        _healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        debugPrint("Exception in getHealthDataFromTypes: $error");
      }

      _healthDataList = health.removeDuplicates(_healthDataList);
      await _fetchStepData.call().then((value) {
        nbOfStepsToday = value.$1 ?? 0;
        stepsData = value.$2;
      });

      activeEnergyBurnedToday = (await _fetchActiveEnergy()) ?? 0;

      emit(HealthDataLoaded(
        healthData: _healthDataList,
        nbOfStepsToday: nbOfStepsToday,
        stepsData: stepsData,
        activeEnergyBurnedToday: activeEnergyBurnedToday,
      ));
    });
  }

  Future<(int?, List<HealthDataPoint>)> _fetchStepData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // bool stepsPermission =
    //     await health.hasPermissions([HealthDataType.STEPS]) ?? false;
    // if (!stepsPermission) {
    //   stepsPermission = await health.requestAuthorization(
    //       [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED]);
    // }

    // if (stepsPermission) {
    try {
      int? steps = await health.getTotalStepsInInterval(midnight, now);
      debugPrint('Total number of steps: $steps');
      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS], startTime: midnight, endTime: now);

      return (steps, stepsData);
    } catch (error) {
      debugPrint("Exception in getTotalStepsInInterval: $error");
    }
    // }
    return (null, <HealthDataPoint>[]);
  }

  Future<int?> _fetchActiveEnergy() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // bool stepsPermission =
    //     await health.hasPermissions([HealthDataType.ACTIVE_ENERGY_BURNED]) ??
    //         false;
    // if (!stepsPermission) {
    //   stepsPermission = await health
    //       .requestAuthorization([HealthDataType.ACTIVE_ENERGY_BURNED]);
    // }

    // if (stepsPermission) {
    try {
      int? energyBurnt = await health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: DateTime.now(),
      ).then((value) {
        int eng = 0;
        for (var v in value) {
          eng += double.parse(v.value.toJson()['numeric_value'].toString())
              .toInt();
        }
        return eng;
      });
      debugPrint('Total number of energyBurnt: $energyBurnt');

      // setState(() {
      //   _nofSteps = steps ?? 0;
      //   _state = steps == null ? AppState.NO_DATA : AppState.STEPS_READY;
      // });
      return energyBurnt ?? 0;
    } catch (error) {
      debugPrint("Exception in getTotalStepsInInterval: $error");
    }
    // }
    return null;
  }

  // Future<void> _getHealthConnectSdkStatus() async {
  //   assert(Platform.isAndroid, "This is only available on Android");

  //   final status = await health.getHealthConnectSdkStatus();

  //   setState(() {
  //     _contentHealthConnectStatus = Text('Health Connect Status: $status');
  //     _state = AppState.HEALTH_CONNECT_STATUS;
  //   });
  // }

  // Future<void> _addData() async {
  //   final now = DateTime.now();
  //   final earlier = now.subtract(const Duration(minutes: 20));

  //   bool success = true;

  //   success &= await health.writeHealthData(
  //       value: 1.925,
  //       type: HealthDataType.HEIGHT,
  //       startTime: earlier,
  //       endTime: now);
  //   success &= await Health().writeHealthData(
  //       value: 90, type: HealthDataType.WEIGHT, startTime: now);

  //   setState(() {
  //     _state = success ? AppState.DATA_ADDED : AppState.DATA_NOT_ADDED;
  //   });
  // }

  // Future<void> _revokeAccess() async {
  //   try {
  //     await Health().revokePermissions();
  //   } catch (error) {
  //     debugPrint("Exception in revokeAccess: $error");
  //   }
  // }
}
