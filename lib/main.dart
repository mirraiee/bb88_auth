import 'package:flutter/material.dart';
import 'signin.dart';
import 'signup.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login 2025',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (_) => LoginPage(),
        '/signup': (_) => SignupPage(),
      },
    );
  }
}
