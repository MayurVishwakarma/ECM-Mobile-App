import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  final _picker = ImagePicker();
  Uint8List? imgBytes;
  Uint8List? watermarkedImgBytes;
  bool isLoading = false;
  Uint8List? file;

  Future<void> pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // Read image bytes
        final imageBytes = await image.readAsBytes();
        setState(() {
          imgBytes = Uint8List.fromList(imageBytes);
        });

        // Add watermark after setting the image bytes
        await addWaterMark();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> addWaterMark() async {
    if (imgBytes == null) return; // Ensure imgBytes is not null

    try {
      final watermarkedBytes = await ImageWatermark.addTextWatermark(
        imgBytes: imgBytes!,
        font: null, //ImageFont.readOtherFontZip(file!),
        watermarkText: 'Current Location: 17.1552, 19.2525',
        dstX: 20,
        dstY: 30,
      );

      setState(() {
        watermarkedImgBytes = watermarkedBytes;
      });
    } catch (e) {
      debugPrint('Error adding watermark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Watermark'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    width: 600,
                    height: 250,
                    child: imgBytes == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo),
                              SizedBox(height: 10),
                              Text('Click here to take a photo'),
                            ],
                          )
                        : Image.memory(imgBytes!,
                            width: 600, height: 200, fit: BoxFit.fitHeight),
                  ),
                ),
                const SizedBox(height: 10),
                watermarkedImgBytes == null
                    ? const SizedBox()
                    : Image.memory(watermarkedImgBytes!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
