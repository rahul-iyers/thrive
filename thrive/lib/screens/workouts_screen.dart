import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import 'exercises_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  final Habit habit;

  WorkoutsScreen({required this.habit});

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> with SingleTickerProviderStateMixin{
  late Habit habit;
  late TextEditingController _workoutNotesController;
  bool _showTips = true;
  double _tipsOpacity = 1.0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
    _workoutNotesController = TextEditingController(text: habit.workoutNotes);

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.2), // Slide UP slightly
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start auto fade + slide after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _tipsOpacity = 0.0;
        });
        _slideController.forward(); // <--- ADD THIS (SLIDE UP)
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _showTips = false;
            });
          }
        });
      }
    });
  }



  @override
  void dispose() {
    _slideController.dispose();
    _workoutNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    final habitBox = Hive.box<Habit>('habits');

    if (habit.isInBox) {
      await habit.save();
    } else {
      await habitBox.add(habit);
    }
  }

  Future<void> _saveWorkoutNotes() async {
    habit.workoutNotes = _workoutNotesController.text;
    await _saveHabit();
  }

  Future<void> _handlePop() async {
    await _saveWorkoutNotes();
    Navigator.pop(context, habit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout data saved!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTextInput(String label, Function(String) onChanged, {String initialValue = ''}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberInputField(String label, Function(String) onChanged, {String initialValue = ''}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }


  void addWorkout(Workout workout) {
    setState(() {
      final updatedWorkout = List<Workout>.from(habit.workouts);
      updatedWorkout.add(workout);
      habit.workouts = updatedWorkout;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout added!'), duration: Duration(seconds: 2)),
    );
  }


  Future<void> deleteWorkout(int index) async {
    setState(() {
      final updatedWorkout = List<Workout>.from(habit.workouts);
      if (index >= 0 && index < updatedWorkout.length) {
        updatedWorkout.removeAt(index);
        habit.workouts = updatedWorkout;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }



  Future<void> _editWorkout(BuildContext context, int index, Workout workout) async {
    String name = workout.name;
    String type = workout.type;
    double minutes = workout.minutes;

    final updatedWorkout = await showDialog<Workout>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Workout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextInput('Workout Name', (val) => name = val, initialValue: name),
                SizedBox(height: 20),
                Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                _buildTextInput('Workout Type', (val) => type = val, initialValue: type),
                SizedBox(height: 8),
                _buildNumberInputField('Minutes', (val) => minutes = double.tryParse(val) ?? 0, initialValue: minutes.toString()),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        Workout(
                            name: name,
                            type: type,
                            minutes: minutes,
                            exercises: workout.exercises
                        )
                      );
                    },
                    child: Text('Save'),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );

    if (updatedWorkout != null) {
      setState(() {
        habit.workouts[index] = updatedWorkout;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout updated!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _createWorkout() async {
    String name = '';
    String type = '';
    double minutes = 0;

    final newWorkout = await showDialog<Workout>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create a Workout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextInput('Workout Name', (val) => name = val),
                SizedBox(height: 20),
                Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                _buildTextInput('Workout Type', (val) => type = val),
                SizedBox(height: 8),
                _buildNumberInputField('Minutes', (val) => minutes = double.tryParse(val) ?? 0),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (name.isNotEmpty) {
                        Navigator.pop(
                          context,
                          Workout(name: name, type: type, minutes: minutes),
                        );
                      }
                    },
                    child: Text('Save'),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );

    if (newWorkout != null) {
      addWorkout(newWorkout);
    }
  }

  void _navigateToExercises(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(workout: workout),
      ),
    );
  }

  double get totalMinutes =>
      habit.workouts.fold(0, (sum, workout) => sum + workout.minutes);

  Widget _buildTotalsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Totals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTotalTile('Workout Minutes', totalMinutes.toStringAsFixed(1), Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTile(String label, String value, Color color) {
    return Container(
      width: 140, // Same width for consistency
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workout Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _workoutNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write notes about your workout here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openExercisesPage(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(workout: workout),
      ),
    );
  }

  Future<bool?> _confirmDeleteDialog(String workoutName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Workout?'),
        content: Text('Are you sure you want to delete \"$workoutName\"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }


  Widget _buildWorkoutsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (_showTips) ...[
          SlideTransition(
            position: _slideAnimation,
            child:AnimatedOpacity(
              duration: Duration(milliseconds: 600),
              opacity: _tipsOpacity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeOutBack,
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Card(
                        // color: Colors.yellow[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(Icons.swipe_left),
                              SizedBox(height: 8),
                              Text(
                                'Swipe left to delete a workout',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Card(
                        // color: Colors.blue[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center, color: Colors.blue),
                              SizedBox(height: 8),
                              Text(
                                'Tap dumbbell to view exercises',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
        ],


        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text('Add Workout', style: TextStyle(fontSize: 16)),
          ),
        ),
        SizedBox(height: 12),


        habit.workouts.isEmpty
            ? Text('No workouts added yet.', style: TextStyle(color: Colors.grey))
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: habit.workouts.length,
          itemBuilder: (context, index) {
            final workout = habit.workouts[index];
            return Dismissible(
              key: ValueKey(workout.name + index.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) => _confirmDeleteDialog(workout.name),
              onDismissed: (_) => deleteWorkout(index),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${workout.minutes.toStringAsFixed(0)} min',
                          style: TextStyle(fontSize: 14, color: Colors.blue[800], fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      _buildTypeChip(workout.type),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.fitness_center, color: Colors.blue, size: 30),
                    onPressed: () => _openExercisesPage(workout),
                  ),
                  onTap: () => _editWorkout(context, index, workout),
                ),
              ),
            );

          },
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    Color chipColor;

    switch (type.toLowerCase()) {
      case 'cardio':
        chipColor = Colors.redAccent;
        break;
      case 'gym':
        chipColor = Colors.blueAccent;
        break;
      case 'sport':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(type, style: TextStyle(color: Colors.white)),
      backgroundColor: chipColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }


  Widget _buildWorkoutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handlePop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Workouts'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _handlePop,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildTotalsCard(),
              SizedBox(height: 16),
              _buildWorkoutNotesCard(),
              SizedBox(height: 16),
              _buildWorkoutsList(),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _createWorkout,
              //   child: Text('Add Workout'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
