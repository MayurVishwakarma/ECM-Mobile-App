// ignore_for_file: unused_element, avoid_unnecessary_containers, unused_field, prefer_const_constructors, unused_import, non_constant_identifier_names, prefer_final_fields, unused_catch_stack, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks, unused_local_variable, prefer_collection_literals, unused_label, empty_statements, curly_braces_in_flow_control_structures, unnecessary_new, empty_catches, prefer_is_empty, sort_child_properties_last, file_names, avoid_print, must_be_immutable, use_key_in_widget_constructors, prefer_typing_uninitialized_variables, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineScountModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineTimeModel.dart';
import 'package:ecm_application/Screens/Home/RoutineCheck/ManualCheck.dart';
import 'package:ecm_application/Services/RestRoutine.dart';
import 'package:flutter/material.dart';
import 'package:ecm_application/Model/Project/Login/AreaModel.dart';
import 'package:ecm_application/Model/Project/Login/DistibutoryModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/math_utils.dart';
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RoutineCheckScreen extends StatefulWidget {
  String? ProjectName;
  RoutineCheckScreen(String project) {
    ProjectName = project;
  }

  @override
  State<RoutineCheckScreen> createState() => _RoutineCheckScreenState();
}

class _RoutineCheckScreenState extends State<RoutineCheckScreen> {
  List<RoutineCheckMasterModel> _DisplayList = <RoutineCheckMasterModel>[];
  List<RoutineStatusList> processList = [];
  List<RoutineStatusList> nextScheduleList = [];
  // RoutineScountModel? scountList;
  var routineTime;
  var scount;
  var area = 'All';
  var distibutory = 'All';
  var process = '3';
  var nextschedule = 0;
  var isDateSort = 0;
  String? _search = '';
  AreaModel? selectedArea;
  DistibutroryModel? selectedDistributory;
  RoutineStatusList? selectStatus;
  RoutineStatusList? selectSchedule;
  Future<List<DistibutroryModel>>? futureDistributory;
  Future<List<AreaModel>>? futureArea;
  List<RoutineStatusList>? futureprocess;
  List<RoutineStatusList>? futureschedule;
  TextEditingController _routineTime = TextEditingController();
  String? dateSortImage = 'assets/images/unsort.png';
  List<DistibutroryModel>? DistriList;
  List<RoutineCheckMasterModel>? RoutineList;
  FToast? fToast;
  String? userType = '';
  int _page = 0;
  int _limit = 20;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _DisplayList = [];
    });
    _firstLoad();
    _controller = new ScrollController()..addListener(_loadMore);
    getDropDownAsync();
    getUserType();
    addProcessList();
    addNextScheduleList();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  getDropDownAsync() async {
    setState(() {
      futureArea = getAreaid();
      futureDistributory = getDistibutoryid();
    });
  }

  getDist(BuildContext context, List<DistibutroryModel> values) {
    try {
      return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 168, 211, 237),
            borderRadius: BorderRadius.circular(5)),
        child: DropdownButton(
          value: selectedDistributory == null ||
                  (values
                      .where((e) => e.id == selectedDistributory!.id)
                      .isEmpty)
              ? values.first
              : selectedDistributory,
          underline: Container(color: Colors.transparent),
          isExpanded: true,
          items: values.map((DistibutroryModel distibutroryModel) {
            return DropdownMenuItem<DistibutroryModel>(
              value: distibutroryModel,
              child: Center(
                child: Text(
                  distibutroryModel.description!,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
          onChanged: (textvalue) async {
            setState(() {
              selectedDistributory = textvalue as DistibutroryModel;
              distibutory = selectedDistributory!.id == 0
                  ? "All"
                  : selectedDistributory!.id.toString();
            });
            _firstLoad();
          },
        ),
      );
    } catch (_, ex) {
      return Container();
    }
  }

  getArea(BuildContext context, List<AreaModel> values) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 168, 211, 237),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButton(
        underline: Container(color: Colors.transparent),
        value: selectedArea == null ||
                (values.where((element) => element == selectedArea)) == 0
            ? values.first
            : selectedArea,
        isExpanded: true,
        items: values.map((AreaModel areaModel) {
          return DropdownMenuItem<AreaModel>(
            value: areaModel,
            child: Center(
              child: Text(
                areaModel.areaName!,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
        onChanged: (textvalue) async {
          var data = textvalue as AreaModel;
          var distriFuture = getDistibutoryid(
              areaId: data.areaid == 0 ? 'All' : data.areaid.toString());
          await distriFuture.then((value) => setState(() {
                selectedDistributory = value.first;
                distibutory = "All";
              }));
          setState(() {
            // _page = 0;
            // _hasNextPage = true;
            // _isFirstLoadRunning = false;
            // _isLoadMoreRunning = false;
            // _DisplayList = <PMSListViewModel>[];

            selectedArea = data;
            futureDistributory = distriFuture;

            area = selectedArea!.areaid == 0
                ? "All"
                : selectedArea!.areaid.toString();
          });
          _firstLoad();

          // await GetOmsOverviewModel();
          // setState(() {
          //   try {
          //     selectedState = textvalue as AreaModel;
          //   } catch (_, ex) {
          //     print(ex);
          //   }
          // });
        },
      ),
    );
  }

  getProcessList(BuildContext context, List<RoutineStatusList> values) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 168, 211, 237),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButton(
        underline: Container(color: Colors.transparent),
        value: selectStatus == null ||
                (values.where((element) => element == selectStatus)) == 0
            ? values.first
            : selectStatus,
        isExpanded: true,
        items: values.map((RoutineStatusList areaModel) {
          return DropdownMenuItem<RoutineStatusList>(
            value: areaModel,
            child: Center(
              child: Text(
                areaModel.name,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
        onChanged: (textvalue) async {
          //onAreaChange(textvalue);
          var data = textvalue as RoutineStatusList;

          setState(() {
            selectStatus = data;

            process =
                selectStatus!.id == 0 ? "All" : selectStatus!.id.toString();
          });
          _firstLoad();
        },
      ),
    );
  }

  getSchedulelist(BuildContext context, List<RoutineStatusList> values) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 168, 211, 237),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButton(
        underline: Container(color: Colors.transparent),
        value: selectSchedule == null ||
                (values.where((element) => element == selectSchedule)) == 0
            ? values.first
            : selectSchedule,
        isExpanded: true,
        items: values.map((RoutineStatusList areaModel) {
          return DropdownMenuItem<RoutineStatusList>(
            value: areaModel,
            child: Center(
              child: Text(
                areaModel.name.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
        onChanged: (textvalue) async {
          //onAreaChange(textvalue);
          var data = textvalue as RoutineStatusList;

          setState(() {
            selectSchedule = data;

            nextschedule = selectSchedule!.id == 0 ? 0 : selectSchedule!.id;
          });
          _firstLoad();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('OMS List'), actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () async {
                await getRoutineTime().then(
                  (value) {
                    setState(() {
                      _routineTime.text = value.toString();
                    });
                  },
                );
                await getRoutineCheckStatusCount(
                  search: _search,
                  areaId: area,
                  distibutoryId: distibutory,
                  routineStatus: int.tryParse(process),
                  nextSchedule: nextschedule,
                  source: 'OMS',
                ).then((value) => getCountPopup(value)).onError(
                      (error, stackTrace) => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Routine Check Count Status"),
                            content: Text("$error"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Back"),
                              ),
                            ],
                          );
                        },
                      ),
                    );
              },
              icon: Icon(Icons.info)),
        )
      ]),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _page = 0;
          });
          _DisplayList = [];
          _firstLoad();
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Search Bar
                  Stack(
                    children: [
                      Positioned(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                onChanged: (value) async {
                                  setState(() {
                                    _search = value;
                                  });
                                },
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.go,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    hintText: "Search"),
                              )),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  getpop(context);
                                  _firstLoad();
                                  new Future.delayed(new Duration(seconds: 1),
                                      () {
                                    Navigator.pop(context); //pop dialog
                                  });
                                  //_createRow();
                                },
                              ),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                  //Area Distibutory DropDown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder(
                          future: futureArea,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                  child: getArea(context, snapshot.data!));
                            } else if (snapshot.hasError) {
                              return Text(
                                // ignore: prefer_interpolation_to_compose_strings
                                "Something Went Wrong: " +
                                    snapshot.error.toString(),
                              );
                            } else {
                              return Center(child: Container());
                            }
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FutureBuilder(
                          future: futureDistributory,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                  child: getDist(context, snapshot.data!));
                            } else if (snapshot.hasError) {
                              return Container();
                            } else {
                              return Center(
                                child: Container(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  //Sataus and Schedule DropDown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: getProcessList(context, processList)),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: getSchedulelist(context, nextScheduleList))
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            // height: 25,
                            width: 90,
                            child: Text(
                              'CHAK NO.\n(DIST-AREA)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            height: 55,
                            child: FittedBox(
                              child: Text(
                                'Rountin Check \nDone',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            height: 25,
                            child: FittedBox(
                              child: Text(
                                'Last Rountin \nDone',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => dateSortTapped(),
                            child: SizedBox(
                              width: 60,
                              height: 25,
                              child: Row(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      'Next \nSechdeule',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  Expanded(
                                      child: Image(
                                    image: AssetImage(dateSortImage!),
                                    height: 50,
                                    width: 50,
                                  ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _controller,
                      interactive: true,
                      thickness: 10,
                      radius: Radius.circular(15),
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        controller: _controller,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: _isFirstLoadRunning
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Column(children: [
                                  getBody(),
                                  if (_isLoadMoreRunning == true)
                                    Container(
                                      child: Text('No Data Found'),
                                    ),
                                  if (_hasNextPage == false)
                                    Container(
                                      child: Text("No Result Found"),
                                    ),
                                  if (_DisplayList.isEmpty)
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      padding: EdgeInsets.all(8),
                                      width: double.infinity,
                                      decoration:
                                          BoxDecoration(color: Colors.white),
                                      child: Center(
                                          child: Text(
                                        'No Result Found',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  SizedBox(height: 150),
                                ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getCountPopup(RoutineScountModel count) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Material(
              color: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade200),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            widget.ProjectName.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                              onTap: (() {
                                                Navigator.pop(context);
                                              }),
                                              child: Icon(
                                                Icons.clear,
                                                color: Colors.white,
                                              )),
                                        )
                                      ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 20,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Colors.blue.shade200),
                                          child: Center(
                                            child: Text(
                                              'Information',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 100,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily: 'Lato',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        children: [
                                                          TextSpan(
                                                            text: 'TOTAL OMS: ',
                                                          ),
                                                          TextSpan(
                                                            text: count.sCount
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Lato',
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    RichText(
                                                      text: TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily: 'Lato',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        children: [
                                                          TextSpan(
                                                            text: 'PENDING : ',
                                                          ),
                                                          TextSpan(
                                                            text: count.pending
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Lato',
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    RichText(
                                                      text: TextSpan(
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily: 'Lato',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                'COMPLETELY DONE: ',
                                                          ),
                                                          TextSpan(
                                                            text: count
                                                                .fullyDone
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Lato',
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                  child: Row(
                                                children: [
                                                  Text(
                                                      'Routine CheckUp Period:'),
                                                  Expanded(
                                                      child: TextField(
                                                    enabled: isEdit(),
                                                    controller: _routineTime,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 45, 51, 74)),
                                                  )),
                                                  Text(' Days'),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  if (isEdit())
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        updateRoutineTime(
                                                                int.parse(
                                                                    _routineTime
                                                                        .text))
                                                            .then((value) => {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(value
                                                                            ? 'Success'
                                                                            : 'Error'),
                                                                        content: Text(value
                                                                            ? 'Routine CheckUp Period Updarted Successfully'
                                                                            : 'Something Went Wrong !!!'),
                                                                        actions: <Widget>[
                                                                          TextButton(
                                                                            child:
                                                                                Text('OK'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  )
                                                                });
                                                      },
                                                      child: Text('Update'),
                                                    )
                                                ],
                                              )),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          );
        });
  }

  _showToast(String? msg, {int? MessageType = 0}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: MessageType! == 0
            ? Color.fromARGB(255, 57, 255, 159)
            : Color.fromARGB(255, 243, 72, 72),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MessageType == 0 ? Icons.check : Icons.close,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            msg!,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  getUserType() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      userType = pref.getString('usertype');
    } catch (_, ex) {
      userType = '';
    }
  }

  bool isEdit() {
    var flag = userType!.toLowerCase().contains('manager') ||
        userType!.toLowerCase().contains('admin');
    if (flag) {
      return true;
    } else {
      return false;
    }
  }

  void dateSortTapped() {
    if (isDateSort == 2) {
      isDateSort = 0;
    } else {
      isDateSort++;
    }

    switch (isDateSort) {
      case 0:
        dateSortImage = 'assets/images/unsort.png';
        break;
      case 1:
        dateSortImage = 'assets/images/ascsort.png';
        break;
      case 2:
        dateSortImage = 'assets/images/dessort.png';
        break;
    }
    getpop(context);
    _firstLoad();
    new Future.delayed(new Duration(seconds: 1), () {
      Navigator.pop(context); //pop dialog
    });
  }

  /*getOmsList(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: _controller,
        interactive: true,
        thickness: 12,
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: _controller,
          child: Container(
            margin: EdgeInsets.only(left: 8.00, right: 8.00, bottom: (13.00)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: _isFirstLoadRunning
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(children: [
                    getBody(),
                    // when the _loadMore function is running
                    if (_isLoadMoreRunning == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // When nothing else to load
                    if (_hasNextPage == false)
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                      ),
                  ]),
          ),
        ),
      ),
    );
  }
*/
  Widget getBody() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _DisplayList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => RoutineManual_CheckList(
                      _DisplayList[index].omsId!,
                      _DisplayList[index].chakNo!,
                      _DisplayList[index].areaName ?? '',
                      _DisplayList[index].description ?? '',
                      widget.ProjectName!,
                      true,
                      'oms',
                      _DisplayList[index].amsCoordinate ?? '')),
              (Route<dynamic> route) => true,
            );
          },
          child: Container(
            // height: 60,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    // height: 50,
                    width: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(_DisplayList[index].chakNo!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Text(
                            '( ${_DisplayList[index].description ?? ' '}-${_DisplayList[index].areaName ?? ' '} )',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.cyan)),
                      ],
                    )),
                SizedBox(
                    width: 55,
                    height: 25,
                    child: FittedBox(
                        child: Text(
                      getlongDate(_DisplayList[index].workedOn ?? '')!,
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ))),
                SizedBox(
                    width: 55,
                    height: 25,
                    child: FittedBox(
                        child: Text(
                            getLastRoutineStatus(
                                _DisplayList[index].routineStatus ?? 0,
                                _DisplayList[index].nextScheduleDate ??
                                    DateTime.now().toString()),
                            style: getLastRoutineStatusStyle(
                                _DisplayList[index].routineStatus ?? 0,
                                _DisplayList[index].nextScheduleDate ??
                                    DateTime.now().toString())))),
                SizedBox(
                    width: 60,
                    height: 25,
                    child: FittedBox(
                        child: Text(
                      getNextScheduleDate(
                          _DisplayList[index].nextScheduleDate.toString())!,
                      style: TextStyle(fontSize: 10),
                    )))
              ],
            ),
          ),
        );
      },
    );
  }

  String? getlongDate(String date) {
    try {
      final DateTime now = DateTime.parse(date);
      final DateTime nullDate = DateTime(1, 1, 1);
      if (now == nullDate) {
        return 'Not Available';
      }
      final DateFormat formatter = DateFormat('dd-MMM-yyyy');
      final String formatted =
          formatter.format(now.add(Duration(hours: 5, minutes: 30)));
      return formatted;
    } catch (e) {
      return '';
    }
  }

  String? getNextScheduleDate(String date) {
    try {
      final DateTime now = DateTime.parse(date);
      final DateTime nullDate = DateTime(1, 1, 1);
      if (now == nullDate) {
        return '';
      }
      final DateFormat formatter = DateFormat('dd-MMM-yyyy');
      final String formatted =
          formatter.format(now.add(Duration(hours: 5, minutes: 30)));
      return formatted;
    } catch (e) {
      return '';
    }
  }

  getLastRoutineStatus(int status, String schedule) {
    DateTime dt = DateTime.now();
    DateTime scheduleDateTime = DateTime.parse(schedule);

    var result;
    try {
      if (scheduleDateTime.isBefore(dt) && status == 2)
        return "Already Due";
      else if (scheduleDateTime.isAfter(dt) && status == 2)
        return "Done";
      else if (status == 1)
        return "Partially Done";
      else
        return "Pending";
    } catch (_, ex) {
      result = 'Pending';
    }
    return result;
  }

  getLastRoutineStatusStyle(int status, String schedule) {
    DateTime dt = DateTime.now();
    DateTime scheduleDateTime = DateTime.parse(schedule);

    var result;
    try {
      if (scheduleDateTime.isBefore(dt) && status == 2)
        return TextStyle(
            fontSize: 8, backgroundColor: Colors.red, color: Colors.white);
      else if (scheduleDateTime.isAfter(dt) && status == 2)
        return TextStyle(
            fontSize: 4, backgroundColor: Colors.green, color: Colors.white);
      else if (status == 1)
        return TextStyle(
            fontSize: 8,
            backgroundColor: Colors.orange.shade600,
            color: Colors.white);
      else
        return TextStyle(
          fontSize: 8,
        );
    } catch (_, ex) {
      result = TextStyle(
        fontSize: 8,
      );
    }
    return result;
  }

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    setState(() {
      _page = 0;
      _isFirstLoadRunning = true;
      _hasNextPage = true;
      _isLoadMoreRunning = false;
    });

    try {
      final fetchedData = await getRoutineNodeList(
        search: _search!,
        areaId: area,
        distibutoryId: distibutory,
        routineStatus: int.tryParse(process),
        dateSort: isDateSort,
        nextSchedule: nextschedule,
        index: _page,
        limit: _limit,
        source: 'OMS',
      );

      setState(() {
        _DisplayList = fetchedData;
      });
    } catch (_) {
      print('First load failed');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
        _page += 1;
      });

      try {
        final fetchedData = await getRoutineNodeList(
          search: _search!,
          areaId: area,
          distibutoryId: distibutory,
          routineStatus: int.tryParse(process),
          dateSort: isDateSort,
          nextSchedule: nextschedule,
          index: _page,
          limit: _limit,
          source: 'OMS',
        );

        if (fetchedData.isNotEmpty) {
          setState(() {
            _DisplayList.addAll(fetchedData);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (_) {
        print('Load more failed!');
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void addProcessList() {
    processList = [
      RoutineStatusList(3, "ALL STATUS"),
      RoutineStatusList(0, "PENDING"),
      RoutineStatusList(2, "COMPLETELY DONE"),
    ];
  }

  void addNextScheduleList() {
    nextScheduleList = [
      RoutineStatusList(0, "ALL SCHEDULE"),
      RoutineStatusList(1, "ALREADY DUE"),
      RoutineStatusList(7, "WITHIN NEXT WEEK"),
      RoutineStatusList(15, "IN NEXT 15 DAYS"),
      RoutineStatusList(25, "IN NEXT 25 DAYS"),
    ];
  }

  /*Future<RoutineScountModel> getECMReportStatusCoun() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? conString = preferences.getString('ConString');

      final response = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/Routine/RoutineStatusCount?Search=$_search&areaId=$area&DistributoryId=$distibutory&RoutineStatus=$process&StartDate=01-01-1900&EndDate=01-01-1900&NextSchedule=$nextschedule&Source=oms&conString=$conString'));
      print(
          'http://wmsservices.seprojects.in/api/Routine/RoutineStatusCount?Search=$_search&areaId=$area&DistributoryId=$distibutory&RoutineStatus=$process&StartDate=01-01-1900&EndDate=01-01-1900&NextSchedule=$nextschedule&Source=oms&conString=$conString');
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        RoutineScountModel result =
            RoutineScountModel.fromJson(json['data']['Response']);

        return result;
      } else {
        throw Exception('Failed to load API');
      }
    } catch (e) {
      throw Exception('Failed to load API');
    }
  }*/
  /*Future<void> fetchRoutineTime() async {
    final prefs = await SharedPreferences.getInstance();
    final projectId = prefs.getString('ProjectId');
    final url =
        'http://ecmv2.iotwater.in:3011/api/v1/routine/routineTime?projectId=$projectId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final routineTimeModel = RoutineTimeModel.fromJson(jsonResponse);

      if (routineTimeModel.data != null &&
          routineTimeModel.data!.response != null) {
        final days = routineTimeModel.data!.response!.days;
        setState(() {
          _routineTime.text = days.toString();
        });
      }
    }
  }
*/
  /*Future<String> updateRoutineTime(int days) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');
    try {
      var actionUrl =
          'http://wmsservices.seprojects.in/api/Routine/UpdateRoutineTime?Days=$days&conString=$conString';
      var response =
          await http.post(Uri.parse(actionUrl), body: jsonEncode({}));

      if (response.statusCode != 200) {
        setState(() {
          isSubmited = false;
        });
        return 'Not Ok';
      } else {
        setState(() {
          isSubmited = true;
        });
        return 'OK';
      }
    } catch (error) {
      return error.toString();
    }
  }*/

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
}

class RoutineStatusList {
  final int id;
  final String name;

  RoutineStatusList(this.id, this.name);
}
