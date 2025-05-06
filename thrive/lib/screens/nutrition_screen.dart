import 'package:flutter/material.dart';
import 'package:thrive/models/food.dart';
import '../models/habit.dart';

class NutritionScreen extends StatefulWidget {
  final Habit habit;

  NutritionScreen({required this.habit});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late Habit habit;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
  }

  void addFood(Food food) {
    setState(() {
      final updatedFoods = List<Food>.from(habit.foods);
      updatedFoods.add(food);
      habit.foods = updatedFoods;
    });
  }

  void deleteFood(int index) {
    setState(() {
      final updatedFoods = List<Food>.from(habit.foods);
      if (index >= 0 && index < updatedFoods.length) {
        updatedFoods.removeAt(index);
        habit.foods = updatedFoods;
      }
    });
  }

  double get totalCalories => habit.foods.fold(0, (sum, food) => sum + food.calories);
  double get totalProtein => habit.foods.fold(0, (sum, food) => sum + food.protein);
  double get totalCarbs => habit.foods.fold(0, (sum, food) => sum + food.carbs);
  double get totalFats => habit.foods.fold(0, (sum, food) => sum + food.fats);
  double get totalSugar => habit.foods.fold(0, (sum, food) => sum + food.addedSugar);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🥗 Totals Section
            Text(
              'Totals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTotalCard('Calories', '${totalCalories.toStringAsFixed(0)} cal', Colors.orange.shade100),
                _buildTotalCard('Protein', '${totalProtein.toStringAsFixed(1)}g', Colors.blue.shade100),
                _buildTotalCard('Carbs', '${totalCarbs.toStringAsFixed(1)}g', Colors.green.shade100),
                _buildTotalCard('Fats', '${totalFats.toStringAsFixed(1)}g', Colors.purple.shade100),
                _buildTotalCard('Sugar', '${totalSugar.toStringAsFixed(1)}g', Colors.pink.shade100),
              ],
            ),

            SizedBox(height: 20),

            // 🍔 Food List
            Text(
              'Foods',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            habit.foods.isEmpty
                ? Text('No foods added yet.', style: TextStyle(color: Colors.grey))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: habit.foods.length,
              itemBuilder: (context, index) {
                final food = habit.foods[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 0.8, end: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                        '${food.calories.toStringAsFixed(0)} cal | '
                            '${food.protein.toStringAsFixed(1)}g protein | '
                            '${food.carbs.toStringAsFixed(1)}g carbs | '
                            '${food.fats.toStringAsFixed(1)}g fat | '
                            '${food.addedSugar.toStringAsFixed(1)}g sugar',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          deleteFood(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // ➕ Add Food Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newFood = await _showAddFoodDialog();
                if (newFood != null) {
                  addFood(newFood);
                }
              },
              child: Text('Add Food'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<Food?> _showAddFoodDialog() async {
    String name = '';
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    double addedSugar = 0;

    return await showDialog<Food>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', (val) => name = val),
                _buildTextField('Calories', (val) => calories = double.tryParse(val) ?? 0, number: true),
                _buildTextField('Protein (g)', (val) => protein = double.tryParse(val) ?? 0, number: true),
                _buildTextField('Carbs (g)', (val) => carbs = double.tryParse(val) ?? 0, number: true),
                _buildTextField('Fats (g)', (val) => fats = double.tryParse(val) ?? 0, number: true),
                _buildTextField('Added Sugar (g)', (val) => addedSugar = double.tryParse(val) ?? 0, number: true),
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
      },
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }
}
