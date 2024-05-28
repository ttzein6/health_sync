import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_sync/blocs/health_data/health_data_bloc.dart';
import 'package:health_sync/utils/validators.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthSummaryScreen extends StatefulWidget {
  const HealthSummaryScreen({super.key});

  @override
  _HealthSummaryScreenState createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HealthDataBloc>().add(LoadHealthData());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Summary'),
      ),
      body: SafeArea(
        child: BlocBuilder<HealthDataBloc, HealthDataState>(
          builder: (context, state) {
            if (state is HealthDataInitial ||
                state is HealthDataLoading ||
                state is FetchingHealthData) {
              return MaterialButton(
                onPressed: () {
                  context.read<HealthDataBloc>().add(LoadHealthData());
                },
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            } else if (state is HealthDataLoaded) {
              return _buildChartContent(state);
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildChartContent(HealthDataLoaded state) {
    // _healthDataList.where((data) => data.type == HealthDataType.STEPS).map(
    //       (data) {},
    //     );
    List<HealthDataPoint> healthData = state.healthData;
    int totalStepsToday = state.nbOfStepsToday;
    int activeEnergyBurntToday = state.activeEnergyBurnedToday;
    // return Text("DATA LENGTH FETCHED : ${{_healthDataList.length}}");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return ListView(
          // mainAxisAlignment: MainAxisAlignment.,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                const Text("Steps Today ", style: TextStyle(fontSize: 24)),
                Text("Total Steps Today: $totalStepsToday",
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              height: 400,
              width: constraints.maxWidth,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // interval: 1,
                        reservedSize: 50,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.isNaN || value.isInfinite) {
                            return defaultGetTitle(value, meta);
                          }
                          var dateTime = DateTime.fromMillisecondsSinceEpoch(
                              value.round());

                          return Text("${dateTime.hour}:${dateTime.minute}");
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: healthData
                          .where((data) =>
                              data.type == HealthDataType.STEPS &&
                              data.value.toJson()['numeric_value'] != null)
                          .map(
                        (data) {
                          double value = double.tryParse(data.value
                                  .toJson()['numeric_value']
                                  .toString()) ??
                              0;
                          if (value.isNaN || value.isInfinite) {
                            value = 0;
                          }
                          return FlSpot(
                            data.dateFrom.millisecondsSinceEpoch.toDouble(),
                            value,
                          );
                        },
                      ).toList(),
                      isCurved: false,
                      // barWidth: 4,
                      // colors: [Colors.blue],
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Card(
              elevation: 5,
              color: Theme.of(context).colorScheme.tertiary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Active Energy Burned Today",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    Text(
                      "$activeEnergyBurntToday",
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
  // Widget _buildAuthenticateButton() {
  //   return Center(
  //     child: TextButton(
  //       onPressed: _authorize,
  //       style: ButtonStyle(
  //         backgroundColor: MaterialStateProperty.all(Colors.blue),
  //       ),
  //       child:
  //           const Text("Authenticate", style: TextStyle(color: Colors.white)),
  //     ),
  //   );
  // }

  // Widget _buildLoadingOrErrorContent() {
  //   switch (_state) {
  //     case AppState.FETCHING_DATA:
  //       return const Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           CircularProgressIndicator(strokeWidth: 10),
  //           SizedBox(height: 20),
  //           Text('Fetching data...'),
  //         ],
  //       );
  //     case AppState.NO_DATA:
  //       return const Center(child: Text('No Data to show'));
  //     case AppState.AUTH_NOT_GRANTED:
  //       return const Center(child: Text('Authorization not granted'));
  //     case AppState.DATA_NOT_ADDED:
  //       return const Center(
  //           child: Text('Failed to add data. Check permissions.'));

  //     default:
  //       return const Center(child: Text('Unknown state'));
  //   }
  // }

 
