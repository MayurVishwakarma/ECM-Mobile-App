// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, unused_catch_stack, unused_import, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecm_application/Model/Project/Constants.dart';
import 'package:ecm_application/Model/Project/ECMTool/ECMCountMasterModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/ECM_Checklist_Model.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSListViewModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckListModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RestService.dart';

final dio = Dio();
var headers = {'Content-Type': 'application/json'};
Future<List<ECM_Checklist_Model>> getECMProcess(String source) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');
    final response = await http.get(Uri.parse(GetHttpRequest(
        WebApiPmsPrefix, 'ECMProcessId?Source=$source&conString=$conString')));
    print(WebApiPmsPrefix + 'ECMProcessId?Source=$source&conString=$conString');
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<ECM_Checklist_Model> result = <ECM_Checklist_Model>[];
      json['data']['Response']
          .forEach((v) => result.add(ECM_Checklist_Model.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (_, ex) {
    throw Exception("API Consumed Failed");
  }
}

Future<List<ECM_Checklist_Model>> getECMCheckListByProcessId(
  int deviceId,
  int processId,
  String source,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final projectId = prefs.getString('ProjectId');

    if (projectId == null || projectId.isEmpty) {
      throw Exception('Project ID not found.');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ));

    final url =
        'http://ecmv2.iotwater.in:3011/api/v1/ecm/ecmdetailreport/$projectId/$processId/$source/$deviceId';

    print("URL: $url");

    final response = await dio.get(url);

    if (response.statusCode == 200 && response.data != null) {
      print("Response Data: ${response.requestOptions.connectTimeout}");

      final data = response.data['data']?['Response'];

      if (data is List) {
        return data.map((item) => ECM_Checklist_Model.fromJson(item)).toList();
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed with status: ${response.statusCode}");
    }
  } on DioException catch (dioError) {
    print("DioException: ${dioError.message}");
    throw Exception("Network error occurred");
  } catch (e) {
    print("Unexpected error: $e");
    throw Exception("An error occurred while fetching ECM checklist");
  }
}
/*
Future<String?> uploadImage(String ImagePath, XFile? image) async {
  try {
    if (image == null || image.path.isEmpty) {
      debugPrint("Image is null or path is empty.");
      return '';
    }

    // Log the image path for debugging
    debugPrint("Uploading image from path: ${image.path}");

    // Create the multipart file
    var imgData = await http.MultipartFile.fromPath('Image', image.path);

    // Create the request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://wmsservices.seprojects.in/api/PMS?imgDirPath=$ImagePath&Api=2'),
    );

    request.files.add(imgData);

    // Log the request details
    debugPrint("Request prepared: $request");

    // Send the request
    http.StreamedResponse response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      debugPrint("Image uploaded successfully.");
      var path = await response.stream.bytesToString();
      if (path == '""') {
        debugPrint("Empty path returned by the server.");
        return '';
      } else {
        debugPrint("Server returned path: $path");
        return path.replaceAll('"', '');
      }
    } else {
      debugPrint("Failed to upload image. Status code: ${response.statusCode}");
      return '';
    }
  } catch (e) {
    // Catch any errors and log them
    debugPrint("Error during image upload: $e");
    return '';
  }
}
*/
/*Future<String?> uploadImageAndGetPath(
    String filePath, String deviceType, int deviceId) async {
  try {
    final dio = Dio();

    final fileName = filePath.split('/').last;
    final prefs = await SharedPreferences.getInstance();

    final projectId = prefs.getString('ProjectId');
    // Prepare FormData
    final formData = FormData.fromMap({
      'files': [
        await MultipartFile.fromFile(filePath, filename: fileName),
      ],
    });

    // Endpoint URL
    final url =
        'http://ecmv2.iotwater.in:3011aa/api/v1/ecm_images/$projectId/$deviceType/$deviceId';

    final response = await dio.request(
      url,
      options: Options(method: 'POST'),
      data: formData,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      print(data);
      final imagePath = data;
      return imagePath.toString();
    } else {
      print('Failed: ${response.statusCode} - ${response.statusMessage}');
      return null;
    }
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}


*/

