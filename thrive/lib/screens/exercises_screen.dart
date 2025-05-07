import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExercisesScreen extends StatefulWidget {
  final Workout workout;

  ExercisesScreen({required this.workout});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  Future<void> addExercise(Exercise exercise) async {
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises.add(exercise);

    setState(() {
      workout.exercises = updatedExercises;
    });

    await workout.save();
  }

  void _deleteExercise(int index) async {
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises.removeAt(index);

    setState(() {
      workout.exercises = updatedExercises;
    });

    await workout.save();
  }


  void _confirmDeleteExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Exercise?'),
        content: Text('Are you sure you want to delete this exercise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteExercise(index); // ✅ Actually delete the exercise
              Navigator.pop(context); // ✅ Then close the dialog
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> editExercise(int index, Exercise exercise) async {
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[index] = exercise;

    setState(() {
      workout.exercises = updatedExercises;
    });

    await workout.save();
  }

  void _showAddExerciseOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create New Exercise'),
              onTap: () {
                Navigator.pop(context);
                _showManualAddDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Pick from Templates'),
              onTap: () {
                Navigator.pop(context);
                _showPickTemplateDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddDialog() {
    String name = '';
    int minutes = 0;
    int sets = 0;
    String reps = '';
    String weight = '';
    String notes = '';
    String type = 'Gym';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Exercise'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', onChanged: (v) => name = v),
                _buildNumberField('Minutes', onChanged: (v) => minutes = int.tryParse(v) ?? 0),
                _buildNumberField('Sets', onChanged: (v) => sets = int.tryParse(v) ?? 0),
                _buildTextField('Reps', onChanged: (v) => reps = v),
                _buildTextField('Weight', onChanged: (v) => weight = v),
                _buildTextField('Notes', onChanged: (v) => notes = v),
                _buildTextField('Type', onChanged: (v) => type = v),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  Navigator.pop(context, Exercise(
                    name: name,
                    minutes: minutes,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                    notes: notes,
                    type: type,
                  ));
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ).then((newExercise) {
      if (newExercise != null) {
        addExercise(newExercise);
      }
    });
  }

  void _showPickTemplateDialog() async {
    final templatesBox = Hive.box<Exercise>('exercise_templates');
    final templates = templatesBox.values.toList();

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No templates available')),
      );
      return;
    }

    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a Template'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final exercise = templates[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.sets} sets • ${exercise.reps} reps'),
                  onTap: () => Navigator.pop(context, exercise),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedExercise != null) {
      final confirm = await _showTemplatePreviewDialog(selectedExercise);
      if (confirm) {
        addExercise(
          Exercise(
            name: selectedExercise.name,
            minutes: selectedExercise.minutes,
            sets: selectedExercise.sets,
            reps: selectedExercise.reps,
            weight: selectedExercise.weight,
            notes: selectedExercise.notes,
            type: selectedExercise.type,
          ),
        );
      }
    }
  }

  Future<bool> _showTemplatePreviewDialog(Exercise exercise) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add This Exercise?'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${exercise.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Minutes: ${exercise.minutes}'),
                Text('Sets: ${exercise.sets}'),
                Text('Reps: ${exercise.reps}'),
                Text('Weight: ${exercise.weight}'),
                Text('Type: ${exercise.type}'),
                if (exercise.notes.isNotEmpty) Text('Notes: ${exercise.notes}'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Add')),
          ],
        );
      },
    ) ?? false;
  }

  void _showEditExerciseDialog(int index, Exercise exercise) {
    String name = exercise.name;
    int minutes = exercise.minutes;
    int sets = exercise.sets;
    String reps = exercise.reps;
    String weight = exercise.weight;
    String notes = exercise.notes;
    String type = exercise.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Exercise'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', initialValue: name, onChanged: (v) => name = v),
                _buildNumberField('Minutes', initialValue: minutes.toString(), onChanged: (v) => minutes = int.tryParse(v) ?? 0),
                _buildNumberField('Sets', initialValue: sets.toString(), onChanged: (v) => sets = int.tryParse(v) ?? 0),
                _buildTextField('Reps', initialValue: reps, onChanged: (v) => reps = v),
                _buildTextField('Weight', initialValue: weight, onChanged: (v) => weight = v),
                _buildTextField('Notes', initialValue: notes, onChanged: (v) => notes = v),
                _buildTextField('Type', initialValue: type, onChanged: (v) => type = v),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, Exercise(
                  name: name,
                  minutes: minutes,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  notes: notes,
                  type: type,
                ));
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ).then((editedExercise) {
      if (editedExercise != null) {
        editExercise(index, editedExercise);
      }
    });
  }

  Widget _buildTextField(String label, {String? initialValue, required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: initialValue != null ? TextEditingController(text: initialValue) : null,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(String label, {String? initialValue, required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: initialValue != null ? TextEditingController(text: initialValue) : null,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${workout.name} Exercises'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: workout.exercises.isEmpty
                  ? Center(child: Text('No exercises yet.'))
                  : ListView.builder(
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text('${exercise.sets} sets • ${exercise.reps} reps'),
                      onTap: () => _showEditExerciseDialog(index, exercise),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteExercise(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _showAddExerciseOptions,
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
