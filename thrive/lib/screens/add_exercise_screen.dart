import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';

class AddExerciseScreen extends StatefulWidget {
  final Function(Exercise) onAdd;
  final Exercise? exercise;
  final bool showPickTemplateButton;

  AddExerciseScreen({
    required this.onAdd,
    this.exercise,
    this.showPickTemplateButton = true,
  });

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController minutesController;
  late TextEditingController setsController;
  late TextEditingController repsController;
  late TextEditingController weightController;
  late TextEditingController notesController;

  String type = 'Gym';
  final List<String> types = ['Gym', 'Sport', 'Cardio'];
  late Box<Exercise> templatesBox;

  @override
  void initState() {
    super.initState();
    templatesBox = Hive.box<Exercise>('exercise_templates');

    nameController = TextEditingController(text: widget.exercise?.name ?? '');
    minutesController = TextEditingController(
        text: widget.exercise != null && widget.exercise!.minutes > 0
            ? widget.exercise!.minutes.toString()
            : '');
    setsController = TextEditingController(
        text: widget.exercise != null && widget.exercise!.sets > 0
            ? widget.exercise!.sets.toString()
            : '');
    repsController = TextEditingController(text: widget.exercise?.reps ?? '');
    weightController = TextEditingController(text: widget.exercise?.weight ?? '');
    notesController = TextEditingController(text: widget.exercise?.notes ?? '');

    type = widget.exercise?.type ?? 'Gym';
  }

  @override
  void dispose() {
    nameController.dispose();
    minutesController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void pickFromTemplate() async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      builder: (context) {
        final templates = templatesBox.values.toList();
        if (templates.isEmpty) {
          return Center(child: Text('No templates found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, template);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (template.type.isNotEmpty)
                          _buildTag('Type: ${template.type}'),
                        if (template.sets > 0 && template.reps.isNotEmpty)
                          _buildTag('Sets x Reps: ${template.sets} x ${template.reps}'),
                        if (template.weight.isNotEmpty)
                          _buildTag('Weight: ${template.weight}'),
                        if (template.minutes > 0)
                          _buildTag('Minutes: ${template.minutes}'),
                      ],
                    ),
                    if (template.notes.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        template.notes,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        nameController.text = selected.name;
        minutesController.text = selected.minutes.toString();
        setsController.text = selected.sets.toString();
        repsController.text = selected.reps;
        weightController.text = selected.weight;
        notesController.text = selected.notes;
        type = selected.type;
      });
    }
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🆕 Show Pick From Template button only if allowed
              if (widget.showPickTemplateButton) ...[
                ElevatedButton(
                  onPressed: pickFromTemplate,
                  child: Text('Pick from Template'),
                ),
                SizedBox(height: 20),
              ],

              // Exercise Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),

              // Exercise Type
              DropdownButtonFormField(
                value: type,
                items: types.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    type = val as String;
                  });
                },
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 12),

              // Minutes
              TextFormField(
                controller: minutesController,
                decoration: InputDecoration(labelText: 'Minutes'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),

              // Sets
              TextFormField(
                controller: setsController,
                decoration: InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),

              // Reps
              TextFormField(
                controller: repsController,
                decoration: InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 12),

              // Weight
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Weight (lbs)'),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final exercise = Exercise(
                      name: nameController.text.trim(),
                      minutes: int.tryParse(minutesController.text.trim()) ?? 0,
                      sets: int.tryParse(setsController.text.trim()) ?? 0,
                      reps: repsController.text.trim(),
                      weight: weightController.text.trim(),
                      notes: notesController.text.trim(),
                      type: type,
                    );
                    widget.onAdd(exercise);
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.exercise == null ? 'Save Exercise' : 'Update Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
