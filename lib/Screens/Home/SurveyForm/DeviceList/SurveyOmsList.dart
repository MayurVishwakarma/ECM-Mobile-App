// ignore_for_file: prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_const_constructors, avoid_print, prefer_is_empty, avoid_unnecessary_containers, unused_local_variable, must_be_immutable, camel_case_types, use_key_in_widget_constructors, use_build_context_synchronously, unnecessary_null_comparison, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, deprecated_member_use, file_names
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ecm_application/Model/Project/Damage/OmsSurveyModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Model/Project/Login/AreaModel.dart';
import 'package:ecm_application/Model/Project/Login/DistibutoryModel.dart';
import 'package:ecm_application/Screens/Home/SurveyForm/SiteSurveyForm/SiteSurveyForm.dart';
import 'package:http/http.dart' as http;
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyOmsList extends StatefulWidget {
  @override
  State<SurveyOmsList> createState() => _SurveyOmsListState();
}

class _SurveyOmsListState extends State<SurveyOmsList> {
  List<SurveyModel>? _DisplayList = <SurveyModel>[];

  @override
  void initState() {
    super.initState();
    setState(() {
      _DisplayList = [];
    });
    _firstLoad();
    getScount();
    getDropDownAsync();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firstLoad();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  var area = 'All';
  var distibutory = 'ALL';

  String? _search = '';

  AreaModel? selectedArea;
  DistibutroryModel? selectedDistributory;

  Future<List<DistibutroryModel>>? futureDistributory;
  Future<List<AreaModel>>? futureArea;
  List<PMSChaklistModel>? ProcessList;
  List<DistibutroryModel>? DistriList;

  getDropDownAsync() async {
    setState(() {
      futureArea = getAreaid();
      futureDistributory = getDistibutoryid();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? project = preferences.getString('project');
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
                child: FittedBox(
                  child: Text(
                    distibutroryModel.description!,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (textvalue) async {
            setState(() {
              _page = 0;
              _hasNextPage = true;
              _isFirstLoadRunning = false;
              _isLoadMoreRunning = false;
              _DisplayList = <SurveyModel>[];

              selectedDistributory = textvalue as DistibutroryModel;
              distibutory = selectedDistributory!.id == 0
                  ? "All"
                  : selectedDistributory!.id.toString();
            });
            _firstLoad();
          },
        ),
      );
    } catch (_) {
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
              child: FittedBox(
                child: Text(
                  areaModel.areaName ?? "",
                  style: TextStyle(fontSize: 13),
                ),
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
            _page = 0;
            _hasNextPage = true;
            _isFirstLoadRunning = false;
            _isLoadMoreRunning = false;
            _DisplayList = <SurveyModel>[];

            selectedArea = data;
            futureDistributory = distriFuture;

            area = selectedArea!.areaid == 0
                ? "All"
                : selectedArea!.areaid.toString();
          });
          _firstLoad();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _page = 0;
          scount = 0;
        });
        _DisplayList = [];
        _firstLoad();
        getScount();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.grey.shade200),
            child: _DisplayList! != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        Stack(
                          children: [
                            Positioned(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
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
                                                  EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              hintText: "Search"),
                                        ),
                                      ),
                                      IconButton(
                                        splashColor: Colors.blue,
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          getpop(context);

                                          setState(() {
                                            _page = 0;
                                            _hasNextPage = true;
                                            _isFirstLoadRunning = false;
                                            _isLoadMoreRunning = false;
                                            _DisplayList = <SurveyModel>[];
                                          });
                                          _firstLoad();

                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            Navigator.pop(context); //pop dialog
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //dropdown
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// This Future Builder is Used for Area DropDown list
                              FutureBuilder(
                                future: futureArea,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Expanded(
                                        child:
                                            getArea(context, snapshot.data!));
                                  } else if (snapshot.hasError) {
                                    return Text(
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

                              ///This Future Builder is Used for Distibutory DropDown List
                              FutureBuilder(
                                future: futureDistributory,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Expanded(
                                        child:
                                            getDist(context, snapshot.data!));
                                  } else if (snapshot.hasError) {
                                    return Container();
                                  } else {
                                    return Center(child: Container());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total Nodes Surveyed : $scount',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'CHAK NO.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900),
                                          ),
                                          Text(
                                            '(Distri-Area)',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      'Automation',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Center(
                                    child: Text(
                                      'Mechanical',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900),
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

                                        // when the _loadMore function is running
                                        if (_isLoadMoreRunning == true)
                                          Container(
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        // When nothing else to load
                                        if (_hasNextPage == false)
                                          Container(
                                            child: Center(
                                              child: Text('No Nodes to load '),
                                            ),
                                          ),
                                        SizedBox(height: 150),
                                      ]),
                              ),
                            ),
                          ),
                        ),
                      ])
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/soon.gif',
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Page under construction',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
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

  Widget getBody() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _DisplayList!.length,
      itemBuilder: (context, index) {
        return Container(
          // height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: InkWell(
              onTap: () async {
                var source = 'oms';
                var projectName;
                var conString;
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                conString = preferences.getString('ConString');
                projectName = preferences.getString('ProjectName')!;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SurveyInsertPage(
                            _DisplayList![index],
                            projectName,
                            source,
                          )),
                  (Route<dynamic> route) => true,
                ).whenComplete(() {
                  _firstLoad();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //chak No.
                  SizedBox(
                      height: 50,
                      width: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(_DisplayList![index].chakNo!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                    '( ' +
                                        _DisplayList![index]
                                            .areaName
                                            .toString() +
                                        "-" +
                                        _DisplayList![index]
                                            .description
                                            .toString() +
                                        ' )',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue,
                                        fontFamily: "Lato")),
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                      height: 50,
                      width: 90,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: (_DisplayList![index].automation ?? 0) != 0
                                  ? Colors.red
                                  : Colors.green, //colorchngerEle(index),
                              borderRadius: BorderRadius.circular(80)),
                          child: Center(
                            child: Text(
                              (_DisplayList![index].automation ?? 0).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                      height: 50,
                      width: 90,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: (_DisplayList![index].mechanical ?? 0) != 0
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              (_DisplayList![index].mechanical ?? 0).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              )),
        );
      },
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

  int _page = 0;
  final int _limit = 20;
  
  bool _hasNextPage = true;

  
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  late ScrollController _controller;

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    setState(() {
      _page = 0;
      _isFirstLoadRunning = true;
      _hasNextPage = true;
      _isFirstLoadRunning = false;
      _isLoadMoreRunning = false;
    });
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? conString = preferences.getString('ConString');
      String? projectName = preferences.getString('ProjectName');

      var url = '';
      if (projectName!.contains('Kundalia LBC')) {
        url =
            'http://ecm.seprojects.in:3008/api/v1/survey/status/KLBC/$area/$distibutory/$_page/$_limit?search=$_search';
      } else if (projectName.contains('Kundalia RBC')) {
        url =
            'http://ecm.seprojects.in:3008/api/v1/survey/status/KRBC/$area/$distibutory/$_page/$_limit?search=$_search';
      } else if (projectName.contains('Alirajpur Demo')) {
        url =
            'http://ecm.seprojects.in:3008/api/v1/survey/status/ALP/$area/$distibutory/$_page/$_limit?search=$_search';
      } else {
        url =
            'http://wmsservices.seprojects.in/api/OMS/OmsSurveyReportStatus?Search=$_search&areaId=$area&DistributoryId=$distibutory&pageIndex=$_page&pageSize=$_limit&conString=$conString';
      }
      print(url);
      final res = await http.get(Uri.parse(url));

      var json = jsonDecode(res.body);
      List<SurveyModel> fetchedData = <SurveyModel>[]; //['data']['Response']
      json['data']['Response']
          .forEach((e) => fetchedData.add(SurveyModel.fromJson(e)));
      _DisplayList = [];
      if (fetchedData.length > 0) {
        setState(() {
          _DisplayList!.addAll(fetchedData);
        });
      }
    } catch (err) {
      print('Something went wrong');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
        _page += 1; // Display a progress indicator at the bottom
      });
      // Increase _page by 1
      try {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String? conString = preferences.getString('ConString');
        String? projectName = preferences.getString('ProjectName');

        var url = '';
        if (projectName!.contains('Kundalia LBC')) {
          url =
              'http://ecm.seprojects.in:3008/api/v1/survey/status/KLBC/$area/$distibutory/$_page/$_limit?search=$_search';
        } else if (projectName.contains('Kundalia RBC')) {
          url =
              'http://ecm.seprojects.in:3008/api/v1/survey/status/KRBC/$area/$distibutory/$_page/$_limit?search=$_search';
        } else if (projectName.contains('Alirajpur Demo')) {
          url =
              'http://ecm.seprojects.in:3008/api/v1/survey/status/ALP/$area/$distibutory/$_page/$_limit?search=$_search';
        } else {
          'http://wmsservices.seprojects.in/api/OMS/OmsSurveyReportStatus?Search=$_search&areaId=$area&DistributoryId=$distibutory&pageIndex=$_page&pageSize=$_limit&conString=$conString';
        }
        final res = await http.get(Uri.parse(url));

        print(url);

        var json = jsonDecode(res.body);
        List<SurveyModel> fetchedData = <SurveyModel>[];
        json['data']['Response']
            .forEach((e) => fetchedData.add(SurveyModel.fromJson(e)));
        if (fetchedData.length > 0) {
          setState(() {
            _DisplayList!.addAll(fetchedData);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        print('Something went wrong!');
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  int? scount = 0;
  Future<void> getScount() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');

      var dio = Dio();
      var response = await dio.request(
        'http://wmsservices.seprojects.in/api/OMS/OmsSurveyReportStatusCount?conString=$conString',
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        //print(json.encode(response.data['data']['Response']['SCount']));
        scount = response.data['data']['Response']['SCount'];
      } else {
        print(response.statusMessage);
      }
      /* if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List<CountModel> Result = <CountModel>[];
        json['data']['Response']
            .forEach((v) => Result.add(CountModel.fromJson(v)));
        setState(() {
          scount = Result.first.scount;
        });
      } else {
        throw Exception('Failed to load API');
      }
*/
    } catch (e) {
      throw Exception('Failed to load API');
    }
  }
}
