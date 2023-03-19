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
      //verifica se há cameras disponíveis para uso do app
      if (cameras.length > 0) {
        //Cameras é um vetor, pois os celulares possuem mais de uma, portanto,
        //podemos colocar o índice 0 para carregar a primeira e principal camera
        //a traseira, mas como queremos a frontal, colocamos no indice 1
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

  //faz o dispose da controller e da CameraController para não haver risco de sobreposição
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
    return Stack(
      children: [
        //Cria o preview da camera pegando toda a tela
      SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CameraPreview(controller!),
      ),

      //Posiciono o Objeto 3D para preencher a tela
      Positioned.fill(
        child: Object3dController(),
      ),
      //Texto para debuggar as faces processadas pelo ML Kit
      Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          facesDetected.isNotEmpty? facesDetected.first.toString() : "No faces detected"
        ),
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
        inputImageFormat: InputImageFormat.yuv420,
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
