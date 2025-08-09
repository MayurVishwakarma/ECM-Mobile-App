class SurveyModel {
  int? omsId;
  String? chakNo;
  int? amsId;
  String? amsNo;
  int? gateWayId;
  String? gatewayNo;
  String? gatewayName;
  int? rmsId;
  String? rmsNo;
  String? areaName;
  String? description;
  int? automation;
  int? mechanical;
  int? tubing;
  SurveyModel(
      {this.omsId,
      this.chakNo,
      this.amsId,
      this.amsNo,
      this.gateWayId,
      this.gatewayNo,
      this.gatewayName,
      this.rmsId,
      this.rmsNo,
      this.areaName,
      this.description,
      this.automation,
      this.mechanical,
      this.tubing});

  SurveyModel.fromJson(Map<String, dynamic> json) {
    omsId = json['OmsId'];
    chakNo = json['ChakNo'];
    amsId = json['AmsId'];
    amsNo = json['AmsNo'];
    gateWayId = json['GateWayId'];
    gatewayNo = json['GatewayNo'];
    gatewayName = json['GatewayName'];
    rmsId = json['RmsId'];
    rmsNo = json['RmsNo'];
    areaName = json['AreaName'];
    description = json['Description'];
    automation = json['Automation'];
    mechanical = json['Mechanical'];
    tubing = json['Tubing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OmsId'] = this.omsId;
    data['ChakNo'] = this.chakNo;
    data['AmsId'] = this.amsId;
    data['AmsNo'] = this.amsNo;
    data['GatewayId'] = this.gateWayId;
    data['GateWayNo'] = this.gatewayNo;
    data['GatewayName'] = this.gatewayName;
    data['RmsId'] = this.rmsId;
    data['RmsNo'] = this.rmsNo;
    data['AreaName'] = this.areaName;
    data['Description'] = this.description;
    data['Automation'] = this.automation;
    data['Mechanical'] = this.mechanical;
    data['Tubing'] = this.tubing;

    return data;
  }
}
