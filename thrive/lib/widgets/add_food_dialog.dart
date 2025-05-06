import 'package:flutter/material.dart';
import '../models/food.dart';

class AddFoodDialog extends StatefulWidget {
  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  String name = '';
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;
  double addedSugar = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Food'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildField('Name', (val) => name = val),
            _buildField('Calories', (val) => calories = double.tryParse(val) ?? 0),
            _buildField('Protein (g)', (val) => protein = double.tryParse(val) ?? 0),
            _buildField('Carbs (g)', (val) => carbs = double.tryParse(val) ?? 0),
            _buildField('Fats (g)', (val) => fats = double.tryParse(val) ?? 0),
            _buildField('Added Sugar (g)', (val) => addedSugar = double.tryParse(val) ?? 0),
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
            if (name.isNotEmpty && calories > 0) {
              Navigator.pop(
                context,
                Food(
                  name: name,
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fats: fats,
                  addedSugar: addedSugar,
                ),
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }
}
