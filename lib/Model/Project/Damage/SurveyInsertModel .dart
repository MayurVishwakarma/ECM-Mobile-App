import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class SurveyInsertModel {
  int? surveyId;
  String? description;
  String? type;
  String? datetime;
  dynamic userId;
  dynamic omsId;
  String? value;
  String? inputType;
  Uint8List? imageByteArray;
  String? remark;
  int? mTransId;
  XFile? image;

  SurveyInsertModel(
      {this.surveyId,
      this.description,
      this.type,
      this.datetime,
      this.userId,
      this.omsId,
      this.value,
      this.inputType,
      this.imageByteArray,
      this.remark,
      this.mTransId,
      this.image});

  SurveyInsertModel.fromJson(Map<String, dynamic> json) {
    surveyId = json['SurveyId'];
    description = json['Description'];
    type = json['Type'];
    datetime = json['Datetime'];
    userId = json['UserId'];
    omsId = json['OmsId'];
    value = json['Value'];
    inputType = json['InputType'];
    if (json['imageByteArray'] != null) {
      imageByteArray = base64.decode(json['imageByteArray']);
    }
    remark = json['remark'];
    mTransId = json['MTransId'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SurveyId'] = this.surveyId;
    data['Description'] = this.description;
    data['Type'] = this.type;
    data['Datetime'] = this.datetime;
    data['UserId'] = this.userId;
    data['OmsId'] = this.omsId;
    data['Value'] = this.value;
    data['InputType'] = this.inputType;
    data['imageByteArray'] = this.imageByteArray;
    data['remark'] = this.remark;
    data['MTransId'] = this.mTransId;
    data['image'] = this.image;
    return data;
  }
}
