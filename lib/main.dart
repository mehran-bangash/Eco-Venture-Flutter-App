
import 'package:eco_venture/views/childSection/multimedia/child_multimedia_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return ResponsiveSizer(
      builder: (context, orientation, screenType) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EcoVenture',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home:ChildMultimediaScreen(),
        );
      },
    );
  }
}

