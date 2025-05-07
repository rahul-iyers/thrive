import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/habit.dart';
import '../screens/food_templates_screen.dart';
import 'package:hive/hive.dart';

class NutritionScreen extends StatefulWidget {
  final Habit habit;

  NutritionScreen({required this.habit});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late Habit habit;
  late TextEditingController _dietNotesController;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
    _dietNotesController = TextEditingController(text: habit.dietNotes);
  }

  @override
  void dispose() {
    _dietNotesController.dispose();
    super.dispose();
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

  void _saveDietNotes() {
    habit.dietNotes = _dietNotesController.text;
  }

  Future<void> _handlePop() async {
    _saveDietNotes();
    Navigator.pop(context, habit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nutrition data saved!'),
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
          title: Text('Nutrition'),
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
              _buildDietNotesCard(),
              SizedBox(height: 16),
              _buildFoodsList(),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showFoodOptions,
                child: Text('Add Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                _buildTotalTile('Calories', totalCalories.toStringAsFixed(0), Colors.orange),
                _buildTotalTile('Protein (g)', totalProtein.toStringAsFixed(1), Colors.green),
                _buildTotalTile('Carbs (g)', totalCarbs.toStringAsFixed(1), Colors.blue),
                _buildTotalTile('Fats (g)', totalFats.toStringAsFixed(1), Colors.purple),
                _buildTotalTile('Added Sugar (g)', totalSugar.toStringAsFixed(1), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTile(String label, String value, Color color) {
    return Container(
      width: 140, // <-- Fixed width for consistency
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



  Widget _buildDietNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diet Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _dietNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write notes about your diet here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foods', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        habit.foods.isEmpty
            ? Text('No foods added yet.', style: TextStyle(color: Colors.grey))
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: habit.foods.length,
          itemBuilder: (context, index) {
            final food = habit.foods[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(food.name),
                subtitle: Text(
                    '${food.calories} cal | ${food.protein}g P | ${food.carbs}g C | ${food.fats}g F | ${food.addedSugar}g Sugar'),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => deleteFood(index),
                ),
                onTap: () => _editFood(context, index, food),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value) {
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

  void _editFood(BuildContext context, int index, Food food) async {
    String name = food.name;
    double calories = food.calories;
    double protein = food.protein;
    double carbs = food.carbs;
    double fats = food.fats;
    double addedSugar = food.addedSugar;

    final updatedFood = await showDialog<Food>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  controller: TextEditingController(text: calories.toString()),
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => calories = double.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: protein.toString()),
                  decoration: InputDecoration(labelText: 'Protein'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => protein = double.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: carbs.toString()),
                  decoration: InputDecoration(labelText: 'Carbs'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => carbs = double.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: fats.toString()),
                  decoration: InputDecoration(labelText: 'Fats'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => fats = double.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: addedSugar.toString()),
                  decoration: InputDecoration(labelText: 'Added Sugar'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => addedSugar = double.tryParse(val) ?? 0,
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
                  Food(
                    name: name,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fats: fats,
                    addedSugar: addedSugar,
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedFood != null) {
      setState(() {
        habit.foods[index] = updatedFood;
      });
    }
  }

  void _showFoodOptions() async {
    final pickedOption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Food', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Choose how you want to add food:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: Text('Manual Entry'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'template'),
            child: Text('Pick from Template'),
          ),
        ],
      ),
    );

    if (pickedOption == 'manual') {
      final newFood = await _showAddFoodDialog();
      if (newFood != null) addFood(newFood);
    } else if (pickedOption == 'template') {
      final selectedFood = await _showPickTemplateDialog();
      if (selectedFood != null) addFood(selectedFood);
    }
  }

  Future<Food?> _showPickTemplateDialog() async {
    final templatesBox = Hive.box<Food>('food_templates');
    List<Food> templates = templatesBox.values.toList();
    List<Food> filteredTemplates = List.from(templates); // Start with everything shown
    TextEditingController _searchController = TextEditingController();

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No templates available')),
      );
    }

    return await showDialog<Food>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pick a Food Template', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search foods...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredTemplates = templates.where((food) {
                            return food.name.toLowerCase().contains(query.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: filteredTemplates.isEmpty
                          ? Center(child: Text('No results found.'))
                          : ListView.builder(
                        itemCount: filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final food = filteredTemplates[index];
                          return Card(
                            color: Colors.green[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Icon(Icons.restaurant_menu, color: Colors.green),
                              title: Text(food.name, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${food.calories} cal • ${food.protein}g P • ${food.carbs}g C • ${food.fats}g F',
                                style: TextStyle(fontSize: 12),
                              ),
                              onTap: () => Navigator.pop(context, food),
                            ),
                          );
                        },
                      ),
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
                  onPressed: () async {
                    final newFood = await _showCreateTemplateDialog();
                    if (newFood != null) {
                      await templatesBox.add(newFood);
                      templates = templatesBox.values.toList();
                      _searchController.clear();
                      setState(() {
                        filteredTemplates = List.from(templates);
                      });
                    }
                  },
                  child: Text('New Template'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<Food?> _showCreateTemplateDialog() async {
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
          title: Text('Create New Template'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => calories = double.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => protein = double.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => carbs = double.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Fats (g)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => fats = double.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Added Sugar (g)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => addedSugar = double.tryParse(val) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
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
          title: Text('Add Food Manually', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    hintText: 'e.g. Chicken Breast',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => name = val,
                ),
                SizedBox(height: 20),
                Text('Macros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                _buildNumberInputField('Calories', (val) => calories = double.tryParse(val) ?? 0),
                SizedBox(height: 8),
                _buildNumberInputField('Protein (g)', (val) => protein = double.tryParse(val) ?? 0),
                SizedBox(height: 8),
                _buildNumberInputField('Carbs (g)', (val) => carbs = double.tryParse(val) ?? 0),
                SizedBox(height: 8),
                _buildNumberInputField('Fats (g)', (val) => fats = double.tryParse(val) ?? 0),
                SizedBox(height: 8),
                _buildNumberInputField('Added Sugar (g)', (val) => addedSugar = double.tryParse(val) ?? 0),
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
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildNumberInputField(String label, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

}
