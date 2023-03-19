
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:untitled2/object_3d_viewer.dart';

class PhotoDetectionFace extends StatefulWidget {
  @override
  _PhotoDetectionFace createState() => _PhotoDetectionFace();
}

class _PhotoDetectionFace extends State<PhotoDetectionFace> {
  late List<CameraDescription> cameras;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
        children:[
          Image.network("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80"),
          Positioned.fill(
            child: Object3dController(),
          ),
        ]
    );
  }
}
