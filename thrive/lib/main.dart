import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/global_context_service.dart';
import 'calendar_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/food.dart';
import 'models/workout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(FoodAdapter());

  // Safely open all boxes
  await openSafeBox<Habit>('habits');
  await openSafeBox<Exercise>('exercise_templates');
  await openSafeBox<Food>('food_templates');

  runApp(Thrive());
}

Future<Box<T>> openSafeBox<T>(String boxName) async {
  try {
    return await Hive.openBox<T>(boxName);
  } catch (e) {
    print('Error opening $boxName: $e');
    print('Deleting and recreating $boxName...');
    await Hive.deleteBoxFromDisk(boxName);
    return await Hive.openBox<T>(boxName);
  }
}

class Thrive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrive',
      navigatorKey: GlobalContextService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(), // <-- new widget to handle login vs calendar
      debugShowCheckedModeBanner: false,
    );
  }
}

// New Widget: AuthGate
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking login state, show loading spinner
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Logged in
          return CalendarScreen();
        } else {
          // Not logged in
          return LoginScreen();
        }
      },
    );
  }
}
