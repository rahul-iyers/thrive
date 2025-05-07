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

  Future<Exercise?> _showCreateTemplateDialog() async {
    String name = '';
    int minutes = 0;
    int sets = 0;
    String reps = '';
    String weight = '';
    String notes = '';
    String type = 'Gym';

    return await showDialog<Exercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Exercise Template'),
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
    );
  }


  void _deleteExercise(int index) async {
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises.removeAt(index);

    setState(() {
      workout.exercises = updatedExercises;
    });

    await workout.save();
  }


  Future<bool?> _confirmDeleteExercise(int index) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Exercise?'),
        content: Text('Are you sure you want to delete "${workout.exercises[index].name}"?'),
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
    List<Exercise> templates = templatesBox.values.toList();
    List<Exercise> filteredTemplates = List.from(templates);
    TextEditingController _searchController = TextEditingController();

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No templates available')),
      );
      return;
    }

    final selectedExercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6,
                      width: 60,
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredTemplates = templates.where((exercise) {
                            return exercise.name.toLowerCase().contains(query.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: filteredTemplates.isEmpty
                          ? Center(child: Text('No results found.'))
                          : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredTemplates.length,
                        separatorBuilder: (context, index) => SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final exercise = filteredTemplates[index];
                          return Card(
                            color: Colors.blue[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              title: Text(
                                exercise.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (exercise.sets > 0 || exercise.reps.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('${exercise.sets} sets × ${exercise.reps} reps'),
                                    ),
                                  if (exercise.weight.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Weight: ${exercise.weight}', style: TextStyle(fontSize: 13)),
                                    ),
                                  if (exercise.notes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(exercise.notes, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                                    ),
                                ],
                              ),
                              onTap: () => Navigator.pop(context, exercise),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
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
                            onPressed: () async {
                              final newExercise = await _showCreateTemplateDialog();
                              if (newExercise != null) {
                                final templatesBox = Hive.box<Exercise>('exercise_templates');
                                await templatesBox.add(newExercise);
                                // Refresh templates
                                templatesBox.flush(); // ensure latest state
                                templatesBox.compact(); // (optional) save space
                                final updatedTemplates = templatesBox.values.toList();
                                setState(() {
                                  templates = updatedTemplates;
                                  filteredTemplates = updatedTemplates;
                                });
                              }
                            },
                            child: Text('New Template'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedExercise != null) {
      final confirm = await _showTemplatePreviewDialog(selectedExercise);
      if (confirm) {
        addExercise(Exercise(
          name: selectedExercise.name,
          minutes: selectedExercise.minutes,
          sets: selectedExercise.sets,
          reps: selectedExercise.reps,
          weight: selectedExercise.weight,
          notes: selectedExercise.notes,
          type: selectedExercise.type,
        ));
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
  Widget _buildExerciseCard(Exercise exercise, int index) {
    return Dismissible(
      key: ValueKey(exercise.hashCode), // instead of name+index
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      confirmDismiss: (_) => _confirmDeleteExercise(index),
        onDismissed: (_) {
          setState(() {
            workout.exercises.removeAt(index);
          });
          workout.save();
        },
      child: Card(
        color: Colors.yellow[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              if (exercise.minutes > 0) ...[
                Icon(Icons.timer, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${exercise.minutes} min',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (exercise.sets > 0 || exercise.reps.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${exercise.sets} sets × ${exercise.reps} reps ${exercise.weight}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              if (exercise.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    exercise.notes,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ),
            ],
          ),
          onTap: () => _showEditExerciseDialog(index, exercise),
        ),
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
        child: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showAddExerciseOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Add Exercise', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 12),
            workout.exercises.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No exercises yet.', style: TextStyle(color: Colors.grey)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return _buildExerciseCard(exercise, index);
              },
            ),
          ],
        ),
      ),

    );
  }
}
