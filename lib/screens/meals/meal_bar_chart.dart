import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:health_sync/models/meal.dart';

class MealBarChart extends StatefulWidget {
  final List<Meal> meals;

  const MealBarChart({super.key, required this.meals});
  @override
  _MealBarChartState createState() => _MealBarChartState();
}

class _MealBarChartState extends State<MealBarChart> {
  List<FlSpot> _mealSpots = [];

  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    List<Meal> meals = widget.meals;
    meals.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
    final List<FlSpot> spots = widget.meals.map((meal) {
      final timestamp = meal.timestamp!.toDate();
      final calories = meal.nutritionInformation?.calories;
      return FlSpot(
        timestamp.millisecondsSinceEpoch.toDouble(),
        calories!.toDouble(),
      );
    }).toList();

    setState(() {
      _mealSpots = spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      swapAnimationDuration: Durations.extralong2,
      BarChartData(
        barGroups: [
          ..._mealSpots.map(
            (meal) => BarChartGroupData(
              barRods: [BarChartRodData(fromY: 0, toY: meal.y, width: 10)],
              x: meal.x.toInt(),
              barsSpace: 20,
            ),
          ),
        ],
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text('${date.hour}:${date.minute}');
                }),
          ),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }
}
