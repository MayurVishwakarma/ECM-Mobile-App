class DamageReport {
  int? total;
  int? electrical;
  int? mechanical;
  int? damageId;
  String? damage;
  String? type;
  int? cNT;
  int? totalOMS;
  int? totalAMS;
  int? totalRMS;
  int? totalElectOMS;
  int? totalMechOMS;
  int? eleCtriCal;
  int? meChaniCal;

  DamageReport({
    this.total,
    this.electrical,
    this.mechanical,
    this.damageId,
    this.damage,
    this.type,
    this.cNT,
    this.totalOMS,
    this.totalAMS,
    this.totalRMS,
    this.totalElectOMS,
    this.totalMechOMS,
    this.eleCtriCal,
    this.meChaniCal,
  });

  DamageReport.fromJson(Map<String, dynamic> json) {
    total = json['Total'];
    electrical = json['Electrical'];
    mechanical = json['Mechanical'];
    damageId = json['DamageId'];
    damage = json['Damage'];
    type = json['Type'];
    cNT = json['CNT'];
    totalOMS = json['TotalOMS'];
    totalAMS = json['TotalAMS'];
    totalRMS = json['TotalRMS'];
    totalElectOMS = json['TotalElectOMS'];
    totalMechOMS = json['TotalMechOMS'];
    eleCtriCal = json['EleCtriCal'];
    meChaniCal = json['MeChaniCal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Total'] = this.total;
    data['Electrical'] = this.electrical;
    data['Mechanical'] = this.mechanical;
    data['DamageId'] = this.damageId;
    data['Damage'] = this.damage;
    data['Type'] = this.type;
    data['CNT'] = this.cNT;
    data['TotalOMS'] = this.totalOMS;
    data['TotalAMS'] = this.totalAMS;
    data['TotalRMS'] = this.totalRMS;
    data['TotalElectOMS'] = this.totalElectOMS;
    data['TotalMechOMS'] = this.totalMechOMS;
    data['EleCtriCal'] = this.eleCtriCal;
    data['MeChaniCal'] = this.meChaniCal;
    return data;
  }
}
