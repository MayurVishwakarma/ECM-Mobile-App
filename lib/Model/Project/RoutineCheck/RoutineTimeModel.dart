class RoutineTimeModel {
  RoutineTimeModel({
    required this.status,
    required this.data,
  });

  final String? status;
  final Data? data;

  RoutineTimeModel copyWith({
    String? status,
    Data? data,
  }) {
    return RoutineTimeModel(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  factory RoutineTimeModel.fromJson(Map<String, dynamic> json) {
    return RoutineTimeModel(
      status: json["Status"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "Status": status,
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    required this.response,
    required this.status,
    required this.message,
  });

  final List<Response> response;
  final String? status;
  final dynamic message;

  Data copyWith({
    List<Response>? response,
    String? status,
    dynamic message,
  }) {
    return Data(
      response: response ?? this.response,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      response: json["Response"] == null
          ? []
          : List<Response>.from(
              json["Response"]!.map((x) => Response.fromJson(x))),
      status: json["Status"],
      message: json["Message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Response": response.map((x) => x.toJson()).toList(),
        "Status": status,
        "Message": message,
      };
}

class Response {
  Response({
    required this.days,
  });

  final int? days;

  Response copyWith({
    int? days,
  }) {
    return Response(
      days: days ?? this.days,
    );
  }

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      days: json["Days"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Days": days,
      };
}
