import 'package:flutter/material.dart';
import 'package:whats_paste/view/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Paste',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.green,
          onPrimary: Colors.white,
          secondary: Colors.green,
          onSecondary: Colors.white,
          tertiary: Colors.green.shade900,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
          surface: Colors.grey.shade100,
          onSurface: Colors.grey.shade800,
        ),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
