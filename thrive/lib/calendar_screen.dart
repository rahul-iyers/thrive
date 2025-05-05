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

          // 🛠 SizedBox instead of Expanded
          SizedBox(
            height: 400, // 🔥 Adjust if needed for your phone
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final dotColor = _getDotColor(day);

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayDetailScreen(date: day),
                      ),
                    );
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: day.month == _focusedMonth.month
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: day.month == _focusedMonth.month
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        if (dotColor != 'none')
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor:
                              dotColor == 'blue' ? Colors.blue : Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
                  backgroundColor: Colors.blueGrey,
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      )
          .toList(),
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

  // ✅ Dot color logic
  String _getDotColor(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final habit = habitBox.get(key);

    if (habit != null) {
      if (habit.exercises.isNotEmpty ||
          habit.sleepHours > 0 ||
          habit.moodRating > 0 ||
          habit.dietNotes.isNotEmpty) {
        return 'blue'; // Day has data
      }
    }

    if (day.isBefore(DateTime.now())) {
      return 'red'; // Past day, missing data
    }

    return 'none'; // No dot
  }
}
