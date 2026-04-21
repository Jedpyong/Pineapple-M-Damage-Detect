import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

Future<Map<String, dynamic>> classifyPineapple(File imageFile) async {
  // 1. Load your TFLite model
  final interpreter = await Interpreter.fromAsset(
    'assets/models/[Op4]EfficientNetV2B0.tflite',
  );

  // 2. Read image file
  final rawBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(rawBytes);

  if (image == null) return {'error': 'Could not decode image'};

  image = img.bakeOrientation(image);

  //Preprocess
  int cropSize = image.width < image.height ? image.width : image.height;

  int offsetX = (image.width - cropSize) ~/ 2;
  int offsetY = (image.height - cropSize) ~/ 2;

  img.Image squareImage = img.copyCrop(
    image,
    offsetX,
    offsetY,
    cropSize,
    cropSize,
  );

  img.Image finalResizedImage = img.copyResize(
    squareImage,
    width: 300, //MobileNet
    height: 300, //MobileNet
    // width: 512, //EfficientNetV2B0
    // height: 512, //EfficientNetV2B0
  );

  //Create Input Buffer
  Float32List inputBytes = Float32List(1 * 300 * 300 * 3);

  int pixelIndex = 0;
  for (int y = 0; y < finalResizedImage.height; y++) {
    for (int x = 0; x < finalResizedImage.width; x++) {
      int pixel = finalResizedImage.getPixel(x, y);
      inputBytes[pixelIndex++] = img.getRed(pixel).toDouble();
      inputBytes[pixelIndex++] = img.getGreen(pixel).toDouble();
      inputBytes[pixelIndex++] = img.getBlue(pixel).toDouble();
    }
  }

  var inputTensor = inputBytes.reshape([1, 300, 300, 3]);

  // 5. Allocate output buffer
  var output = List.filled(1, 0.0).reshape([1, 1]);

  // 6. Run inference
  interpreter.run(inputTensor, output);

  double score = output[0][0];

  String label = score >= 0.5 ? 'Mechanically Damaged' : 'Healthy';
  return {
    'label': label,
    'score': score, // Raw confidence score (0.0 to 1.0)
    'confidence': '${(score * 100).toStringAsFixed(1)}%',
  };
}
