import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contacts_controller.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
        create: (_) => ContactsController(),
        child: MaterialApp(
          title: 'Contacts App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HomeScreen(),
        )
      )
      ;
  }
}
