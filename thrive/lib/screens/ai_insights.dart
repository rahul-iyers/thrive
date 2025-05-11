import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AIInsightsScreen extends StatefulWidget {
  @override
  _AIInsightsScreenState createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  String weekly = "Loading...";
  String monthly = "Loading...";
  String yearly = "Loading...";

  String weeklyLabel = "🗓️ Weekly Insights";
  String monthlyLabel = "📆 Monthly Insights";
  String yearlyLabel = "📊 Yearly Insights";

  @override
  void initState() {
    super.initState();
    fetchInsights();
    generateDateLabels();
  }

  void generateDateLabels() {
    final now = DateTime.now();
    final dateFormatter = DateFormat.MMMMd();
    final monthFormatter = DateFormat.MMMM();
    final yearFormatter = DateFormat.y();

    // Weekly: last Monday to last Sunday
    final lastSunday = now.subtract(Duration(days: now.weekday % 7));
    final previousMonday = lastSunday.subtract(Duration(days: 6));
    weeklyLabel =
    "🗓️ Weekly Insights for ${dateFormatter.format(previousMonday)} – ${dateFormatter.format(lastSunday)}";

    // Monthly: previous calendar month
    final firstDayOfThisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(firstDayOfThisMonth.year, firstDayOfThisMonth.month - 1);
    monthlyLabel = "📆 Monthly Insights for ${monthFormatter.format(lastMonth)}";

    // Yearly: previous calendar year
    final lastYear = now.year - 1;
    yearlyLabel = "📊 Yearly Insights for $lastYear";

    setState(() {});
  }

  Future<void> fetchInsights() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final insightsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('insights');

    final weeklyDoc = await insightsRef.doc('weekly').get();
    final monthlyDoc = await insightsRef.doc('monthly').get();
    final yearlyDoc = await insightsRef.doc('yearly').get();

    setState(() {
      weekly = weeklyDoc.exists ? weeklyDoc['generatedText'] : "No weekly insights yet.";
      monthly = monthlyDoc.exists ? monthlyDoc['generatedText'] : "No monthly insights yet.";
      yearly = yearlyDoc.exists ? yearlyDoc['generatedText'] : "No yearly insights yet.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Insights"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection(weeklyLabel, weekly),
            _buildSection(monthlyLabel, monthly),
            _buildSection(yearlyLabel, yearly),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String text) {
    final bulletPoints = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...bulletPoints.map(
              (line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(line, style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
