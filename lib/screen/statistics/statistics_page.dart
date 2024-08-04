import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class StatisticViewController extends GetxController {
  var selectedYear = DateTime.now().year;
  var selectedMonth = DateTime.now().month;

  List<dynamic> stressScores;

  StatisticViewController(this.stressScores);

  void updateYear(int year) {
    selectedYear = year;
    update();
  }

  void updateMonth(int month) {
    selectedMonth = month;
    update();
  }

  List<FlSpot> getFilteredSpots() {
    List<FlSpot> spots = [];
    List<dynamic> filteredScores = stressScores.where((score) {
      DateTime date = DateTime.parse(score['date']);
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    for (var score in filteredScores) {
      DateTime date = DateTime.parse(score['date']);
      spots.add(FlSpot(date.day.toDouble(), score['score'].toDouble()));
    }

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  String getAnalysis() {
    List<dynamic> filteredScores = stressScores.where((score) {
      DateTime date = DateTime.parse(score['date']);
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    if (filteredScores.length < 5) return '데이터가 부족합니다.';

    double averageScore =
        filteredScores.map((e) => e['score']).reduce((a, b) => a + b) /
            filteredScores.length;

    int highStressDays =
        filteredScores.where((score) => score['score'] > 70).length;
    int lowStressDays =
        filteredScores.where((score) => score['score'] < 30).length;
    int steepIncreaseDays = 0;

    double maxSlope = double.negativeInfinity;
    double minSlope = double.infinity;
    double maxSlopeValue = 0;
    double minSlopeValue = 0;
    DateTime maxSlopeStart = DateTime.now();
    DateTime maxSlopeEnd = DateTime.now();
    DateTime minSlopeStart = DateTime.now();
    DateTime minSlopeEnd = DateTime.now();

    List<FlSpot> spots = getFilteredSpots();
    for (int i = 1; i < spots.length; i++) {
      double slope =
          (spots[i].y - spots[i - 1].y) / (spots[i].x - spots[i - 1].x);
      if (slope > maxSlope) {
        maxSlope = slope;
        maxSlopeValue = spots[i].y;
        maxSlopeStart =
            DateTime(selectedYear, selectedMonth, spots[i - 1].x.toInt());
        maxSlopeEnd = DateTime(selectedYear, selectedMonth, spots[i].x.toInt());
      }
      if (slope < minSlope) {
        minSlope = slope;
        minSlopeValue = spots[i].y;
        minSlopeStart =
            DateTime(selectedYear, selectedMonth, spots[i - 1].x.toInt());
        minSlopeEnd = DateTime(selectedYear, selectedMonth, spots[i].x.toInt());
      }
      if (slope > 10) {
        steepIncreaseDays++;
      }
    }

    double maxStress = filteredScores
        .map((e) => e['score'])
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    double minStress = filteredScores
        .map((e) => e['score'])
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    int maxStressDay = int.parse(filteredScores
        .firstWhere((e) => e['score'] == maxStress)['date']
        .split('-')[2]);
    int minStressDay = int.parse(filteredScores
        .firstWhere((e) => e['score'] == minStress)['date']
        .split('-')[2]);

    return '이번 달 평균 스트레스 점수는 ${averageScore.toStringAsFixed(1)}점입니다.\n'
        '스트레스가 가장 높은 날은 $maxStressDay일, 가장 낮은 날은 $minStressDay일입니다.\n'
        '스트레스 기울기가 가장 높은 기간은 ${maxSlopeStart.day}일 ~ ${maxSlopeEnd.day}일, '
        '스트레스 기울기가 가장 낮은 기간은 ${minSlopeStart.day}일 ~ ${minSlopeEnd.day}일입니다.';
  }
}

class StatisticsPage extends StatelessWidget {
  final List<dynamic> stressScores;

  const StatisticsPage({super.key, required this.stressScores});

  @override
  Widget build(BuildContext context) {
    final StatisticViewController controller =
        Get.put(StatisticViewController(stressScores));

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                GetBuilder<StatisticViewController>(
                  builder: (controller) {
                    return DropdownButton<int>(
                      dropdownColor: Colors.black,
                      value: controller.selectedYear,
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
                        if (value != null) {
                          controller.updateYear(value);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 16),
                GetBuilder<StatisticViewController>(
                  builder: (controller) {
                    return DropdownButton<int>(
                      dropdownColor: Colors.black,
                      value: controller.selectedMonth,
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
                        if (value != null) {
                          controller.updateMonth(value);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GetBuilder<StatisticViewController>(
                builder: (controller) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 300, // 고정 높이를 설정하여 그래프 크기를 줄임
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 10,
                              verticalInterval: 10,
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
                                  reservedSize: 42, // x축 레이블의 간격을 늘림
                                  interval: 5,
                                  getTitlesWidget: (value, meta) {
                                    int day = value.toInt();
                                    if (day > 30) {
                                      return const Text('');
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        day.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 56, // y축 레이블의 간격을 늘림
                                  interval: 10, // y축 간격을 10점 단위로 설정
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border:
                                  Border.all(color: const Color(0xff37434d)),
                            ),
                            minX: 1,
                            maxX: 31,
                            minY: 0,
                            maxY: 100, // 스트레스 점수의 만점은 100점
                            lineBarsData: [
                              LineChartBarData(
                                spots: controller.getFilteredSpots(),
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
                      const SizedBox(height: 20),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Text(
                            controller.getAnalysis(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.start,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
