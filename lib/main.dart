import 'package:flutter/material.dart';
import 'package:skribbl_clone/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribble Clone',
      //the title of the app
      debugShowCheckedModeBanner: false,
      //removing the banner that comes on top of the debugging
      theme: ThemeData(
        primarySwatch: Colors.teal,
        //  setting the theme of the UI to teal color
      ),
      home: const HomeScreen(),
      // home: const PaintScreen(),
      //  setting the base to text
    );
  }
}
