class CountModel {
  dynamic scount;

  CountModel({this.scount});

  CountModel.fromJson(Map<String, dynamic> json) {
    scount = json['Scount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Scount'] = scount;
    return data;
  }
}
