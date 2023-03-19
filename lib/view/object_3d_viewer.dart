import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Object3dController extends StatefulWidget {
  const Object3dController({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Object3dController> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          scale *= details.scale;
          // Limita o valor da escala para que o objeto 3D não fique muito grande ou muito pequeno
          if (scale < 0.1) {
            scale = 0.1;
          }
          if (scale > 5.0) {
            scale = 5.0;
          }
        });
      },
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: ModelViewer(
            src: 'assets/sunglasses.glb',
            alt: "future custom-made glasses",
            ar: true,
            autoRotate: false,
            cameraControls: true,
          ),
        ),
      ),
    );
  }
}