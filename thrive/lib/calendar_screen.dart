import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'day_detail_screen.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'screens/exercise_templates_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  late Box<Habit> habitBox;
  DateTime? _tappedDay;

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box<Habit>('habits');
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays(_focusedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thrive Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekDaysRow(),

          SizedBox(
            height: 500,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: GridView.builder(
                key: ValueKey<String>(_focusedMonth.toString()),
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final dotColor = _getDotColor(day);
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
                          color: day.month == _focusedMonth.month
                              ? Colors.white
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (day.month == _focusedMonth.month)
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isToday)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.lightBlueAccent,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: day.month == _focusedMonth.month
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            if (dotColor != 'none')
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: dotColor == 'blue'
                                      ? Colors.blue
                                      : Colors.red,
                                ),
                              ),
                          ],
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
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.lightBlueAccent,
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
            icon: Icon(Icons.chevron_left, size: 32),
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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 32),
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
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                  color: Colors.grey[600],
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

  String _getDotColor(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final habit = habitBox.get(key);

    if (habit != null) {
      if (habit.exercises.isNotEmpty ||
          habit.sleepHours > 0 ||
          habit.moodRating > 0 ||
          habit.dietNotes.isNotEmpty) {
        return 'blue';
      }
    }

    if (day.isBefore(DateTime.now())) {
      return 'red';
    }

    return 'none';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
