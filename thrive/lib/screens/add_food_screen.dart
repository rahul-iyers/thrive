import 'package:flutter/material.dart';
import '../models/food.dart';

class AddFoodScreen extends StatefulWidget {
  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  double calories = 0;
  double carbs = 0;
  double protein = 0;
  double fats = 0;
  double addedSugar = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Food Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Food Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => name = val ?? '',
              ),
              SizedBox(height: 12),

              // Calories
              TextFormField(
                decoration: InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => calories = double.tryParse(val ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Carbs
              TextFormField(
                decoration: InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => carbs = double.tryParse(val ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Protein
              TextFormField(
                decoration: InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => protein = double.tryParse(val ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Fats
              TextFormField(
                decoration: InputDecoration(labelText: 'Fats (g)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => fats = double.tryParse(val ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Added Sugar
              TextFormField(
                decoration: InputDecoration(labelText: 'Added Sugar (g)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => addedSugar = double.tryParse(val ?? '0') ?? 0,
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final newFood = Food(
                      name: name,
                      calories: calories,
                      carbs: carbs,
                      protein: protein,
                      fats: fats,
                      addedSugar: addedSugar,
                    );
                    Navigator.pop(context, newFood); // Pass food back!
                  }
                },
                child: Text('Save Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
