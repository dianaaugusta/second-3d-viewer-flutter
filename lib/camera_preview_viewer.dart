import 'package:customeyes_second_application/pages/object_3d_viewer.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:untitled2/object_3d_viewer.dart';

class CameraPreviewPage extends StatefulWidget {
  @override
  _CameraPreviewPageState createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  late List<CameraDescription> cameras;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    return Stack(
        children:[
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          Positioned.fill(
            child: Object3dController(),
          ),
        ]
    );
  }
}
