import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'day_detail_screen.dart';
import 'models/habit.dart';
import 'screens/exercise_templates_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/food_templates_screen.dart';
import 'screens/ai_insights.dart';
import 'screens/this_week_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'services/global_context_service.dart';
import 'services/firestore_service.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  Box<Habit>? habitBox;
  DateTime? _tappedDay;
  bool _hasLoadedTemplates = false;

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box<Habit>('habits');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasLoadedTemplates) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _hasLoadedTemplates = true;
          await loadTemplatesFromFirestore(GlobalContextService.globalContext);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays(_focusedMonth);

    return Scaffold(
      backgroundColor: Color(0xff4e4d4a),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person, color: Colors.yellow),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        title: Text(
          'Thrive',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff4e4d4a),
        foregroundColor: Colors.yellow,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekDaysRow(),
          SizedBox(
            height: 400,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: GridView.builder(
                key: ValueKey<String>(_focusedMonth.toString()),
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isToday = _isSameDay(day, DateTime.now());

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _tappedDay = day;
                      });

                      await Future.delayed(Duration(milliseconds: 150));
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DayDetailScreen(date: day),
                        ),
                      );

                      setState(() {
                        _tappedDay = null;
                      });
                    },
                    child: AnimatedScale(
                      scale: _tappedDay == day ? 0.95 : 1.0,
                      duration: Duration(milliseconds: 150),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday ? Colors.yellow : Color(0xff232222),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isToday
                                ? Color(0xff232222)
                                : (day.month == _focusedMonth.month
                                ? Colors.white
                                : Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThisWeekScreen(),
                    ),
                  );
                },
                child: Text('This Week'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseTemplatesScreen(),
                    ),
                  );
                },
                child: Text('Your Exercises'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodTemplatesScreen(),
                    ),
                  );
                },
                child: Text('Your Foods'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIInsightsScreen(),
                    ),
                  );
                },
                child: Text('🧠 AI Insights'),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 32, color:Colors.yellow),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat.yMMMM().format(_focusedMonth),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.yellow
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 32, color:Colors.yellow),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysRow() {
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays
            .map(
              (day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  List<DateTime> _generateDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysBefore = firstDayOfMonth.weekday % 7;
    final firstToDisplay = firstDayOfMonth.subtract(Duration(days: daysBefore));

    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysAfter = 6 - (lastDayOfMonth.weekday % 7);
    final lastToDisplay = lastDayOfMonth.add(Duration(days: daysAfter));

    final days = <DateTime>[];
    for (var day = firstToDisplay;
    day.isBefore(lastToDisplay.add(Duration(days: 1)));
    day = day.add(Duration(days: 1))) {
      days.add(day);
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
