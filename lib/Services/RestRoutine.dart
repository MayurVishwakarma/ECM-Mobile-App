// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckListModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineScountModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineTimeModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();
var headers = {'Content-Type': 'application/json'};

Future<List<RoutineCheckMasterModel>> getRoutineNodeList({
  String? search = '',
  String? areaId = 'all',
  String? distibutoryId = 'all',
  int? routineStatus = 3,
  int? dateSort = 0,
  int? nextSchedule = 0,
  required int? index,
  int? limit = 15,
  required String? source,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');
    final url =
        'http://ecmtest.iotwater.in:3011/api/v1/routine/routineNodeList?search=$search&areaId=$areaId&distributoryId=$distibutoryId&routineStatus=$routineStatus&dateSort=$dateSort&StartDate=1900-01-01&EndDate=1900-01-01&NextSchedule=$nextSchedule&deviceType=$source&index=$index&limit=$limit&projectId=$projectId';
    final response = await dio.request(
      url,
      options: Options(
        method: 'GET',
      ),
    );

    if (response.statusCode == 200) {
      List<RoutineCheckMasterModel> result = [];
      response.data['data']['Response'].forEach((v) {
        result.add(RoutineCheckMasterModel.fromJson(v));
      });
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception(e);
  }
}

Future<String?> uploadRoutineImage(
    String filePath, String deviceType, int deviceId) async {
  try {
    final fileName = filePath.split('/').last;
    final prefs = await SharedPreferences.getInstance();

    final projectId = prefs.getString('ProjectId');

    final formData = FormData.fromMap({
      'ecmFile': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final url =
        'http://ecmtest.iotwater.in:3011/api/v1/routine_images/$projectId/$deviceType/$deviceId';

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

Future<List<RoutineCheckListModel>> getRoutineCheckList(
    String deviceId, String source) async {
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
        'http://ecmtest.iotwater.in:3011/api/v1/routine/routineReport/$projectId/$deviceId';

    print("URL: $url");

    final response = await dio.get(url);

    if (response.statusCode == 200 && response.data != null) {
      print("Response Data: ${response.requestOptions.connectTimeout}");

      final data = response.data['data']?['Response'];

      if (data is List) {
        return data
            .map((item) => RoutineCheckListModel.fromJson(item))
            .toList();
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

Future<bool> uploadRoutineReport(dynamic payload) async {
  try {
    var response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/routine/savereoutinereport',
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
      } else {
        throw Exception();
      }
    } else {
      return false;
    }
  } catch (e) {
    print(jsonDecode(e.toString()));
    // Handle any errors that occur during the request
    throw Exception("Failed to upload ECM report");
  }
}

Future<bool> updateRoutineTime(int days) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');
    final url =
        'http://ecmtest.iotwater.in:3011/api/v1/routine/routineTime?routineTime=$days&projectId=$projectId';
    final response = await dio.request(
      url,
      options: Options(
        method: 'PUT',
      ),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception(e);
  }
}

Future<int> getRoutineTime() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');

    if (projectId == null || projectId.isEmpty) {
      throw Exception('Project ID not found in SharedPreferences');
    }

    final Dio dio = Dio();
    final String url =
        'http://ecmtest.iotwater.in:3011/api/v1/routine/routineTime?projectId=$projectId';

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final routineTimeModel = RoutineTimeModel.fromJson(jsonResponse);

      final daysList = routineTimeModel.data?.response;

      if (daysList != null) {
        return daysList.first.days ?? 0;
      }

      return 0;
    } else {
      print('Failed to fetch routine time: ${response.statusCode}');
      return 0;
    }
  } catch (e) {
    print('Error in getRoutineTime: $e');
    return 0;
  }
}

Future<RoutineScountModel> getRoutineCheckStatusCount({
  String? search = '',
  String? areaId = 'all',
  String? distibutoryId = 'all',
  int? routineStatus = 3,
  int? nextSchedule = 0,
  required String? source,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');
    final url =
        'http://ecmtest.iotwater.in:3011/api/v1/routine/routinestatuscount?search=$search&areaId=$areaId&distributoryId=$distibutoryId&routineStatus=$routineStatus&StartDate=1900-01-01&EndDate=1900-01-01&NextSchedule=$nextSchedule&deviceType=$source&projectId=$projectId';
    final response = await dio.request(
      url,
      options: Options(
        method: 'GET',
      ),
    );
    if (response.statusCode == 200) {
      // var json = jsonDecode(response.body);

      RoutineScountModel result =
          RoutineScountModel.fromJson(response.data['data']['Response'][0]);
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception('Failed to load API');
  }
}
