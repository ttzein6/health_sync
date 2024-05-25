import 'package:flutter/material.dart';
import 'package:health_sync/models/health_data.dart';

class HealthDetailsScreen extends StatelessWidget {
  final HealthData healthData;

  const HealthDetailsScreen({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metric: ${healthData.metric}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Value: ${healthData.value}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Timestamp: ${healthData.timestamp}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('User ID: ${healthData.id}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
