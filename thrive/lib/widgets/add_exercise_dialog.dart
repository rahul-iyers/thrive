import 'package:flutter/material.dart';
import '../models/exercise.dart';

class AddExerciseDialog extends StatefulWidget {
  final Exercise? existingExercise;

  AddExerciseDialog({this.existingExercise});

  @override
  _AddExerciseDialogState createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  late TextEditingController nameController;
  late TextEditingController setsController;
  late TextEditingController repsController;
  late TextEditingController weightController;
  late TextEditingController minutesController;
  late TextEditingController notesController;
  String type = 'Gym';

  @override
  void initState() {
    super.initState();
    final e = widget.existingExercise;
    nameController = TextEditingController(text: e?.name ?? '');
    setsController = TextEditingController(text: e?.sets.toString() ?? '');
    repsController = TextEditingController(text: e?.reps ?? '');
    weightController = TextEditingController(text: e?.weight ?? '');
    minutesController = TextEditingController(text: e?.minutes.toString() ?? '');
    notesController = TextEditingController(text: e?.notes ?? '');
    type = e?.type ?? 'Gym';
  }

  @override
  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    minutesController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingExercise != null ? 'Edit Exercise' : 'Add Exercise'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(nameController, 'Name'),
            _buildTextField(setsController, 'Sets', isNumber: true),
            _buildTextField(repsController, 'Reps'),
            _buildTextField(weightController, 'Weight'),
            _buildTextField(minutesController, 'Minutes', isNumber: true),
            _buildTextField(notesController, 'Notes'),
            DropdownButtonFormField<String>(
              value: type,
              decoration: InputDecoration(labelText: 'Type'),
              items: ['Gym', 'Cardio', 'Sport']
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => type = val);
              },
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
            if (nameController.text.trim().isEmpty) return;

            Navigator.pop(
              context,
              Exercise(
                name: nameController.text.trim(),
                sets: int.tryParse(setsController.text.trim()) ?? 0,
                reps: repsController.text.trim(),
                weight: weightController.text.trim(),
                minutes: int.tryParse(minutesController.text.trim()) ?? 0,
                notes: notesController.text.trim(),
                type: type,
              ),
            );
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
