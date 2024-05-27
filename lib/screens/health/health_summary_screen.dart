// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/health_data/health_data_bloc.dart';

class HealthSummaryScreen extends StatelessWidget {
  const HealthSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthDataBloc = BlocProvider.of<HealthDataBloc>(context);
    healthDataBloc
        .add(LoadHealthData()); // Replace 'user_id' with actual user ID

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Summary')),
        body: BlocBuilder<HealthDataBloc, HealthDataState>(
          builder: (context, state) {
            return const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.face_retouching_natural_outlined),
                  Text(" Coming Soon!"),
                ],
              ),
            );
            if (state is HealthDataLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (state is HealthDataLoaded) {
              if (state.healthData.isEmpty) {
                return const Center(
                  child: Text("No Health Data"),
                );
              }
              return ListView.builder(
                itemCount: state.healthData.length,
                itemBuilder: (context, index) {
                  final data = state.healthData[index];
                  return ListTile(
                    title: Text('Health Metric: ${data.metric}'),
                    subtitle: Text('Value: ${data.value}'),
                  );
                },
              );
              // return TwoPane(
              //   startPane: Container(
              //     color: Colors.red,
              //   ),
              //   endPane: Container(
              //     color: Colors.blue,
              //   ),
              //   startPaneFixedWidth: 400,
              //   panePriority: constraints.maxWidth > 600
              //       ? PanePriority.proportion
              //       : PanePriority.start,
              // );
            } else if (state is HealthDataError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const Center(child: Text('No Data'));
            }
          },
        ),
      );
    });
  }
}
