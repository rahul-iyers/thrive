import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ThisWeekScreen extends StatefulWidget {
  @override
  _ThisWeekScreenState createState() => _ThisWeekScreenState();
}

class _ThisWeekScreenState extends State<ThisWeekScreen>
    with TickerProviderStateMixin {
  DateTime startOfWeek = _getStartOfWeek();
  Map<String, Map<String, dynamic>> dailyData = {};

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static DateTime _getStartOfWeek() {
    final now = DateTime.now();
    final daysSinceSunday = now.weekday % 7;
    return DateTime(now.year, now.month, now.day - daysSinceSunday);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    fetchWeekData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  List<FlSpot> workoutData = [];
  Future<void> fetchWeekData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final endOfWeek = startOfWeek.add(Duration(days: 7));
    final habitsQuery = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection('habits')
        .where('loggedFor', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(startOfWeek))
        .where('loggedFor', isLessThan: DateFormat('yyyy-MM-dd').format(endOfWeek))
        .get();

    Map<String, Map<String, dynamic>> dataByDay = {};
    for (var doc in habitsQuery.docs) {
      final data = doc.data();
      final dayKey = data['loggedFor'];
      if (dayKey != null && dayKey is String) {
        dataByDay[dayKey] = data;
      }

      dataByDay[dayKey] = data;
    }

    setState(() {
      dailyData = dataByDay;
      workoutData = _getChartData("workouts", count:true);
    });

    _controller.forward(); // trigger animation
  }

  List<String> get weekLabels => ['Sun', 'M', 'T', 'W', 'Th', 'F', 'S'];

  double getStat(DateTime day, String key, {bool count = false}) {
    final dayKey = DateFormat('yyyy-MM-dd').format(day);
    final entry = dailyData[dayKey];
    if (entry == null) return 0;

    if (count) {
      final value = entry[key];
      if (value is List) return value.length.toDouble();
      return value != null ? 1 : 0;
    }

    final value = entry[key];
    return (value is num) ? value.toDouble() : 0;
  }

  List<FlSpot> _getChartData(String key, {bool count = false}) {
    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return FlSpot(i.toDouble(), getStat(day, key, count: count));
    });
  }

  Widget _buildChart(String title, List<FlSpot> data, String unit, double maxY) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.2),
        end: Offset.zero,
      ).animate(_fadeAnimation),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: (maxY / 5).ceilToDouble(),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index < 0 || index > 6) return Container();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(weekLabels[index], style: TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: false,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        color: Colors.yellow,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text("Unit: $unit", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<FlSpot> data) {
    final yValues = data.map((e) => e.y).toList();
    double maxY = yValues.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) {
      maxY = 2;
    }
    // maxY = yValues.isEmpty ? 2 : yValues.reduce((a, b) => a > b ? a : b);
    return maxY.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final weekRange = "${DateFormat('MMM d').format(startOfWeek)} – ${DateFormat('MMM d').format(startOfWeek.add(Duration(days: 6)))}";

    return Scaffold(
      appBar: AppBar(
        title: Text("This Week: $weekRange"),
        backgroundColor: Color(0xff4e4d4a),
        foregroundColor: Colors.yellow,
      ),
      body: dailyData.isEmpty
          ? Center(child: Text("No data for this week yet."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChart("Sleep Hours", _getChartData("sleepHours"), "hrs", 12),
            // _buildChart("🙂 Mood", _getChartData("moodRating"), "1–10", 10),
            _buildChart("Workouts", _getChartData("workouts", count: true), "count", _getMaxY(workoutData)),
            // _buildChart("Foods Logged", _getChartData("foods", count: true), "count", _getMaxY(_getChartData("foods"))),
          ],
        ),
      ),
    );
  }
}
