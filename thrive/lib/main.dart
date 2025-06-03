import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/global_context_service.dart';
import 'calendar_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/food.dart';
import 'models/workout.dart';
import 'models/mood_entry.dart';
import 'models/user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  await openSafeBox<Habit>('habits');
  await openSafeBox<Exercise>('exercise_templates');
  await openSafeBox<Food>('food_templates');
  await Hive.openBox<UserProfile>('userProfile');

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          bodyLarge: GoogleFonts.roboto(color: Colors.white),
          bodyMedium: GoogleFonts.roboto(color: Colors.white70),
          titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff4e4d4a),
        primaryColor: Colors.yellow,
        colorScheme: const ColorScheme.dark(
          primary: Colors.yellow,
          secondary: Colors.yellow,
          surface: Color(0xff4e4d4a),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff4e4d4a),
          foregroundColor: Colors.yellow,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Color(0xff232222),       // black card background
          shadowColor: Colors.black87,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        // textTheme: const TextTheme(
        //   bodyLarge: TextStyle(color: Colors.white),
        //   bodyMedium: TextStyle(color: Colors.white70),
        //   titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return CalendarScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
