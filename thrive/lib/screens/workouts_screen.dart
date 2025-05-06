import 'package:flutter/material.dart';
import 'package:thrive/models/workout.dart';
import '../models/habit.dart';
import '../models/exercise.dart';
import '../screens/exercise_templates_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  final Habit habit;

  WorkoutsScreen({required this.habit});

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  late Habit habit;
  late TextEditingController _workoutNotesController;
  String type = 'Gym';


  @override
  void initState() {
    super.initState();
    habit = widget.habit;
    _workoutNotesController = TextEditingController(text: habit.workoutNotes);
  }

  @override
  void dispose() {
    _workoutNotesController.dispose();
    super.dispose();
  }

  void addWorkout(Workout workout) {
    setState(() {
      final updatedWorkout = List<Workout>.from(habit.workouts);
      updatedWorkout.add(workout);
      habit.workouts = updatedWorkout;
    });
  }

  void deleteWorkout(int index) {
    setState(() {
      final updatedWorkout = List<Workout>.from(habit.workouts);
      if (index >= 0 && index < updatedWorkout.length) {
        updatedWorkout.removeAt(index);
        habit.workouts = updatedWorkout;
      }
    });
  }

  double get totalMinutes => habit.workouts.fold(0, (sum, workout) => sum + workout.minutes);

  void _saveWorkoutNotes() {
    habit.workoutNotes = _workoutNotesController.text;
  }

  Future<void> _handlePop() async {
    _saveWorkoutNotes();
    Navigator.pop(context, habit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout data saved!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handlePop();
        return false;
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _createWorkout,
                child: Text('Add Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Totals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildWorkoutRow('Workout Minutes', totalMinutes.toStringAsFixed(1)),
          ],
        ),
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

  Widget _buildWorkoutsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        habit.workouts.isEmpty
            ? Text('No workouts added yet.', style: TextStyle(color: Colors.grey))
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: habit.workouts.length,
          itemBuilder: (context, index) {
            final workout = habit.workouts[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(workout.name),
                subtitle: Text(
                    '${workout.type} | ${workout.minutes} min '),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => deleteWorkout(index),
                ),
                onTap: () => _editWorkout(context, index, workout),
              ),
            );
          },
        ),
      ],
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

  void _editWorkout(BuildContext context, int index, Workout workout) async {
    String name = workout.name;
    String type = workout.type;
    double minutes = workout.minutes;

    final updatedWorkout = await showDialog<Workout>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Workout'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  controller: TextEditingController(text: type),
                  decoration: InputDecoration(labelText: 'Type'),
                  onChanged: (val) => type = val,
                ),
                TextField(
                  controller: TextEditingController(text: minutes.toString()),
                  decoration: InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => minutes = double.tryParse(val) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Workout(
                    name: name,
                    type: type,
                    minutes: minutes,
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedWorkout != null) {
      setState(() {
        habit.workouts[index] = updatedWorkout;
      });
    }
  }

  void _createWorkout() async {
    Future<Workout?> showAddWorkoutDialog() async {
      String name = '';
      String type = '';
      double minutes = 0;

      return await showDialog<Workout>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create a Workout'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (val) => name = val,
                  ),
                  // DropdownButtonFormField<String>(
                  //   value: type,
                  //   decoration: InputDecoration(labelText: 'Type'),
                  //   items: ['Gym', 'Cardio', 'Sport'].map((typeOption) {
                  //     return DropdownMenuItem(
                  //       value: typeOption,
                  //       child: Text(typeOption),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) {
                  //     if (value != null) {
                  //       setState(() {
                  //         type = value;
                  //       });
                  //     }
                  //   },
                  // ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Type'),
                    onChanged: (val) => type = val,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => minutes = double.tryParse(val) ?? 0,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty) {
                    Navigator.pop(
                      context,
                      Workout(
                        name: name,
                        type: type,
                        minutes: minutes,
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
    final newWorkout = await showAddWorkoutDialog();
    if (newWorkout != null) addWorkout(newWorkout);
  }
}
