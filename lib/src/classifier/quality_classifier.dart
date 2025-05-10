import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

Future<Map<String, dynamic>> classifyPineapple(File imageFile, String model) async {
  // 1. Load your TFLite model
  final interpreter = await Interpreter.fromAsset('assets/models/mobileNet2.tflite');

  // 2. Read image file
  final rawBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(rawBytes);

  // 3. Resize to 224x224
  img.Image resized = img.copyResize(image!, width: 224, height: 224);

  // 4. Normalize and convert to Float32List
  var input = List.generate(224, (y) =>
    List.generate(224, (x) {
      final pixel = resized.getPixel(x, y);
      return [
        img.getRed(pixel) / 255.0,
        img.getGreen(pixel) / 255.0,
        img.getBlue(pixel) / 255.0,
      ];
    }),
  );

  // Convert to Tensor input shape: [1, 224, 224, 3]
  var inputTensor = [input];

  // 5. Allocate output buffer
  var output = List.filled(1, 0.0).reshape([1, 1]);

  // 6. Run inference
  interpreter.run(inputTensor, output);

    double score = output[0][0];
  String label = score >= 0.5 ? 'Healthy' : 'Mechanically Damaged';
  return {
    'label': label,
    'score': score,          // Raw confidence score (0.0 to 1.0)
    'confidence': '${(score * 100).toStringAsFixed(1)}%',
  };
  // return score.toString();
}
