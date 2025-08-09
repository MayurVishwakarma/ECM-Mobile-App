// ignore_for_file: unnecessary_new

import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ECM_Checklist_Model {
  int? checkListId;
  int? subProcessId;
  int? processId;
  String? description;
  int? seqNo;
  String? inputType;
  String? inputText;
  String? value;
  String? subProcessName;
  String? processName;
  int? approvedStatus;
  int? workedBy;
  String? workedOn;
  int? approvedBy;
  String? approvedOn;
  String? tempDT;
  String? remark;
  String? approvalRemark;
  Uint8List? imageByteArray;
  int? isMultiValue;
  int? subChakQty;
  String? deviceType;
  String? downlink;
  String? macAddress;
  String? subscribeTopicName;
  String? parameterName;
  int? isBullet;
  int? isBulletHeader;
  String? comment;
  String? coordinate;
  String? dataType;
  String? source;
  int? deviceId;
  String? conString;
  int? userId;
  String? siteTeamEngineer;
  bool? issiteTeamEngineer;
  XFile? image;
  String? issaved;

  ECM_Checklist_Model({
    this.checkListId,
    this.subProcessId,
    this.processId,
    this.description,
    this.seqNo,
    this.inputType,
    this.inputText,
    this.value,
    this.subProcessName,
    this.processName,
    this.approvedStatus,
    this.workedBy,
    this.workedOn,
    this.approvedBy,
    this.approvedOn,
    this.tempDT,
    this.remark,
    this.approvalRemark,
    this.imageByteArray,
    this.isMultiValue,
    this.subChakQty,
    this.deviceType,
    this.downlink,
    this.macAddress,
    this.subscribeTopicName,
    this.parameterName,
    this.isBullet,
    this.isBulletHeader,
    this.comment,
    this.coordinate,
    this.dataType,
    this.source,
    this.deviceId,
    this.conString,
    this.userId,
    this.siteTeamEngineer,
    this.issiteTeamEngineer,
    this.image,
    this.issaved,
  });

  factory ECM_Checklist_Model.fromJson(Map<String, dynamic> json) {
    return ECM_Checklist_Model(
      checkListId: int.tryParse(json['CheckListId']?.toString() ?? ''),
      subProcessId: int.tryParse(json['SubProcessId']?.toString() ?? ''),
      processId: int.tryParse(json['ProcessId']?.toString() ?? ''),
      description: json['Description'],
      seqNo: int.tryParse(json['SeqNo']?.toString() ?? ''),
      inputType: json['InputType'],
      inputText: json['InputText'],
      value: json['Value'],
      subProcessName: json['SubProcessName'],
      processName: json['ProcessName'],
      approvedStatus: int.tryParse(json['ApprovedStatus']?.toString() ?? ''),
      workedBy: int.tryParse(json['WorkedBy']?.toString() ?? ''),
      workedOn: json['WorkedOn'],
      approvedBy: int.tryParse(json['ApprovedBy']?.toString() ?? ''),
      approvedOn: json['ApprovedOn'],
      tempDT: json['TempDT'],
      remark: json['Remark'],
      approvalRemark: json['ApprovalRemark'],
      imageByteArray:
          json['imageByteArray'] != null && json['imageByteArray'] != ''
              ? base64.decode(json['imageByteArray'])
              : null,
      isMultiValue: int.tryParse(json['IsMultiValue']?.toString() ?? ''),
      subChakQty: int.tryParse(json['SubChakQty']?.toString() ?? ''),
      deviceType: json['DeviceType'],
      downlink: json['Downlink'],
      macAddress: json['MacAddress'],
      subscribeTopicName: json['SubscribeTopicName'],
      parameterName: json['ParameterName'],
      isBullet: int.tryParse(json['IsBullet']?.toString() ?? ''),
      isBulletHeader: int.tryParse(json['IsBulletHeader']?.toString() ?? ''),
      comment: json['Comment'],
      coordinate: json['Coordinate'],
      dataType: json['DataType'],
      source: json['Source'],
      deviceId: int.tryParse(json['DeviceId']?.toString() ?? ''),
      conString: json['conString'],
      userId: int.tryParse(json['UserId']?.toString() ?? ''),
      siteTeamEngineer: json['SiteTeamEngineer'],
      issaved: json['issaved'],
      image: null, // Must be assigned manually later if needed
      issiteTeamEngineer: json['issiteTeamEngineer'] is bool
          ? json['issiteTeamEngineer']
          : json['issiteTeamEngineer'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CheckListId': checkListId,
      'SubProcessId': subProcessId,
      'ProcessId': processId,
      'Description': description,
      'SeqNo': seqNo,
      'InputType': inputType,
      'InputText': inputText,
      'Value': value,
      'SubProcessName': subProcessName,
      'ProcessName': processName,
      'ApprovedStatus': approvedStatus,
      'WorkedBy': workedBy,
      'WorkedOn': workedOn,
      'ApprovedBy': approvedBy,
      'ApprovedOn': approvedOn,
      'TempDT': tempDT,
      'Remark': remark,
      'ApprovalRemark': approvalRemark,
      'imageByteArray':
          imageByteArray != null ? base64.encode(imageByteArray!) : null,
      'IsMultiValue': isMultiValue,
      'SubChakQty': subChakQty,
      'DeviceType': deviceType,
      'Downlink': downlink,
      'MacAddress': macAddress,
      'SubscribeTopicName': subscribeTopicName,
      'ParameterName': parameterName,
      'IsBullet': isBullet,
      'IsBulletHeader': isBulletHeader,
      'Comment': comment,
      'Coordinate': coordinate,
      'DataType': dataType,
      'Source': source,
      'DeviceId': deviceId,
      'conString': conString,
      'UserId': userId,
      'SiteTeamEngineer': siteTeamEngineer,
      'issaved': issaved,
      'issiteTeamEngineer': issiteTeamEngineer,
      // 'image': image != null ? image!.path : null, // Not serializable automatically
    };
  }
}

/*
class ECM_Checklist_Model {
  int? checkListId;
  int? subProcessId;
  int? processId;
  String? description;
  int? seqNo;
  String? inputType;
  String? inputText;
  String? value;
  String? subProcessName;
  String? processName;
  int? approvedStatus;
  int? workedBy;
  String? workedOn;
  int? approvedBy;
  String? approvedOn;
  String? tempDT;
  String? remark;
  String? approvalRemark;
  Uint8List? imageByteArray;
  int? isMultiValue;
  int? subChakQty;
  String? deviceType;
  String? downlink;
  String? macAddress;
  String? subscribeTopicName;
  String? parameterName;
  int? isBullet;
  int? isBulletHeader;
  String? comment;
  String? coordinate;
  String? dataType;
  String? source;
  int? deviceId;
  String? conString;
  int? userId;
  String? siteTeamEngineer;
  bool? issiteTeamEngineer;
  XFile? image;
  String? issaved;

  ECM_Checklist_Model(
      {this.checkListId,
      this.subProcessId,
      this.processId,
      this.description,
      this.seqNo,
      this.inputType,
      this.inputText,
      this.value,
      this.subProcessName,
      this.processName,
      this.approvedStatus,
      this.workedBy,
      this.workedOn,
      this.approvedBy,
      this.approvedOn,
      this.tempDT,
      this.remark,
      this.approvalRemark,
      this.imageByteArray,
      this.isMultiValue,
      this.subChakQty,
      this.deviceType,
      this.downlink,
      this.macAddress,
      this.subscribeTopicName,
      this.parameterName,
      this.isBullet,
      this.isBulletHeader,
      this.comment,
      this.coordinate,
      this.dataType,
      this.source,
      this.deviceId,
      this.conString,
      this.userId,
      this.siteTeamEngineer,
      this.image,
      this.issaved,
      this.issiteTeamEngineer});

  ECM_Checklist_Model.fromJson(Map<String, dynamic> json) {
    checkListId = json['CheckListId'];
    subProcessId = json['SubProcessId'];
    processId = json['ProcessId'];
    description = json['Description'];
    seqNo = json['SeqNo'];
    inputType = json['InputType'];
    inputText = json['InputText'];
    value = json['Value'];
    subProcessName = json['SubProcessName'];
    processName = json['ProcessName'];
    approvedStatus = json['ApprovedStatus'];
    workedBy = json['WorkedBy'];
    workedOn = json['WorkedOn'];
    approvedBy = json['ApprovedBy'];
    approvedOn = json['ApprovedOn'];
    tempDT = json['TempDT'];
    remark = json['Remark'];
    approvalRemark = json['ApprovalRemark'];
    if (json['imageByteArray'] != null)
      imageByteArray = base64.decode(json['imageByteArray']);
    isMultiValue = json['IsMultiValue'];
    subChakQty = json['SubChakQty'];
    deviceType = json['DeviceType'];
    downlink = json['Downlink'];
    macAddress = json['MacAddress'];
    subscribeTopicName = json['SubscribeTopicName'];
    parameterName = json['ParameterName'];
    isBullet = json['IsBullet'];
    isBulletHeader = json['IsBulletHeader'];
    comment = json['Comment'];
    coordinate = json['Coordinate'];
    dataType = json['DataType'];
    source = json['Source'];
    deviceId = json['DeviceId'];
    conString = json['conString'];
    userId = json['UserId'];
    issaved = json['issaved'];
    siteTeamEngineer = json['SiteTeamEngineer'];
    image = json['image'];
    issiteTeamEngineer = json['issiteTeamEngineer'];
    // if (inputType == 'image') {
    //   if (value!.length != 0)
    //     image = XFile.fromData(base64.decode(value!));
    //   else
    //     image = XFile(
    //         "imageupload.png"); //yeh code check kar lena i dont know ki static image kese feed karte XFile me
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CheckListId'] = this.checkListId;
    data['SubProcessId'] = this.subProcessId;
    data['ProcessId'] = this.processId;
    data['Description'] = this.description;
    data['SeqNo'] = this.seqNo;
    data['InputType'] = this.inputType;
    data['InputText'] = this.inputText;
    data['Value'] = this.value;
    data['SubProcessName'] = this.subProcessName;
    data['ProcessName'] = this.processName;
    data['ApprovedStatus'] = this.approvedStatus;
    data['WorkedBy'] = this.workedBy;
    data['WorkedOn'] = this.workedOn;
    data['ApprovedBy'] = this.approvedBy;
    data['ApprovedOn'] = this.approvedOn;
    data['TempDT'] = this.tempDT;
    data['Remark'] = this.remark;
    data['ApprovalRemark'] = this.approvalRemark;
    data['imageByteArray'] = this.imageByteArray;
    data['IsMultiValue'] = this.isMultiValue;
    data['SubChakQty'] = this.subChakQty;
    data['DeviceType'] = this.deviceType;
    data['Downlink'] = this.downlink;
    data['MacAddress'] = this.macAddress;
    data['SubscribeTopicName'] = this.subscribeTopicName;
    data['ParameterName'] = this.parameterName;
    data['IsBullet'] = this.isBullet;
    data['IsBulletHeader'] = this.isBulletHeader;
    data['Comment'] = this.comment;
    data['Coordinate'] = this.coordinate;
    data['DataType'] = this.dataType;
    data['Source'] = this.source;
    data['DeviceId'] = this.deviceId;
    data['conString'] = this.conString;
    data['UserId'] = this.userId;
    data['issaved'] = this.issaved;
    data['SiteTeamEngineer'] = this.siteTeamEngineer;
    data['image'] = this.image;
    data['issiteTeamEngineer'] = this.issiteTeamEngineer;
    return data;
  }
}
*/
