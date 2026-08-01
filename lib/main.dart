import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';


Future<void> main() async {

  // ضروري قبل أي عملية async في Flutter
  WidgetsFlutterBinding.ensureInitialized();


  // تشغيل Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // تشغيل التطبيق
  runApp(
    const ProviderScope(
      child: EasyBookApp(),
    ),
  );

}



class EasyBookApp extends StatelessWidget {

  const EasyBookApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(

      title: 'Easy Book - Luxury Salon Ecosystem',

      debugShowCheckedModeBanner: false,


      theme: AppTheme.darkTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: ThemeMode.dark,


      routerConfig: appRouter,

    );

  }

}