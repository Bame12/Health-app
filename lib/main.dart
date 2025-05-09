import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:healthadmin/core/theme/app_theme.dart';
import 'package:healthadmin/firebase_options.dart';
import 'package:healthadmin/providers/auth_provider.dart';
import 'package:healthadmin/providers/doctor_provider.dart';
import 'package:healthadmin/providers/appointment_provider.dart';
import 'package:healthadmin/providers/review_provider.dart';
import 'package:healthadmin/router/app_router.dart';
import 'package:healthadmin/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Firebase services here
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase services immediately after Firebase.initializeApp()
    await FirebaseService.initialize();

    print('Firebase and services initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');

    // For desktop platforms, continue anyway
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      print('Continuing without Firebase on desktop platform');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only create providers after Firebase is initialized
    return FutureBuilder(
      future: _waitForFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => DoctorProvider()),
            ChangeNotifierProvider(create: (_) => AppointmentProvider()),
            ChangeNotifierProvider(create: (_) => ReviewProvider()),
          ],
          child: MaterialApp.router(
            title: 'Doctor Finder',
            theme: AppTheme.lightTheme,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }

  Future<void> _waitForFirebase() async {
    // Wait a bit for Firebase to be ready
    await Future.delayed(const Duration(milliseconds: 100));
  }
}