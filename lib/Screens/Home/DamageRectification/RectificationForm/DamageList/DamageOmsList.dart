// ignore_for_file: prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_const_constructors, avoid_print, prefer_is_empty, avoid_unnecessary_containers, unused_local_variable, must_be_immutable, camel_case_types, use_key_in_widget_constructors, use_build_context_synchronously, unnecessary_null_comparison, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks

import 'dart:async';
import 'package:ecm_application/Model/Project/Damage/OmsDamageModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Model/Project/Login/AreaModel.dart';
import 'package:ecm_application/Model/Project/Login/DistibutoryModel.dart';
import 'package:ecm_application/Screens/Home/DamageRectification/RectificationForm/DamageForms/DamageInsertForm.dart';
import 'package:ecm_application/Services/RestDamage.dart';
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Oms_DamagePage extends StatefulWidget {
  @override
  State<Oms_DamagePage> createState() => _Oms_DamagePageState();
}

class _Oms_DamagePageState extends State<Oms_DamagePage> {
  List<DamageModel>? _DisplayList = <DamageModel>[];
  int _page = 0;
  final int _limit = 35;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  var area = 'All';
  var distibutory = 'ALL';
  String? _search = '';
  AreaModel? selectedArea;
  DistibutroryModel? selectedDistributory;
  Future<List<DistibutroryModel>>? futureDistributory;
  Future<List<AreaModel>>? futureArea;
  List<PMSChaklistModel>? ProcessList;
  List<DistibutroryModel>? DistriList;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _DisplayList = [];
    });
    _firstLoad();
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
              _DisplayList = <DamageModel>[];

              selectedDistributory = textvalue as DistibutroryModel;
              distibutory = selectedDistributory!.id == 0
                  ? "All"
                  : selectedDistributory!.id.toString();
            });
            _firstLoad();
            // await GetOmsOverviewModel();
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
            _DisplayList = <DamageModel>[];

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
                                            _DisplayList = <DamageModel>[];
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                      "Unable to Load Distributory",
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
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Expanded(
                                        child:
                                            getDist(context, snapshot.data!));
                                  } else if (snapshot.hasError) {
                                    return Container(
                                      child: Text('unable to load Area'),
                                    );
                                  } else {
                                    return Center(child: Container());
                                  }
                                },
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
                                      'Elctrical',
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
                                        if (_isLoadMoreRunning == true)
                                          Container(
                                            child: Text('No Data Found'),
                                          ),
                                        if (_hasNextPage == false)
                                          Container(
                                            child: Text("No Result Found"),
                                          ),
                                        if (_DisplayList!.isEmpty)
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            padding: EdgeInsets.all(8),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.white),
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

                        /*getOmsList(context)
                      */
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

  /*getOmsList(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: _controller,
        interactive: true,
        thickness: 12,
        radius: Radius.circular(30),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: _controller,
          child: Container(
            margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 13.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), // Increase the circular radius
                bottomRight:
                    Radius.circular(30), // Increase the circular radius
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 2.0,
                  blurRadius: 2.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            child: _isFirstLoadRunning
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      getBody(),
                      // when the _loadMore function is running
                      _isLoadMoreRunning
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : SizedBox(),

                      // When nothing else to load
                      !_hasNextPage ? SizedBox(height: 10) : SizedBox(),
                    ],
                  ),
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
      itemCount: _DisplayList!.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
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
                      builder: (context) => DamageInsert(
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
                              color: (_DisplayList![index].electrical ?? 0) != 0
                                  ? Colors.red
                                  : Colors.green, //colorchngerEle(index),
                              borderRadius: BorderRadius.circular(80)),
                          child: Center(
                            child: Text(
                              (_DisplayList![index].electrical ?? 0).toString(),
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

  void _firstLoad() async {
    setState(() {
      _page = 0;
      _isFirstLoadRunning = true;
      _hasNextPage = true;
      _isLoadMoreRunning = false;
    });

    try {
      final fetchedData = await getDamageStatusList(
        search: _search!,
        areaId: area,
        distibutoryId: distibutory,
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
        final fetchedData = await getDamageStatusList(
          search: _search!,
          areaId: area,
          distibutoryId: distibutory,
          index: _page,
          limit: _limit,
          source: 'OMS',
        );

        if (fetchedData!.isNotEmpty) {
          setState(() {
            _DisplayList!.addAll(fetchedData);
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
}
