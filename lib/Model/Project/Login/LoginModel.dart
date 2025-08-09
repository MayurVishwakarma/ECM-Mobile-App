// class LoginMasterModel {
//   int? userid;
//   String? mobMessage;
//   String? token;
//   String? userType;
//   String? fName;
//   String? lName;
//   String? pwd;

//   LoginMasterModel(
//       {this.userid,
//       this.mobMessage,
//       this.token,
//       this.userType,
//       this.fName,
//       this.lName,
//       this.pwd});

//   LoginMasterModel.fromJson(Map<String, dynamic> json) {
//     userid = json['userid'];
//     mobMessage = json['MobMessage'];
//     token = json['Token'];
//     userType = json['userType'];
//     fName = json['FName'];
//     lName = json['LName'];
//     pwd = json['pwd'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['userid'] = this.userid;
//     data['MobMessage'] = this.mobMessage;
//     data['Token'] = this.token;
//     data['userType'] = this.userType;
//     data['FName'] = this.fName;
//     data['LName'] = this.lName;
//     data['pwd'] = this.pwd;
//     return data;
//   }
// }

class LoginMasterModel {
  LoginMasterModel({
    required this.userid,
    required this.mobMessage,
    required this.token,
    required this.userType,
    required this.fName,
    required this.lName,
    required this.pwd,
    required this.notify,
    required this.isDryTestUser,
    required this.designation,
  });

  final int? userid;
  final String? mobMessage;
  final String? token;
  final String? userType;
  final String? fName;
  final String? lName;
  final String? pwd;
  final String? notify;
  final dynamic isDryTestUser;
  final String? designation;

  LoginMasterModel copyWith({
    int? userid,
    String? mobMessage,
    String? token,
    String? userType,
    String? fName,
    String? lName,
    String? pwd,
    String? notify,
    dynamic isDryTestUser,
    String? designation,
  }) {
    return LoginMasterModel(
      userid: userid ?? this.userid,
      mobMessage: mobMessage ?? this.mobMessage,
      token: token ?? this.token,
      userType: userType ?? this.userType,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      pwd: pwd ?? this.pwd,
      notify: notify ?? this.notify,
      isDryTestUser: isDryTestUser ?? this.isDryTestUser,
      designation: designation ?? this.designation,
    );
  }

  factory LoginMasterModel.fromJson(Map<String, dynamic> json) {
    return LoginMasterModel(
      userid: json["userid"],
      mobMessage: json["MobMessage"],
      token: json["Token"],
      userType: json["userType"],
      fName: json["FName"],
      lName: json["LName"],
      pwd: json["pwd"],
      notify: json["notify"],
      isDryTestUser: json["isDryTestUser"],
      designation: json["designation"],
    );
  }

  Map<String, dynamic> toJson() => {
        "userid": userid,
        "MobMessage": mobMessage,
        "Token": token,
        "userType": userType,
        "FName": fName,
        "LName": lName,
        "pwd": pwd,
        "notify": notify,
        "isDryTestUser": isDryTestUser,
        "designation": designation,
      };
}
