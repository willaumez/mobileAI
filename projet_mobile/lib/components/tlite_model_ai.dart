import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TfliteModel {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      print("Modèle chargé avec succès.");
    } catch (e) {
      print("Erreur lors du chargement du modèle : $e");
      throw Exception('Impossible de charger le modèle');
    }
  }

  Future<String?> getCategoryFromImage(File imageFile) async {
    try {
      var bytes = await imageFile.readAsBytes();
      var input = _preprocessImage(bytes);

      var output = List.filled(1*4, 0).reshape([1,4]);
      _interpreter.run(input, output);

      var outputAsList = output[0].toList();
      _interpreter.close();

      return _postprocessOutput(outputAsList);
    } catch (e) {
      print("Erreur lors de l'inférence : $e");
      // Gérer l'erreur, par exemple, en lançant une exception ou en retournant un message d'erreur
      return null;
    }
  }

  Uint8List _preprocessImage(Uint8List imageBytes) {
  // Charger l'image avec la bibliothèque image
  img.Image? image = img.decodeImage(imageBytes);

  if (image != null) {
    // Redimensionner l'image à la taille souhaitée (224x224)
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convertir les valeurs de pixel en float32 et normaliser
    var input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = resizedImage.getPixel(x, y);

        // Normaliser les valeurs des canaux de couleur entre 0 et 1
        input[pixelIndex++] = (img.getRed(pixel) / 255.0);
        input[pixelIndex++] = (img.getGreen(pixel) / 255.0);
        input[pixelIndex++] = (img.getBlue(pixel) / 255.0);
      }
    }
    return Uint8List.fromList(input.buffer.asUint8List());
  } else {
    throw Exception('Impossible de décoder l\'image');
  }
}

  String _postprocessOutput(List<dynamic> output) {
    var doubleList = List<double>.from(output);
    var categories = ['Sport', 'Shopping', 'Fitness', 'Autres'];
    var maxIdx = doubleList.indexWhere((element) => element == doubleList.reduce((curr, next) => curr > next ? curr : next));
    var category = maxIdx != -1 && maxIdx < categories.length ? categories[maxIdx] : 'Autres';
    return category;
  }





}
