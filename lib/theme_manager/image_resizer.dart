import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
class ImageResizer {
 static Future<void> reduceImageSizeAndQuality(String p) async {
      String imagePath=p.split(":").first;
      String home=p.split(":").last;
    // Load the image from the given path
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image != null) {
      // Resize the image to a smaller size (e.g., 50% of the original size)
      int newWidth = (image.width * 0.1).toInt();
      int newHeight = (image.height * 0.1).toInt();
      img.Image resizedImage = img.copyResize(
          image, width: newWidth, height: newHeight);

      // Encode the image to JPEG with reduced quality
      List<int> compressedImageBytes = img.encodeJpg(resizedImage, quality: 50);

      // Convert List<int> to Uint8List
      Uint8List compressedImageUint8List = Uint8List.fromList(
          compressedImageBytes);

      // Save the compressed image to a new file
      await Directory("$home/.NexData/compressed/").create(recursive: true);
      String newPath = "$home/.NexData/compressed/img.jpg";
      File compressedImageFile = File(newPath);
      await compressedImageFile.writeAsBytes(compressedImageUint8List);
    } else{

    }
  }
}