Future<String?> uploadImageAndGetPath(
    String filePath, String deviceType, int deviceId) async {
  try {
    final fileName = filePath.split('/').last;
    final prefs = await SharedPreferences.getInstance();

    final projectId = prefs.getString('ProjectId');

    final formData = FormData.fromMap({
      'ecmFile': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final url =
        'http://ecmv2.iotwater.in:3011/api/v1/ecm_images/$projectId/$deviceType/$deviceId';

    final response = await dio.post(url, data: formData);

    if (response.statusCode == 200 && response.data != null) {
      // Response is a plain text path string like: /SEE...
      return response.data.toString().trim();
    } else {
      print(
          '❌ Upload failed with status: ${response.statusCode} - ${response.statusMessage}');
      return null;
    }
  } catch (e) {
    print('❌ Error uploading file: $e');
    return null;
  }
}

Future<bool> uploadECMReport(dynamic payload) async {
  try {
    var response = await dio.request(
      'http://ecmv2.iotwater.in:3011/api/v1/ecm/saveecmreport',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: payload,
    );

    if (response.statusCode == 200) {
      var json = response.data;
      if (json["Status"] == "Ok") {
        return true;
      } else
        throw new Exception();
    } else {
      return false;
    }
  } catch (e) {
    print(jsonDecode(e.toString()));
    throw Exception("Failed to upload ECM report");
  }
}

Future<List<PMSListViewModel>?> getEcmStatusList({
  String? search = '',
  String? areaId = 'all',
  String? distibutoryId = 'all',
  String? processId = 'all',
  String? subProcessId = 'all',
  required int? index,
  int? limit = 15,
  required String? source,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    final projectId = prefs.getString('ProjectId');
   
    final response = await dio.request(
      'http://ecmv2.iotwater.in:3011/api/v1/ecm/ecmreportlist?search=${search}&areaId=${areaId}&distributoryId=${distibutoryId}&processId=${processId}&subProcessId=${subProcessId}&deviceType=$source&index=$index&limit=$limit&projectId=$projectId',
      options: Options(
        method: 'GET',
      ),
    );

    if (response.statusCode == 200) {
      List<PMSListViewModel> result = [];
      response.data['data']['Response'].forEach((v) {
        result.add(PMSListViewModel.fromJson(v));
      });
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception('Failed to load API');
  }
}

Future<ECMStatusCountMasterModel> getECMReportStatusCoun(
    String? area, distibutory, source) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final projectId = preferences.getString('ProjectId');

    final response = await http.get(Uri.parse(
        'http://ecmv2.iotwater.in:3011/api/v1/ecm/ecmreportcount?search&areaId=$area&distributoryId=$distibutory&processId=all&subProcessId=all&deviceType=$source&projectId=$projectId'));
    print(
        'http://ecmv2.iotwater.in:3011/api/v1/ecm/ecmreportcount?search&areaId=$area&distributoryId=$distibutory&processId=all&subProcessId=all&deviceType=$source&projectId=$projectId');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      ECMStatusCountMasterModel result =
          ECMStatusCountMasterModel.fromJson(json['data']['Response'][0]);
      print(result.sCount);
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception('Failed to load API :${e}');
  }
}

/*Future<List<ECM_Checklist_Model>> getECMCheckListByProcessId(
    int _deviceId, int _processId, String _source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(GetHttpRequest(WebApiPmsPrefix,
        'ECMReport?deviceId=$_deviceId&ProcessId=$_processId&Source=$_source&conString=$conString')));
    print(WebApiPmsPrefix +
        'ECMReport?deviceId=$_deviceId&ProcessId=$_processId&Source=$_source&conString=$conString');
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<ECM_Checklist_Model> result = <ECM_Checklist_Model>[];
      json['data']['Response']
          .forEach((v) => result.add(ECM_Checklist_Model.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (_, ex) {
    throw Exception("API Consumed Failed");
  }
}*/
/*Future<List<ECM_Checklist_Model>> getOMSECMCheckListByProcessId(
    int _deviceId, int _processId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(GetHttpRequest(WebApiPmsPrefix,
        'OmsECMReport_New?omsId=$_deviceId&ProcessId=$_processId&conString=$conString')));
    print(WebApiPmsPrefix +
        'OmsECMReport_New?omsId=$_deviceId&ProcessId=$_processId&conString=$conString');
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<ECM_Checklist_Model> result = <ECM_Checklist_Model>[];
      json['data']['Response']
          .forEach((v) => result.add(ECM_Checklist_Model.fromJson(v)));
      return result
          .where((element) => element.processId == _processId)
          .toList();
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (_, ex) {
    throw Exception("API Consumed Failed");
  }
}
*/
// Future<List<Damage_CheckList>> getOMSDamageByDeviceId(int _deviceId) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   String? conString = preferences.getString('ConString');
//   try {
//     final response = await http.get(Uri.parse(
//         'http://wmsservices.seprojects.in/api/Rectify/RectifyReport?deviceId=$_deviceId&source=OMS&conString=$conString'));
//     print(
//         'http://wmsservices.seprojects.in/api/Rectify/RectifyReport?deviceId=$_deviceId&source=OMS&conString=$conString');
//     var json = jsonDecode(response.body);
//     if (response.statusCode == 200) {
//       List<Damage_CheckList> result = <Damage_CheckList>[];
//       json['data']['Response']
//           .forEach((v) => result.add(Damage_CheckList.fromJson(v)));
//       return result;
//     } else {
//       throw Exception("API Consumed Failed");
//     }
//   } on Exception catch (_, ex) {
//     throw Exception("API Consumed Failed");
//   }
// }
