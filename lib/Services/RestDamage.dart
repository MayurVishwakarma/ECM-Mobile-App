// ignore_for_file: avoid_print, non_constant_identifier_names, unused_catch_stack

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ecm_application/Model/Project/Damage/DamageCommanModel.dart';
import 'package:ecm_application/Model/Project/Damage/DamageHistory.dart';
import 'package:ecm_application/Model/Project/Damage/DamageInformation.dart';
import 'package:ecm_application/Model/Project/Damage/Information.dart';
import 'package:ecm_application/Model/Project/Damage/IssuesMasterModel.dart';
import 'package:ecm_application/Model/Project/Damage/MaterialConsumption.dart';
import 'package:ecm_application/Model/Project/Damage/MaterialConsumptionHistoryModel.dart';
import 'package:ecm_application/Model/Project/Damage/OmsDamageModel.dart';
import 'package:ecm_application/Model/Project/Damage/SurveyInsertModel%20.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final dio = Dio();
var headers = {'Content-Type': 'application/json'};

Future<List<DamageInsertModel>> getDamageform(
    int deviceId, String? deviceType) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? projectId = preferences.getString('ProjectId');
  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/damageDetailReport/$projectId/$deviceType/$deviceId'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/damageDetailReport/$projectId/$deviceType/$deviceId');

    if (response.statusCode == 200) {
      List<DamageInsertModel> result = <DamageInsertModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(DamageInsertModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<SurveyInsertModel>> getSurveyformOms(int deviceId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/OMS/OmsSurveyReport?omsId=$deviceId&conString=$conString'));
    print(
        'http://wmsservices.seprojects.in/api/OMS/OmsSurveyReport?omsId=$deviceId&conString=$conString');

    if (response.statusCode == 200) {
      List<SurveyInsertModel> result = <SurveyInsertModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(SurveyInsertModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

/*Future<List<DamageInsertModel>> getDamageformAms(int deviceId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/AMS/AmsDamageReport_New?amsId=$deviceId&conString=$conString'));
    print(
        'http://wmsservices.seprojects.in/api/AMS/AmsDamageReport_New?amsId=$deviceId&conString=$conString');
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<DamageInsertModel> result = <DamageInsertModel>[];
      json['data']['Response']
          .forEach((v) => result.add(DamageInsertModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageInsertModel>> getDamageformLora(int deviceId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/LoRa/LoRaDamageReport_New?GatewayId=$deviceId&conString=$conString'));
    print(
        'http://wmsservices.seprojects.in/api/LoRa/LoRaDamageReport_New?GatewayId=$deviceId&conString=$conString');
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<DamageInsertModel> result = <DamageInsertModel>[];
      json['data']['Response']
          .forEach((v) => result.add(DamageInsertModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageInsertModel>> getDamageformRms(int deviceId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? conString = preferences.getString('ConString');
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/RMS/RmsDamageReport_New?rmsId=$deviceId&conString=$conString'));
    print(
        'http://wmsservices.seprojects.in/api/RMS/RmsDamageReport_New?rmsId=$deviceId&conString=$conString');
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<DamageInsertModel> result = <DamageInsertModel>[];
      json['data']['Response']
          .forEach((v) => result.add(DamageInsertModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}
*/
Future<List<MaterialConsumptionModel>> getDamageformCommon(
    int deviceId, String source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? projectId = preferences.getString('ProjectId');
  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/materialConsumption/$projectId/$source/$deviceId'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/materialConsumption/$projectId/$source/$deviceId');

    if (response.statusCode == 200) {
      List<MaterialConsumptionModel> result = <MaterialConsumptionModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(MaterialConsumptionModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageHistory>> getDamageHistorCommon(
    int deviceId, String source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? projectId = preferences.getString('ProjectId');

  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/damageHistoryreport?deviceId=$deviceId&startDate=1900-01-01&endDate=1900-01-01&index=0&limit=1500&deviceType=$source&projectId=$projectId'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/damageHistoryreport?deviceId=$deviceId&startDate=1900-01-01&endDate=1900-01-01&index=0&limit=1500&deviceType=$source&projectId=$projectId');

    if (response.statusCode == 200) {
      List<DamageHistory> result = <DamageHistory>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(DamageHistory.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<MaterialConsumptionHistoryDamageModel>>
    getMaterialConsumptionHistory(int deviceId, String source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // String? conString = preferences.getString('ConString');
  String? projectId = preferences.getString('ProjectId');

  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/materialConsumptionSummaryReport/$projectId/$deviceId/$source'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/materialConsumptionSummaryReport/$projectId/$deviceId/$source');

    if (response.statusCode == 200) {
      List<MaterialConsumptionHistoryDamageModel> result =
          <MaterialConsumptionHistoryDamageModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response'].forEach(
          (v) => result.add(MaterialConsumptionHistoryDamageModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<InfoModel>> Infomation(int deviceId, String source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? projectId = preferences.getString('ProjectId');

  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationReport/$projectId/$source/$deviceId/1'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationReport/$projectId/$source/$deviceId/1');

    if (response.statusCode == 200) {
      List<InfoModel> result = <InfoModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(InfoModel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageIssuesMasterModel>> Issues(
    int deviceId, String source) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? projectId = preferences.getString('ProjectId');

  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationReport/$projectId/$source/$deviceId/2'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationReport/$projectId/$source/$deviceId/2');

    if (response.statusCode == 200) {
      List<DamageIssuesMasterModel> result = <DamageIssuesMasterModel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(DamageIssuesMasterModel.fromJson(v)));

      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageInformationmodel>> getDamageInformationCommon(
    int deviceId, String source, String infotype) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? projectId = preferences.getString('ProjectId');

  try {
    final response = await http.get(Uri.parse(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationSummaryReport/$projectId/$deviceId/$source/$infotype'));
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/informationSummaryReport/$projectId/$deviceId/$source/$infotype');

    if (response.statusCode == 200) {
      List<DamageInformationmodel> result = <DamageInformationmodel>[];
      var json = jsonDecode(response.body);
      json['data']['Response']
          .forEach((v) => result.add(DamageInformationmodel.fromJson(v)));
      return result;
    } else {
      throw Exception("API Consumed Failed");
    }
  } on Exception catch (e) {
    print(e.toString());
    throw Exception("API Consumed Failed");
  }
}

Future<List<DamageModel>?> getDamageStatusList({
  String? search = '',
  String? areaId = 'all',
  String? distibutoryId = 'all',
  required int? index,
  int? limit = 15,
  required String? source,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // final conString = await prefs.getString('ConString');
    final projectId = prefs.getString('ProjectId');
    print(
        'http://ecmtest.iotwater.in:3011/api/v1/damage/damageReportList?search=${search}&areaId=${areaId}&distributoryId=${distibutoryId}&deviceType=${source}&index=${index}&limit=${limit}&projectId=$projectId');
    final response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/damage/damageReportList?search=${search}&areaId=${areaId}&distributoryId=${distibutoryId}&deviceType=${source}&index=${index}&limit=${limit}&projectId=$projectId',
      options: Options(
        method: 'GET',
      ),
    );

    if (response.statusCode == 200) {
      List<DamageModel> result = [];
      response.data['data']['Response'].forEach((v) {
        result.add(DamageModel.fromJson(v));
      });
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception('Failed to load API');
  }
}

Future<bool> uploadDamageReport(dynamic payload) async {
  try {
    var response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/damage/savedamagereport',
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
      // throw Exception("API Consumed Failed");
    }
  } catch (e) {
    print(jsonDecode(e.toString()));
    // Handle any errors that occur during the request
    throw Exception("Failed to upload ECM report");
  }
}

Future<bool> uploadMaterialConsumptionReport(dynamic payload) async {
  try {
    var response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/damage/savematerialconsumptionreport',
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
      // throw Exception("API Consumed Failed");
    }
  } catch (e) {
    print(jsonDecode(e.toString()));
    // Handle any errors that occur during the request
    throw Exception("Failed to upload ECM report");
  }
}

Future<bool> uploadInfromationReport(dynamic payload) async {
  try {
    var response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/damage/saveinformationreport',
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
      // throw Exception("API Consumed Failed");
    }
  } catch (e) {
    print(jsonDecode(e.toString()));
    // Handle any errors that occur during the request
    throw Exception("Failed to upload ECM report");
  }
}

/*
Future<List<DamageModel>?> getDamageHistoryList({
  String? search = '',
  String? areaId = 'all',
  String? distibutoryId = 'all',
  required int? index,
  int? limit = 15,
  required String? source,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');
    final response = await dio.request(
      'http://ecmtest.iotwater.in:3011/api/v1/damage/damageReportList?search=$search&areaId=$areaId&distributoryId=$distibutoryId&deviceType=$source&index=$index&limit=$limit&projectId=$projectId',
      options: Options(
        method: 'GET',
      ),
    );

    if (response.statusCode == 200) {
      List<DamageModel> result = [];
      response.data['data']['Response'].forEach((v) {
        result.add(DamageModel.fromJson(v));
      });
      return result;
    } else {
      throw Exception('Failed to load API');
    }
  } catch (e) {
    throw Exception('Failed to load API');
  }
}
*/
