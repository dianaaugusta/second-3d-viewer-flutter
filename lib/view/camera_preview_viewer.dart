

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:untitled2/view/object_3d_viewer.dart';

class CameraPreviewPage extends StatefulWidget {
  @override
  _CameraPreviewPageState createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  CameraImage? cameraImage;
  late List<CameraDescription> cameras;
   CameraController? controller;
  late String result = "";

  late InputImage inputImage;

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        controller = CameraController(cameras[0],
            ResolutionPreset.medium);
        controller?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            initializeCameraStreamAndDetection();
            setCameraImage(controller!);
          });
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
    if (controller == null || !(controller?.value.isInitialized ??false)){
      return Container();
    }
    return Stack(
        children:[
          AspectRatio(
            aspectRatio:(controller?.value.aspectRatio ?? 0.0),
            child: CameraPreview(controller!),
          ),
          Positioned.fill(
            child: Object3dController(),
          ),
          Text(
            result,
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),
          ),
        ]
    );
  }

  void initializeCameraStreamAndDetection(){
    //Aqui inicio a fazer a conversão da imagem em tempo real ou o mais cedo possível detectada pela camera
    //do android
    final WriteBuffer allBytes = WriteBuffer();
    if(cameraImage != null){
      for (final Plane plane in cameraImage!.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      //Aqui defino o tamanho da imagem baseado na imagem em tempo real que pego na camera
      final Size imageSize = Size((cameraImage?.width.toDouble() ?? 0.0), (cameraImage?.height.toDouble() ?? 0.0));

      //Aqui defino a orientação da imagem baseado na imagem em tempo real que pego na camera, se vier null,
      //coloco como padrão o valor de 0 graus
      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(cameras[0].sensorOrientation) ?? InputImageRotation.rotation0deg ;

      //Aqui defino o formato da imagem baseado na imagem em tempo real que pego na camera, se vier null,
      //colo como padrão o formato de YUV420, bytes usados normalmente para detecção de imagens e não crashar o app
      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(cameraImage?.format.raw) ?? InputImageFormat.yuv420;

      final planeData = cameraImage?.planes.map(
            (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    }

    print("null");

  }

  void setCameraImage(CameraController controller){
    controller.startImageStream((image) =>
    cameraImage = image);
  }
}
