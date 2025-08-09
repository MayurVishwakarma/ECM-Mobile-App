// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:image_watermark/image_watermark.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ImageProcessingInput {
//   final Uint8List byteData;
//   final String watermarkText;

//   ImageProcessingInput(this.byteData, this.watermarkText);
// }

// Future<Uint8List> imageProcessingIsolate(ImageProcessingInput input) async {
//   return await resizeAndWatermarkImage(input.byteData, input.watermarkText);
// }

// Future<Uint8List> resizeAndWatermarkImage(
//   Uint8List byteData,
//   String watermarkText,
// ) async {
//   debugPrint("🔧 Starting image processing...");
//   debugPrint(
//       "📏 Original size: ${(byteData.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB");

//   const int targetSizeBytes = 200 * 1024; // 200 KB

//   // 🧠 Step 1: If already small, watermark and return
//   if (byteData.lengthInBytes <= targetSizeBytes) {
//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: byteData,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );
//     return watermarked;
//   }

//   // 📸 Step 2: Decode to get dimensions
//   img.Image? decodedImage = img.decodeImage(byteData);
//   if (decodedImage == null) throw Exception("Failed to decode image");

//   int width = decodedImage.width;
//   int height = decodedImage.height;

//   // 📏 Step 3: Resize to max 800px on longer side
//   const maxDimension = 800;
//   if (width > height) {
//     width = maxDimension;
//     height = (decodedImage.height / decodedImage.width * maxDimension).round();
//   } else {
//     height = maxDimension;
//     width = (decodedImage.width / decodedImage.height * maxDimension).round();
//   }

//   // 🔁 Step 4: Try compressing with decreasing quality
//   for (int quality = 90; quality >= 30; quality -= 5) {
//     Uint8List? compressed = await FlutterImageCompress.compressWithList(
//       byteData,
//       minWidth: width,
//       minHeight: height,
//       quality: quality,
//       format: CompressFormat.jpeg,
//     );

//     // 🖋️ Step 5: Add watermark
//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: compressed,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );

//     if (watermarked.lengthInBytes <= targetSizeBytes) {
//       return watermarked;
//     }
//   }

//   // 🪓 Step 6: Further reduce dimensions if needed
//   while (width > 200 && height > 200) {
//     width = (width * 0.9).toInt();
//     height = (height * 0.9).toInt();

//     Uint8List? compressed = await FlutterImageCompress.compressWithList(
//       byteData,
//       minWidth: width,
//       minHeight: height,
//       quality: 30,
//       format: CompressFormat.jpeg,
//     );

//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: compressed,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );

//     if (watermarked.lengthInBytes <= targetSizeBytes) {
//       return watermarked;
//     }
//   }

//   throw Exception("Couldn't compress image below 500 KB even after resizing.");
// }

// // Uncomment this if you want to ristrict the image size to 1.5 MB
// /*
// Future<Uint8List> resizeAndWatermarkImage(
//   Uint8List byteData,
//   String watermarkText,
// ) async {
//   debugPrint("🔧 Starting image processing...");
//   debugPrint(
//       "📏 Image size: ${(byteData.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB");
//   final int maxSizeBytes = (1.5 * 1024 * 1024).toInt(); // 1.5 MB
//   const int targetSizeBytes = 500 * 1024; // 500 KB

//   // 🧠 Step 1: If already small, watermark and return
//   if (byteData.lengthInBytes <= targetSizeBytes) {
//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: byteData,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );

//     if (watermarked.lengthInBytes <= maxSizeBytes) return watermarked;

//     throw Exception("Watermarked image exceeds 1.5 MB limit.");
//   }

//   // 📸 Step 2: Decode image using `image` package just to get dimensions
//   img.Image? decodedImage = img.decodeImage(byteData);
//   if (decodedImage == null) throw Exception("Failed to decode image");

//   int width = decodedImage.width;
//   int height = decodedImage.height;

//   // 📏 Step 3: Resize the image to max 800px on longest side
//   const maxDimension = 800;
//   if (width > height) {
//     width = maxDimension;
//     height = (decodedImage.height / decodedImage.width * maxDimension).round();
//   } else {
//     height = maxDimension;
//     width = (decodedImage.width / decodedImage.height * maxDimension).round();
//   }

//   // 🔁 Step 4: Try compressing with decreasing quality
//   for (int quality = 90; quality >= 30; quality -= 5) {
//     Uint8List? compressed = await FlutterImageCompress.compressWithList(
//       byteData,
//       minWidth: width,
//       minHeight: height,
//       quality: quality,
//       format: CompressFormat.jpeg,
//     );

//     // 🖋️ Step 5: Watermark it
//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: compressed,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );

//     if (watermarked.lengthInBytes <= targetSizeBytes) {
//       return watermarked;
//     } else if (quality <= 30 && watermarked.lengthInBytes <= maxSizeBytes) {
//       return watermarked;
//     }

//     // Uncomment this if you wanna log:
//     // print("📦 Quality $quality: ${(watermarked.lengthInBytes / 1024).toStringAsFixed(2)} KB");
//   }

//   // 🪓 Step 6: If still big, reduce dimensions further
//   while (width > 200 && height > 200) {
//     width = (width * 0.9).toInt();
//     height = (height * 0.9).toInt();

//     Uint8List? compressed = await FlutterImageCompress.compressWithList(
//       byteData,
//       minWidth: width,
//       minHeight: height,
//       quality: 30,
//       format: CompressFormat.jpeg,
//     );

//     Uint8List watermarked = await ImageWatermark.addTextWatermark(
//       imgBytes: compressed,
//       font: null,
//       watermarkText: watermarkText,
//       dstX: 20,
//       dstY: 30,
//     );

//     if (watermarked.lengthInBytes <= targetSizeBytes) return watermarked;
//     if (watermarked.lengthInBytes <= maxSizeBytes) return watermarked;
//   }

//   throw Exception("Couldn't compress image below 1.2MB even after resizing.");
// }
// */

// Future<void> storeImagePath(XFile file) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setString('imagePath', file.path);
// }

// // Retrieve XFile path from SharedPreferences
// Future<XFile?> retrieveImagePath() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final String? imagePath = prefs.getString('imagePath');
//   if (imagePath != null) {
//     return XFile(imagePath);
//   }
//   return null;
// }

// //we can upload image from camera or from gallery based on parameter
// Future<bool> storeImagesInSharedPref(
//   String imagePath,
//   String checkListId,
// ) async {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   return pref.setString(checkListId, imagePath);
// }

// Future<void> clearImageFromSharedPreferences(checkListId) async {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   pref.remove(checkListId);
// }

// Future<XFile> getPrefImage(checkListId) async {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   var imagePath1 = pref.getString(checkListId.toString());
//   return XFile(imagePath1 ?? '');
// }
