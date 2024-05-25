import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_sync/models/meal.dart';

class MealPieChart extends StatefulWidget {
  final List<Meal> meals;

  const MealPieChart({super.key, required this.meals});
  @override
  _MealPieChartState createState() => _MealPieChartState();
}

class _MealPieChartState extends State<MealPieChart> {
  List<double> _mealSpots = [];
  double proteinToday = 0, carbsToday = 0, fatToday = 0;
  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    for (var meal in widget.meals) {
      proteinToday += meal.nutritionInformation?.protein ?? 0;
      carbsToday += meal.nutritionInformation?.carbohydrates ?? 0;
      fatToday += meal.nutritionInformation?.fat ?? 0;
    }
    double sum = proteinToday + carbsToday + fatToday;
    double protein = (proteinToday / sum);
    double carbs = (carbsToday / sum);
    double fats = (fatToday / sum);
    setState(() {
      _mealSpots = [protein, carbs, fats];
    });
  }

  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                swapAnimationDuration: Durations.extralong2,
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 15,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      showTitle: true,
                      color: Colors.red,
                      title: "${(_mealSpots[0] * 100).toInt()}%",
                      value: _mealSpots[0],
                      radius: touchedIndex == 0 ? 60.0 : 50.0,
                      titleStyle: TextStyle(
                        fontSize: touchedIndex == 0 ? 25.0 : 16.0,
                        fontWeight: FontWeight.bold,
                        shadows: shadows,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      showTitle: true,
                      color: Colors.amber,
                      title: "${(_mealSpots[1] * 100).toInt()}%",
                      value: _mealSpots[1],
                      radius: touchedIndex == 1 ? 60.0 : 50.0,
                      titleStyle: TextStyle(
                        fontSize: touchedIndex == 1 ? 25.0 : 16.0,
                        fontWeight: FontWeight.bold,
                        shadows: shadows,
                      ),
                    ),
                    PieChartSectionData(
                      showTitle: true,
                      color: Colors.blue,
                      title: "${(_mealSpots[2] * 100).toInt()}%",
                      value: _mealSpots[2],
                      radius: touchedIndex == 2 ? 60.0 : 50.0,
                      titleStyle: TextStyle(
                        fontSize: touchedIndex == 2 ? 25.0 : 16.0,
                        fontWeight: FontWeight.bold,
                        shadows: shadows,
                      ),
                    ),
                  ],
                  titleSunbeamLayout: true,
                  borderData: FlBorderData(show: true),

                  // gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Indicator(
                color: Colors.red,
                text: 'Protein : ${proteinToday}g',
                isSquare: true,
              ),
              const SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.amber,
                text: 'Carbohydrates : ${carbsToday}g',
                isSquare: true,
              ),
              const SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.blue,
                text: 'Fat : ${fatToday}g',
                isSquare: true,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
