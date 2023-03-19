import 'package:google_ml_kit/google_ml_kit.dart';
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
  late FaceDetector _faceDetector;
  List<Face> facesDetected = [];

  late InputImage inputImage;

  @override
  void initState() {
    super.initState();
    initializeCamera();

    //Aqui inicio a fazer a conversão da imagem em tempo real ou o mais cedo possível detectada pela camera
    //do android
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future initializeCamera() async {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        controller = CameraController(cameras[1], ResolutionPreset.medium);
        controller?.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            controller?.startImageStream((CameraImage image) async {
              //Inicializo a detecção e o stream a partir da imagem processada
              initializeCameraStreamAndDetection(image);
            });
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
    //Se a controladora não for inicializada, irá apenas mostrar um container vazio
    if (controller == null || !(controller?.value.isInitialized ?? false)) {
      return Container();
    }
    return Stack(children: [
      AspectRatio(
        aspectRatio: (controller?.value.aspectRatio ?? 0.0),
        //Mostro o Preview da câmera dentro do AspectRatio do dispositivo
        child: CameraPreview(controller!),
      ),
      //Posiciono o Objeto 3D para preencher a tela
      Positioned.fill(
        child: Object3dController(),
      ),
      //Texto para debuggar as faces processadas pelo ML Kit
      Text(
        facesDetected.isNotEmpty? facesDetected.first.toString() : "No faces"
      )

    ]);
  }

  Future<void> initializeCameraStreamAndDetection(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    if (cameraImage != null) {
      //Se a cameraImage não for nula, ele vai inserir uma InputImage, necessária
      //para o funcionamento do ML Kit
      //https://github.com/bharat-biradar/Google-Ml-Kit-plugin/tree/master/packages/google_mlkit_commons#creating-an-inputimage
      //através dos dados que ele recebe da imagem mapeada
      InputImageData _dataProcessedFromImage = InputImageData(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: InputImageRotation.rotation90deg,
        inputImageFormat: InputImageFormat.bgra8888,
        //mapeando a imagem
        planeData: image.planes.map(
          (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList(),
      );


      InputImage _bytesFromInputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        inputImageData: _dataProcessedFromImage,
      );

      //Finalmente, o ML Kit vai TENTAR ler uma face a partir da imagem que recebe
      //a partir da ImageInput mapeada, convertida e recebida
      var result = await _faceDetector.processImage(_bytesFromInputImage);

      //se ele conseguir detectar alguma, adicionará à FacesDetected
      if (result.isNotEmpty) {
        facesDetected = result;
      }
    }
  }
}
