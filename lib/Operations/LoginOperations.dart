// ignore_for_file: file_names, unused_catch_stack

import 'package:dio/dio.dart';
import 'dart:async';
import 'package:ecm_application/Model/Project/Login/LoginModel.dart';

final dio = Dio();
var headers = {'Content-Type': 'application/json'};
Future<LoginMasterModel?> fetchLoginDetails(dynamic payload) async {
  try {
    final url = 'http://ecmtest.iotwater.in:3011/api/v1/auth/login';
    var response = await dio.request(
      url,
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: payload,
    );
    if (response.statusCode == 200) {
      var json = response.data;
      if (json["Status"] == "Ok") {
        LoginMasterModel loginResult =
            LoginMasterModel.fromJson(json['data']['Response'][0]);
        return loginResult;
      } else {
        throw Exception();
      }
    } else {
      throw Exception("API Consumed Failed");
    }
  } catch (ex) {
    throw Exception(ex);
  }
}

/*Future<LoginMasterModel?> fetchLoginDetails(String mobno, String passwd) async {
  try {
    final response = await http.get(Uri.parse(GetHttpRequest(
        WebApiLoginPrefix, 'Login?MobNo=$mobno&Password=$passwd')));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['Status'] == WebApiStatusOk) {
        LoginMasterModel loginResult =
            LoginMasterModel.fromJson(json['data']['Response']);
        return loginResult;
      } else {
        throw Exception("Login Failed");
      }
    } else {
      throw Exception("Login Failed");
    }
  } on Exception catch (_, ex) {
    return null;
  }
}
*/
