import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/view/camera_preview_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter and 3D Glasses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraPreviewPage(),
    );
  }
}

