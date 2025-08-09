class MaterialConsumptionModel {
  MaterialConsumptionModel({
    required this.id,
    required this.rectification,
    required this.deviceId,
    required this.reportedBy,
    required this.reportedOn,
    required this.type,
    required this.value,
    required this.remark,
    required this.imageByteArray,
  });

  final int? id;
  String? rectification;
  final int? deviceId;
  final int? reportedBy;
  final DateTime? reportedOn;
  final String? type;
  String? value;
  final String? remark;
  final dynamic imageByteArray;

  MaterialConsumptionModel copyWith({
    int? id,
    String? rectification,
    int? deviceId,
    int? reportedBy,
    DateTime? reportedOn,
    String? type,
    String? value,
    String? remark,
    dynamic imageByteArray,
  }) {
    return MaterialConsumptionModel(
      id: id ?? this.id,
      rectification: rectification ?? this.rectification,
      deviceId: deviceId ?? this.deviceId,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedOn: reportedOn ?? this.reportedOn,
      type: type ?? this.type,
      value: value ?? this.value,
      remark: remark ?? this.remark,
      imageByteArray: imageByteArray ?? this.imageByteArray,
    );
  }

  factory MaterialConsumptionModel.fromJson(Map<String, dynamic> json) {
    return MaterialConsumptionModel(
      id: json["Id"],
      rectification: json["Rectification"],
      deviceId: json["DeviceId"],
      reportedBy: json["ReportedBy"],
      reportedOn: DateTime.tryParse(json["ReportedOn"] ?? ""),
      type: json["Type"],
      value: json["Value"],
      remark: json["remark"],
      imageByteArray: json["imageByteArray"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Rectification": rectification,
        "DeviceId": deviceId,
        "ReportedBy": reportedBy,
        "ReportedOn": reportedOn?.toIso8601String(),
        "Type": type,
        "Value": value,
        "remark": remark,
        "imageByteArray": imageByteArray,
      };
}
