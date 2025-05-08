import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/food.dart';
import '../widgets/add_food_dialog.dart';
import '../services/firestore_service.dart';

class FoodTemplatesScreen extends StatefulWidget {
  @override
  _FoodTemplatesScreenState createState() => _FoodTemplatesScreenState();
}

class _FoodTemplatesScreenState extends State<FoodTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late Box<Food> templatesBox;
  late AnimationController _controller;
  int? tappedIndex;

  @override
  void initState() {
    super.initState();
    templatesBox = Hive.box<Food>('food_templates');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addTemplate() async {
    final newFood = await showDialog<Food>(
      context: context,
      builder: (context) => AddFoodDialog(),
    );

    if (newFood != null) {
      templatesBox.add(newFood);
      await saveTemplatesToFirestore(context);
      setState(() {});
    }
  }

  void editTemplate(int index, Food oldFood) async {
    setState(() {
      tappedIndex = index;
    });

    await Future.delayed(Duration(milliseconds: 150));

    final updatedFood = await showDialog<Food>(
      context: context,
      builder: (context) => AddFoodDialog(existingFood: oldFood),
    );

    if (updatedFood != null) {
      templatesBox.putAt(index, updatedFood);
      await saveTemplatesToFirestore(context);
      setState(() {});
    }

    setState(() {
      tappedIndex = null;
    });
  }

  void deleteTemplate(int index) async {
    bool confirm = await _confirmDelete();
    if (confirm) {
      templatesBox.deleteAt(index);
      await saveTemplatesToFirestore(context);
      setState(() {});
    }
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Template'),
        content: Text('Are you sure you want to delete this food template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final templates = templatesBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Templates'),
        actions: [
          IconButton(
            onPressed: addTemplate,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: templates.isEmpty
          ? Center(
        child: Text(
          'No templates yet.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final food = templates[index];
          return GestureDetector(
            onTap: () => editTemplate(index, food),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(food.name),
                  subtitle: Text(
                    '${food.calories} cal | ${food.protein}g protein | ${food.carbs}g carbs | ${food.fats}g fat | ${food.addedSugar}g sugar',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => deleteTemplate(index),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
