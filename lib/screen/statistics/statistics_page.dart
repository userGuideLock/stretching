import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class StatisticsPage extends StatefulWidget {
  final List<dynamic> stressScores;

  const StatisticsPage({super.key, required this.stressScores});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<dynamic> filteredScores = widget.stressScores.where((score) {
      DateTime date = DateTime.parse(score['date']);
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    Map<int, List<double>> groupedScores = {};

    for (var score in filteredScores) {
      DateTime date = DateTime.parse(score['date']);
      int dayGroup = ((date.day - 1) ~/ 5) * 5 + 1;
      if (!groupedScores.containsKey(dayGroup)) {
        groupedScores[dayGroup] = [];
      }
      groupedScores[dayGroup]!.add(score['score'].toDouble());
    }

    groupedScores.forEach((dayGroup, scores) {
      double avgScore = scores.reduce((a, b) => a + b) / scores.length;
      spots.add(FlSpot(dayGroup.toDouble(), avgScore));
    });

    spots.sort((a, b) => a.x.compareTo(b.x));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '스트레칭',
                style: TextStyle(
                  color: Color(0xffacdcb4),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.close),
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: () {
                Get.to(() => const BottomNavigation());
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '스트레스 점수 그래프',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  dropdownColor: Colors.black,
                  value: selectedYear,
                  items: List.generate(5, (index) {
                    int year = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  dropdownColor: Colors.black,
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    int month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(
                        month.toString().padLeft(2, '0'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          int day = value.toInt();
                          return Text(day.toString(),
                              style: const TextStyle(color: Colors.white));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style: const TextStyle(color: Colors.white));
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 1,
                  maxX: 31,
                  minY: 0,
                  maxY: 100, // 스트레스 점수의 만점은 100점
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [
                          Colors.greenAccent,
                          Colors.blueAccent,
                        ],
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent.withOpacity(0.3),
                            Colors.blueAccent.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
