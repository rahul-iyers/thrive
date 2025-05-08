import 'package:flutter/material.dart';
import '../models/food.dart';

class AddFoodDialog extends StatefulWidget {
  final Food? existingFood;

  const AddFoodDialog({this.existingFood});

  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  late TextEditingController nameController;
  late TextEditingController caloriesController;
  late TextEditingController proteinController;
  late TextEditingController carbsController;
  late TextEditingController fatsController;
  late TextEditingController addedSugarController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingFood?.name ?? '');
    caloriesController = TextEditingController(text: widget.existingFood != null ? widget.existingFood!.calories.toString() : '0.0');
    proteinController = TextEditingController(text: widget.existingFood != null ? widget.existingFood!.protein.toString() : '0.0');
    carbsController = TextEditingController(text: widget.existingFood != null ? widget.existingFood!.carbs.toString() : '0.0');
    fatsController = TextEditingController(text: widget.existingFood != null ? widget.existingFood!.fats.toString() : '0.0');
    addedSugarController = TextEditingController(text: widget.existingFood != null ? widget.existingFood!.addedSugar.toString() : '0.0');
  }


  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    addedSugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingFood != null ? 'Edit Food' : 'Add Food'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildField('Name', nameController),
            _buildField('Calories', caloriesController),
            _buildField('Protein (g)', proteinController),
            _buildField('Carbs (g)', carbsController),
            _buildField('Fats (g)', fatsController),
            _buildField('Added Sugar (g)', addedSugarController),
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
            if (nameController.text.trim().isNotEmpty && double.tryParse(caloriesController.text) != null) {
              Navigator.pop(
                context,
                Food(
                  name: nameController.text.trim(),
                  calories: double.tryParse(caloriesController.text) ?? 0,
                  protein: double.tryParse(proteinController.text) ?? 0,
                  carbs: double.tryParse(carbsController.text) ?? 0,
                  fats: double.tryParse(fatsController.text) ?? 0,
                  addedSugar: double.tryParse(addedSugarController.text) ?? 0,
                ),
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: label == 'Name' ? TextInputType.text : TextInputType.number,
      ),
    );
  }
}
