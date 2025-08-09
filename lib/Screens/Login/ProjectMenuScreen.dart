// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables, unnecessary_new, file_names, use_key_in_widget_constructors, prefer_collection_literals, unnecessary_null_comparison, unused_field, must_be_immutable, avoid_print, avoid_unnecessary_containers

import 'dart:convert';
import 'package:ecm_application/Model/Common/EngineerModel.dart';
import 'package:ecm_application/Model/project/Constants.dart';
import 'package:ecm_application/Screens/Home/DamageRectification/DamageMenuScreen.dart';
import 'package:ecm_application/Screens/Home/ECM_Tool-Screen/ECMToolScreen.dart';
import 'package:ecm_application/Screens/Home/Production/ProductionScreen.dart';
import 'package:ecm_application/Screens/Home/RoutineCheck/RoutineCheckStatusCommon.dart';
import 'package:ecm_application/Screens/Home/SurveyForm/SurveyNodeList.dart';
import 'package:http/http.dart' as http;
import 'package:ecm_application/Model/Project/Login/State_list_Model.dart';
import 'package:ecm_application/Screens/Home/ECM_Tool-Screen/ECMToolScreen_30Ha.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/Maintenance/Maintenance_Guidance_Tool.dart';

class ProjectMenuScreen extends StatefulWidget {
  String? projectName;
  ProjectMenuScreen(String project) {
    projectName = project;
  }
  @override
  State<ProjectMenuScreen> createState() => _ProjectMenuScreenState();
}

class _ProjectMenuScreenState extends State<ProjectMenuScreen> {
  @override
  void initState() {
    super.initState();
    getDataString();
    getUserId();
  }

  ProjectModel? selectProject;
  String? search = 'All';
  String? ecString = '1111';
  String? dcString = '1111';
  String? userType = 'Engineer';

  getDataString() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      ecString = preferences.getString('EcString');
      dcString = preferences.getString('DcString');
      userType = preferences.getString('usertype');
      // rcString = preferences.getString('RcString');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.projectName!.toUpperCase(),
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20),
                  children: <Widget>[
                    //Maintainence Page
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Maintenance_Guidance_Tool()),
                            (Route<dynamic> route) => true,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(3.0, 3.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/maintenance.png'),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Maintenance Guidance Tool',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Damage Rectification Page
                    if (dcString![0] == '1')
                      InkWell(
                        onTap: () async {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DamageMenuScreen()),
                            (Route<dynamic> route) => true,
                          );
                          // showDialog(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return AlertDialog(
                          //       title: Text("Page Under Construction"),
                          //       content: Text(
                          //           "Sorry, this page is still under construction."),
                          //       actions: [
                          //         TextButton(
                          //           child: Text("OK"),
                          //           onPressed: () =>
                          //               Navigator.of(context).pop(),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(3.0, 3.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/rectification.png'),
                                  ),
                                ),
                                Text(
                                  'Damage/Rectification',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    //ECM page
                    if (ecString![0] == '1')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();

                            String? projectName =
                                preferences.getString('ProjectName');

                            projectName!.toUpperCase() == 'BERKHEDA'
                                ? Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EcmToolScreen30Ha()),
                                    (Route<dynamic> route) => true,
                                  )
                                : Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EcmToolScreen()),
                                    (Route<dynamic> route) => true,
                                  );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(3.0, 3.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/settings.png')),
                                ),
                                Text(
                                  'ECM Tool',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    //Routine Check
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RoutineCheckScreenCommon()),
                            (Route<dynamic> route) => true,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(3.0, 3.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image(
                                  image:
                                      AssetImage('assets/images/routine.png'),
                                ),
                              ),
                              Text(
                                'Routine Check',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //Site Survey Form
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SurveyNodeListScreen()),
                            (Route<dynamic> route) => true,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(3.0, 3.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/survey_form.png'),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Site Survey Form',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    //Manufacturer Page
                    if (userType?.toLowerCase() == 'manufacturer')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AssemblyUpload(
                                        projectName: widget.projectName ?? '',
                                      )),
                              (Route<dynamic> route) => true,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(3.0, 3.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/production.png'),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Production Assembly Upload',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  getpop(context) {
    return showDialog(
      barrierDismissible: false,
      useSafeArea: false,
      context: context,
      builder: (ctx) => Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  getUserId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? mobileNo = preferences.getString('mobileno');
      final projectId = preferences.getString('ProjectId');

      final res = await http.get(Uri.parse(
          'http://ecmtest.iotwater.in:3011/api/v1/project/users/$mobileNo/0/$projectId'));

      print(
          'http://ecmtest.iotwater.in:3011/api/v1/project/users/$mobileNo/0/$projectId');

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response'][0]);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setInt('ProUserId', loginResult.userid!);
          preferences.setBool(
              'isAllowed', loginResult.userid! != null ? true : false);
          return loginResult.firstname.toString();
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (err) {
      return '';
    }
  }
}
