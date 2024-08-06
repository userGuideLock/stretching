import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:http/http.dart' as http;

class StatisticViewController extends GetxController {
  var selectedYear = DateTime.now().year;
  var selectedMonth = DateTime.now().month;

  List<dynamic> stressScores;

  // 전역 변수로 사용할 값들
  double averageScore = 0.0;
  int highStressDay = 0;
  int lowStressDay = 0;
  double highStressScore = 0.0;
  double lowStressScore = 0.0;
  double maxSlope = 0.0;
  double minSlope = 0.0;
  DateTime maxSlopeStart = DateTime.now();
  DateTime maxSlopeEnd = DateTime.now();
  DateTime minSlopeStart = DateTime.now();
  DateTime minSlopeEnd = DateTime.now();

  StatisticViewController(this.stressScores);

  void updateYear(int year) {
    selectedYear = year;
    calculateStatistics();
    update();
  }

  void updateMonth(int month) {
    selectedMonth = month;
    calculateStatistics();
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

  void calculateStatistics() {
    List<dynamic> filteredScores = stressScores.where((score) {
      DateTime date = DateTime.parse(score['date']);
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    if (filteredScores.isEmpty) {
      averageScore = 0.0;
      highStressDay = 0;
      lowStressDay = 0;
      highStressScore = 0.0;
      lowStressScore = 0.0;
      maxSlope = 0.0;
      minSlope = 0.0;
      return;
    }

    averageScore =
        filteredScores.map((e) => e['score']).reduce((a, b) => a + b) /
            filteredScores.length;
    double maxStress = filteredScores
        .map((e) => e['score'])
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    double minStress = filteredScores
        .map((e) => e['score'])
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    highStressDay = int.parse(filteredScores
        .firstWhere((e) => e['score'] == maxStress)['date']
        .split('-')[2]);
    lowStressDay = int.parse(filteredScores
        .firstWhere((e) => e['score'] == minStress)['date']
        .split('-')[2]);
    highStressScore = maxStress;
    lowStressScore = minStress;

    List<FlSpot> spots = getFilteredSpots();
    maxSlope = double.negativeInfinity;
    minSlope = double.infinity;

    for (int i = 1; i < spots.length; i++) {
      double slope =
          (spots[i].y - spots[i - 1].y) / (spots[i].x - spots[i - 1].x);
      if (slope > maxSlope) {
        maxSlope = slope;
        maxSlopeStart =
            DateTime(selectedYear, selectedMonth, spots[i - 1].x.toInt());
        maxSlopeEnd = DateTime(selectedYear, selectedMonth, spots[i].x.toInt());
      }
      if (slope < minSlope) {
        minSlope = slope;
        minSlopeStart =
            DateTime(selectedYear, selectedMonth, spots[i - 1].x.toInt());
        minSlopeEnd = DateTime(selectedYear, selectedMonth, spots[i].x.toInt());
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    calculateStatistics();
  }

  String getScoreRangeAnalysis() {
    if (stressScores.isEmpty) return '데이터가 부족합니다.';

    List<int> scoreRanges = List.filled(10, 0);

    List<dynamic> filteredScores = stressScores.where((score) {
      DateTime date = DateTime.parse(score['date']);
      return date.year == selectedYear && date.month == selectedMonth;
    }).toList();

    for (var score in filteredScores) {
      int rangeIndex = (score['score'] / 10).floor();
      scoreRanges[rangeIndex]++;
    }

    String analysis = '';
    for (int i = 0; i < scoreRanges.length; i++) {
      analysis += '${i * 10} - ${(i + 1) * 10 - 1}점: ${scoreRanges[i]}일\n';
    }
    return analysis;
  }

  String getScoreAdvice() {
    if (averageScore < 10) {
      return '매우 좋은 상태입니다. 스트레스가 거의 없으며, 일상 생활에서 매우 안정적인 상태를 유지하고 있습니다. 이러한 상태를 유지하기 위해 현재의 라이프스타일과 스트레스 관리 방법을 계속해서 실천하세요. 규칙적인 운동과 충분한 수면을 유지하고, 건강한 식습관을 지속하세요. 또한, 마음의 평화를 유지하기 위해 명상이나 호흡 운동 같은 추가적인 스트레스 관리 방법을 도입하는 것도 좋습니다. 이렇게 함으로써 감정적인 균형을 유지하고, 스트레스 상황에서도 차분함을 유지할 수 있습니다.';
    } else if (averageScore < 20) {
      return '좋은 상태입니다. 약간의 스트레스가 있지만 전반적으로 잘 관리되고 있습니다. 현재의 스트레스 관리 방법을 지속하면서 스트레스를 완화할 수 있는 추가적인 방법들을 찾아보세요. 예를 들어, 명상이나 요가와 같은 활동을 추가적으로 해보는 것도 좋습니다. 이러한 활동은 심신의 안정과 집중력을 향상시키는 데 도움이 될 수 있습니다. 또한, 규칙적인 운동과 충분한 수면은 스트레스 수준을 낮추고 전반적인 건강을 증진시킵니다.';
    } else if (averageScore < 30) {
      return '양호한 상태입니다. 스트레스가 조금 더 증가하고 있지만 여전히 잘 관리되고 있습니다. 스트레스가 더 쌓이지 않도록 주의가 필요합니다. 주기적으로 휴식을 취하고, 스트레스 상황에서 벗어날 수 있는 방법을 찾아보세요. 일상의 작은 변화가 큰 도움이 될 수 있습니다. 예를 들어, 일정한 시간에 운동을 하거나, 건강한 식단을 유지하는 것도 도움이 됩니다. 또한, 명상이나 깊은 호흡 운동을 통해 긴장을 풀어보세요.';
    } else if (averageScore < 40) {
      return '보통 상태입니다. 스트레스가 다소 증가하고 있으며, 스트레스 관리가 필요합니다. 스트레스의 원인을 파악하고, 이를 해결하기 위한 구체적인 계획을 세워보세요. 가족이나 친구와의 대화를 통해 스트레스를 풀거나, 취미 생활을 통해 스트레스를 완화시키는 것도 좋은 방법입니다. 또한, 일상에서 긍정적인 활동을 추가함으로써 정서적 안정감을 찾는 것이 중요합니다. 스트레스를 줄이기 위한 체계적인 접근 방법을 고려해보세요.';
    } else if (averageScore < 50) {
      return '조금 높은 상태입니다. 스트레스가 쌓이고 있으며, 적극적인 관리가 필요합니다. 스트레스를 줄이기 위한 구체적인 방법을 실천해보세요. 예를 들어, 일정을 재조정하여 여유 시간을 늘리거나, 스트레스 해소를 위한 활동을 계획해보세요. 전문가의 도움을 받는 것도 좋은 방법입니다. 스트레스가 건강에 미치는 영향을 최소화하기 위해, 규칙적인 운동과 건강한 식습관을 유지하는 것이 중요합니다.';
    } else if (averageScore < 60) {
      return '높은 상태입니다. 스트레스가 상당히 높아졌으며, 즉각적인 관리가 필요합니다. 스트레스 관리 방법을 강화하고, 스트레스가 더 이상 쌓이지 않도록 주의해야 합니다. 이완 요법이나 심리 상담을 통해 스트레스를 관리해보세요. 규칙적인 운동과 건강한 식습관을 유지하는 것도 중요합니다. 추가적으로, 스트레스를 다루는 새로운 방법을 배우고 실천하는 것도 도움이 됩니다.';
    } else if (averageScore < 70) {
      return '매우 높은 상태입니다. 스트레스가 매우 높은 수준이며, 전문가의 도움이 필요할 수 있습니다. 스트레스가 건강에 영향을 미칠 수 있으므로, 빠른 시일 내에 적절한 조치를 취하는 것이 중요합니다. 전문가와의 상담을 통해 스트레스 관리 방법을 배워보세요. 스트레스 해소를 위한 휴식 시간을 꼭 확보하세요. 이 시점에서는 규칙적인 운동, 명상, 그리고 균형 잡힌 식단이 매우 중요한 역할을 할 수 있습니다.';
    } else if (averageScore < 80) {
      return '위험한 상태입니다. 스트레스가 매우 높은 상태로, 즉각적인 관리가 필요합니다. 전문가의 도움을 받는 것이 좋습니다. 스트레스가 건강에 심각한 영향을 미치기 전에 적절한 조치를 취해야 합니다. 전문가와의 상담을 통해 스트레스 해소 방법을 배우고, 이를 일상 생활에 적용해보세요. 이러한 단계들은 정신적 및 신체적 건강을 보호하는 데 필수적입니다.';
    } else if (averageScore < 90) {
      return '매우 위험한 상태입니다. 스트레스가 매우 높은 수준으로, 즉시 전문가의 도움을 받는 것이 좋습니다. 스트레스가 건강에 심각한 영향을 미치기 전에 신속하게 조치를 취해야 합니다. 심리 상담이나 스트레스 관리 프로그램에 참여하여 스트레스를 해소할 수 있는 방법을 배우세요. 지금 바로 조치를 취하는 것이 중요하며, 필요시 의료적 도움을 받는 것도 고려해보세요.';
    } else {
      return '매우 심각한 상태입니다. 스트레스가 극도로 높은 수준으로, 병원에 가서 전문가의 도움을 받는 것이 필요합니다. 스트레스가 건강에 치명적인 영향을 미칠 수 있으므로, 즉각적인 조치가 필요합니다. 가능한 한 빨리 병원을 방문하여 적절한 치료와 상담을 받으세요. 건강을 유지하기 위해 적극적인 치료와 관리가 필요합니다.';
    }
  }

  String getScoreSlopeAdvice() {
    if (maxSlope < 40) {
      return '스트레스가 완만하게 증가했습니다. 현재의 스트레스 관리 방법을 유지하며, 특별한 조치가 필요하지 않습니다. 규칙적인 생활을 유지하고, 작은 스트레스 해소 방법들을 실천하세요. 일상 생활 속에서 편안함을 유지하기 위한 명상이나 심호흡 운동을 추가해보세요.';
    } else if (maxSlope < 50) {
      return '스트레스가 다소 빠르게 증가했습니다. 스트레스 증가의 원인을 파악하고, 이를 완화할 수 있는 방법을 찾아보세요. 주기적인 휴식과 스트레스를 줄일 수 있는 활동을 계획해보세요. 이 시기에는 친구나 가족과의 대화 시간을 늘려 정서적 지지를 받는 것이 도움이 될 수 있습니다.';
    } else if (maxSlope < 60) {
      return '스트레스가 빠르게 증가했습니다. 스트레스 관리에 신경을 써야 합니다. 스트레스의 원인을 분석하고, 이를 해결할 수 있는 구체적인 방법을 찾아보세요. 전문가의 도움을 받는 것도 좋은 방법입니다. 일주일에 한 번이라도 전문가 상담을 받아 스트레스 원인을 명확히 하고, 해결 방안을 모색하는 것이 좋습니다.';
    } else if (maxSlope < 70) {
      return '스트레스가 매우 빠르게 증가했습니다. 즉각적인 조치가 필요합니다. 스트레스가 건강에 심각한 영향을 미치기 전에 전문가의 도움을 받아 스트레스 관리 방법을 배워보세요. 심리 상담이나 스트레스 관리 프로그램에 참여하여 스트레스를 해소하세요. 추가로, 스트레스 해소를 위해 주기적인 운동을 계획하고, 건강한 식습관을 유지하는 것이 중요합니다.';
    } else {
      return '스트레스가 극도로 빠르게 증가했습니다. 이는 건강에 심각한 영향을 미칠 수 있는 매우 위험한 상황입니다. 즉각적인 조치가 필요하며, 전문가의 도움을 받는 것이 중요합니다. 심리 상담을 통해 스트레스 원인을 분석하고, 스트레스 관리 프로그램을 통해 체계적인 관리를 시작하세요. 이와 함께 충분한 휴식과 수면을 취하며, 긴장을 풀기 위한 활동을 지속적으로 실천하세요. 가능한 빨리 병원을 방문하여 신체적, 정신적 건강 상태를 점검받고, 필요한 치료를 받으세요.';
    }
  }

  String getDetailedScoreAdvice() {
    String advice = getScoreAdvice();
    return '이번 달 평균 스트레스 점수는 ${averageScore.toStringAsFixed(1)}점입니다.\n$advice\n\n';
  }

  String getAnalysis() {
    if (stressScores.isEmpty) return '데이터가 부족합니다.';

    calculateStatistics();

    return '평균 스트레스 점수:\n'
        '이번 달 평균 스트레스 점수는 ${averageScore.toStringAsFixed(1)}점입니다.\n'
        '${getScoreAdvice()}\n\n'
        '스트레스가 가장 높은 날과 낮은 날:\n'
        '스트레스가 가장 높은 날은 $highStressDay일, 점수: ${highStressScore.toStringAsFixed(1)}점\n'
        '스트레스가 가장 낮은 날은 $lowStressDay일, 점수: ${lowStressScore.toStringAsFixed(1)}점\n\n'
        '스트레스 기울기 분석:\n'
        '스트레스 기울기가 가장 높은 기간은 ${maxSlopeStart.day}일 ~ ${maxSlopeEnd.day}일, 스트레스가 갑자기 높아진 날입니다.\n'
        '스트레스 기울기가 가장 낮은 기간은 ${minSlopeStart.day}일 ~ ${minSlopeEnd.day}일, 스트레스가 갑자기 낮아진 날입니다.\n\n'
        '10점 단위 스트레스 분석:\n'
        '${getScoreRangeAnalysis()}';
  }

  Future<void> sendDataToApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    const String apiUrl = 'https://your-api-url.com/endpoint';

    // Prepare the query parameters
    final Map<String, String> queryParams = {
      'userId': userId.toString(),
      'highStressDate':
          '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${highStressDay.toString().padLeft(2, '0')}',
      'lowStressDate':
          '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${lowStressDay.toString().padLeft(2, '0')}',
      'minSlopeSecondDate':
          '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${minSlopeEnd.day.toString().padLeft(2, '0')}',
    };

    // Construct the full URL with query parameters
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    // Send the GET request
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('Data sent successfully');
    } else {
      print('Failed to send data: ${response.reasonPhrase}');
    }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Row(
                children: [
                  Text(
                    '스트레스 점수 그래프',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 20),
              GetBuilder<StatisticViewController>(
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
                                    if (day > 31) {
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
                      const Row(
                        children: [
                          Text(
                            '이번 달 평균 스트레스 점수는?',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${controller.averageScore.toStringAsFixed(1)} / 100',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Color(0xffacdcb4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.getDetailedScoreAdvice(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xffe9e9e9),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Row(
                        children: [
                          Text(
                            '이번 달 스트레스가 높은날은?',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Row(
                            children: [
                              Text(
                                '${controller.highStressDay}일, 점수: ${controller.highStressScore.toStringAsFixed(1)}점',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xffacdcb4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        children: [
                          Text(
                            '이번 달 스트레스가 낮은날은?',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Row(
                            children: [
                              Text(
                                '${controller.lowStressDay}일, 점수: ${controller.lowStressScore.toStringAsFixed(1)}점',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xffacdcb4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        children: [
                          Text(
                            '스트레스가 갑자기 높아진 기간은?',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Row(
                            children: [
                              Text(
                                '${controller.maxSlopeStart.day}일 ~ ${controller.maxSlopeEnd.day}일',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xffacdcb4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Text(
                            controller.getScoreSlopeAdvice(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xffe9e9e9),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Row(
                        children: [
                          Text(
                            '스트레스 기울기가 낮아진 기간은?',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      GetBuilder<StatisticViewController>(
                        builder: (controller) {
                          return Row(
                            children: [
                              Text(
                                '${controller.minSlopeStart.day}일 ~ ${controller.minSlopeEnd.day}일',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xffacdcb4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
