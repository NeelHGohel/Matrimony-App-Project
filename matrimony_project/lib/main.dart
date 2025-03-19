import 'package:flutter/material.dart';
import 'package:matrimony_project/design/dashboard_screen.dart';

import 'design/favorite_user.dart';
import 'design/registration_form.dart';
import 'design/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        hintColor: Colors.red,
        primaryColor: Colors.red,
        indicatorColor: Colors.red,
        highlightColor: Colors.red,

        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
