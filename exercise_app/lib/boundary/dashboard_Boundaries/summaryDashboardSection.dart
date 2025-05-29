import 'package:exercise_app/controller/dashboardServices/dashboardSummaryService.dart';
import 'package:exercise_app/boundary/dashboard_Boundaries/dashboard_day_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:intl/intl.dart';

class SummaryDashboardSection extends StatefulWidget {
  const SummaryDashboardSection({super.key});

  @override
  State<SummaryDashboardSection> createState() =>
      _SummaryDashboardSectionState();
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class _SummaryDashboardSectionState extends State<SummaryDashboardSection> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> lastFiveDates = [];
  List<double> lastFiveCalories = [];
  List<double> lastFiveDurations = [];
  List<String> workoutsForDay = [];
  int totalDurationForDay = 0;
  double caloriesForSelectedDay = 0.0;
  bool showCalories = true;
  bool useBarChart = false;

  @override
  void initState() {
    super.initState();
    generateLastFiveDates();
    loadSummary();
  }
  
  double _getYAxisInterval(List<double> data) {
  final maxY = data.isEmpty ? 10 : data.reduce((a, b) => a > b ? a : b);
  
  if (maxY <= 100) return 20;
  if (maxY <= 300) return 50;
  return 100;
}


  void generateLastFiveDates() {
    lastFiveDates = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });
  }

  Future<void> loadSummary() async {
    final allStats = await DashboardSummaryService().fetchCaloriesLast5Days();
    final workouts = await DashboardSummaryService().fetchWorkoutsByDate(
      selectedDate,
    );

    final statsForSelectedDate = allStats.firstWhere(
      (entry) => _isSameDay(entry['date'], selectedDate),
      orElse: () => {'calories': 0.0, 'duration': 0},
    );

    setState(() {
      lastFiveCalories =
          lastFiveDates.map((date) {
            final stat = allStats.firstWhere(
              (entry) => _isSameDay(entry['date'], date),
              orElse: () => {'calories': 0.0},
            );
            return (stat['calories'] as num).toDouble();
          }).toList();

      lastFiveDurations =
          lastFiveDates
              .map((date) {
                final stat = allStats.firstWhere(
                  (entry) => _isSameDay(entry['date'], date),
                  orElse: () => {'duration': 0},
                );
                final rawDuration = stat['duration'];
                if (rawDuration is num) {
                  return rawDuration.toDouble() / 60.0;
                }
                return 0.0;
              })
              .toList()
              .cast<double>();

      workoutsForDay =
          workouts
              .map<String>((e) => (e['workoutName'] ?? 'Unnamed').toString())
              .toList();

      totalDurationForDay = statsForSelectedDate['duration'];
      caloriesForSelectedDay =
          (statsForSelectedDate['calories'] as num).toDouble();
    });
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    final localD1 = d1.toLocal();
    final localD2 = d2.toLocal();
    return localD1.year == localD2.year &&
        localD1.month == localD2.month &&
        localD1.day == localD2.day;
  }

  Widget buildChart(List<double> chartData, Color chartColor) {
    final chartLabel = showCalories ? "Calories" : "Minutes";
    final maxValue = chartData.isEmpty ? 10 : chartData.reduce((a, b) => a > b ? a : b);
final interval = _getYAxisInterval(chartData);
final maxY = ((maxValue / interval).ceil() * interval).toDouble();


    if (useBarChart) {
      return BarChart(
        BarChartData(
          minY: 0,
          maxY:maxY,
          barGroups: List.generate(
            chartData.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: chartData[i],
                  color: chartColor,
                  width: 12,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(show: false),
                ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
              topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false), // 👈 hide top
  ),

            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                "Day",
                style: TextStyle(color: Colors.white70),
              ),
              axisNameSize: 28,
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
  final index = value.toInt();
  if (index < 0 || index >= lastFiveDates.length) return const SizedBox();
  final day = lastFiveDates[index];
  return Text(
    DateFormat('E').format(day), // 'Mon', 'Tue', ...
    style: const TextStyle(color: Colors.white, fontSize: 13),
  );
}

              ),
            ),
            leftTitles: AxisTitles(
  axisNameWidget: Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Text(
      chartLabel,
      style: TextStyle(color: Colors.white70, fontSize: 13),
    ),
  ),
  axisNameSize: 24,
  sideTitles: SideTitles(showTitles: false), // 👈 no numbers here
),

rightTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 42,
    interval: interval,
    getTitlesWidget: (value, meta) {
      return Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
        textAlign: TextAlign.right,
      );
    },
  ),
),


          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY:maxY,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false), // 👈 hide top
  ),

          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              "Day",
              style: TextStyle(color: Colors.white70),
            ),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
  final index = value.toInt();
  if (index < 0 || index >= lastFiveDates.length) return const SizedBox();
  final day = lastFiveDates[index];
  return Text(
    DateFormat('E').format(day), // 'Mon', 'Tue', ...
    style: const TextStyle(color: Colors.white, fontSize: 13,)
  );
}

            ),
          ),
          leftTitles: AxisTitles(
  axisNameWidget: Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Text(
      chartLabel,
      style: TextStyle(color: Colors.white70, fontSize: 13),
    ),
  ),
  axisNameSize: 24,
  sideTitles: SideTitles(showTitles: false), // 👈 no numbers here
),

rightTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    reservedSize: 42,
    interval: interval,
    getTitlesWidget: (value, meta) {
      return Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
        textAlign: TextAlign.right,
      );
    },
  ),
),


        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Colors.white10,
                strokeWidth: 1,
                dashArray: [4, 2],
              ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              chartData.length,
              (i) => FlSpot(i.toDouble(), chartData[i]),
            ),
            isCurved: true,
            color: chartColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  chartColor.withOpacity(0.4),
                  const Color.fromARGB(52, 213, 50, 50),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: chartColor,
                  strokeWidth: 2,
                  strokeColor: Colors.black,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${chartLabel}: ${spot.y.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartData = showCalories ? lastFiveCalories : lastFiveDurations;
    final chartColor = showCalories ? Colors.yellowAccent : Colors.cyanAccent;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              DashboardDaySelector(
                last5Days: lastFiveDates,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  loadSummary();
                },
              ),

              const SizedBox(height: 0),
              workoutsForDay.isEmpty
                  ? const Text(
                    "No workouts for this day.",
                    style: TextStyle(color: Colors.white70),
                  )
                  : SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: workoutsForDay.length,
                      itemBuilder: (context, index) {
                        final workout = workoutsForDay[index];
                        return Container(
                          constraints: const BoxConstraints(
                            minWidth: 160,
                            maxWidth: 170,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00ACC1), // Strong turquoise
                                Color(0xFF00838F), // Rich cyan/teal
                                Color(0xFF005662), // Deep sea green
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [
                              Icon(
                                MdiIcons.weightLifter,
                                color: Colors.white,
                                size: 35,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: () {
                                    // Normalize special characters to dots, then split
                                    String normalized = workout.replaceAll(
                                      RegExp(r'[•·‧∘∙]'),
                                      '.',
                                    );
                                    List<String> parts = normalized.split('.');

                                    if (parts.length >= 2) {
                                      return [
                                        Text(
                                          parts[0].trim(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                        Text(
                                          parts[1].trim().capitalize(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ];
                                    } else {
                                      return [
                                        Text(
                                          workout,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ];
                                    }
                                  }(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                    ),
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6F61), // Light Coral
                            Color(0xFFFF3D00), // Vivid Red
                            Color(0xFFB71C1C), // Deep Red
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Calories",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${caloriesForSelectedDay.round()}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    " kCal",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00B0FF), // Electric Sky Blue
                            Color(0xFF2962FF), // Bold Blue
                            Color(0xFF0D47A1), // Dark Navy Blue
                          ],
                        ),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.white70),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total time",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${(totalDurationForDay / 60).toStringAsFixed(1)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    " mins",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => showCalories = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient:
                            showCalories
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD84315),
                                    Color(0xFFB71C1C),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                                : const LinearGradient(
                                  colors: [Colors.white10, Colors.white10],
                                ),

                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          if (showCalories)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          if (showCalories) const SizedBox(width: 6),
                          Text(
                            "Calories",
                            style: TextStyle(
                              color:
                                  showCalories ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                     
                  GestureDetector(
                    onTap: () => setState(() => showCalories = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient:
                            !showCalories
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF0D47A1),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                                : const LinearGradient(
                                  colors: [Colors.white10, Colors.white10],
                                ),

                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          if (!showCalories)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          if (!showCalories) const SizedBox(width: 6),
                          Text(
                            "Time",
                            style: TextStyle(
                              color:
                                  !showCalories ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                   GestureDetector(
      onTap: () => setState(() => useBarChart = !useBarChart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Icon(
              useBarChart ? Icons.bar_chart : Icons.show_chart,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              useBarChart ? "Bar" : "Line",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),],),),),
                  
                  
                ],
              ),

              const SizedBox(height: 22),
              SizedBox(
                height: 220,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: buildChart(chartData, chartColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



  

