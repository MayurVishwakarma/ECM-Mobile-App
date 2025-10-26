// ignore_for_file: prefer_const_constructors, file_names, prefer_const_literals_to_create_immutables, sort_child_properties_last, import_of_legacy_library_into_null_safe, use_key_in_widget_constructors, library_private_types_in_public_api, unused_import, unused_element, prefer_interpolation_to_compose_strings, avoid_print, prefer_is_empty, use_build_context_synchronously, prefer_typing_uninitialized_variables, curly_braces_in_flow_control_structures, avoid_unnecessary_containers, must_be_immutable, non_constant_identifier_names, unused_local_variable, unused_catch_stack, unrelated_type_equality_checks, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers, prefer_collection_literals
import 'dart:convert';
import 'dart:math';
import 'package:ecm_application/Model/Common/ProcessMasterModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Screens/Home/ECM_Tool-Screen/ECMToolScreen.dart';
import 'package:ecm_application/Screens/Home/ECM_Tool-Screen/NodeDetails_SQL.dart';
import 'package:ecm_application/Screens/Home/ECM_Tool-Screen/NodeDetails_new.dart';
import 'package:ecm_application/Services/RestPmsService.dart';
import 'package:ecm_application/core/SQLite/DbHepherSQL.dart';
import 'package:floor/floor.dart';
// import 'package:http/http.dart' as http;
import 'package:ecm_application/Model/Project/Login/AreaModel.dart';
import 'package:ecm_application/Model/Project/Login/DistibutoryModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSListViewModel.dart';
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:ecm_application/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ecm_application/Model/Project/Login/State_list_Model.dart';

class OmsPage extends StatefulWidget {
  String? ProjectName;
  String? Source;
  OmsPage({this.ProjectName, this.Source});

  @override
  State<OmsPage> createState() => _OmsPageState();
}

class _OmsPageState extends State<OmsPage> {
  List<PMSListViewModel>? _DisplayList = <PMSListViewModel>[];

  @override
  void initState() {
    super.initState();
    setState(() {
      _DisplayList = [];
      ProcessStatusList = [];
    });

    _firstLoad();
    getDropDownAsync();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  List<PMSListViewModel> Listdata = [];
  var conString;
  PMSListViewModel? viewdata;
  var listdatas;
  var area = 'All';
  var distibutory = 'ALL';
  var process = 'ALL';
  var processStatus = 'ALL';
  String? _search = '';
  AreaModel? selectedArea;
  DistibutroryModel? selectedDistributory;
  PMSChaklistModel? selectedProcess;
  ProcessModel? selectedProcessStatus;
  List<ProcessModel>? ProcessStatusList;
  Future<List<DistibutroryModel>>? futureDistributory;
  Future<List<AreaModel>>? futureArea;
  List<PMSChaklistModel>? ProcessList;
  List<PMSListViewModel> listview = [];

  Future ListcolorChanger() async {
    listview = await ListViewModel.instance.fetchByProjectAndDevice(
        widget.Source!.toLowerCase(), widget.ProjectName!);
  }

  Color colorchnger(int index) {
    try {
      for (var item in listview) {
        if (item.omsId == _DisplayList![index].omsId) {
          return Colors.blue;
        }
      }
      return Colors.blue;
    } catch (_) {
      return Colors.blue;
    }
  }

  getDropDownAsync() async {
    setState(() {
      futureArea = getAreaid();
      futureDistributory = getDistibutoryid();
    });
    await getProcessid().then((values) async {
      ProcessList = [];
      ProcessStatusList = [];
      var processList = Set();
      for (var e in values) {
        processList.add(e.processName);
      }
      List<PMSChaklistModel> newList = [];
      List<ProcessModel>? newStatusList = [];
      for (String item in processList) {
        int? processid = values
            .firstWhere((element) => element.processName == item)
            .processId;
        newList.add(PMSChaklistModel(processId: processid, processName: item));

        if (item.toLowerCase().contains('dry comm')) {
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "All",
              processStatusName: "Pending"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "3",
              processStatusName: "Commented"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "1",
              processStatusName: "Fully Completed"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "2",
              processStatusName: "Fully Completed & Approved"));
        } else {
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "All",
              processStatusName: "Pending"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "4",
              processStatusName: "Commented"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "1",
              processStatusName: "Partially Completed"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "2",
              processStatusName: "Fully Completed"));
          newStatusList.add(ProcessModel(
              processId: processid,
              processName: item,
              processStatusId: "3",
              processStatusName: "Fully Completed & Approved"));
        }
      }
      setState(() {
        ProcessList = newList;
        ProcessStatusList = newStatusList;
      });
      await addlist(ProcessList);
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
              _DisplayList = <PMSListViewModel>[];

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
          //onAreaChange(textvalue);
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
            _DisplayList = <PMSListViewModel>[];

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

  getProcess(BuildContext context, List<PMSChaklistModel> values) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 168, 211, 237),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButton(
        underline: Container(color: Colors.transparent),
        value: selectedProcess == null ||
                (values.where((element) => element == selectedProcess)).isEmpty
            ? values.first
            : selectedProcess,
        isExpanded: true,
        items: values.map((PMSChaklistModel processModel) {
          return DropdownMenuItem<PMSChaklistModel>(
            value: processModel,
            child: Center(
              child: FittedBox(
                child: Text(
                  processModel.processName!,
                  softWrap: true,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (textvalue) async {
          var data = textvalue as PMSChaklistModel;
          setState(() {
            selectedProcess = data;

            process = selectedProcess!.processId == 0
                ? "All"
                : selectedProcess!.processId.toString();
            processStatus = "All";
          });
          _firstLoad();
        },
      ),
    );
  }

  getProcessStatus(BuildContext context, List<ProcessModel> values) {
    try {
      // Determine the initial value for the DropdownButton
      final initialValue = (selectedProcessStatus == null ||
              values
                  .where((element) => element == selectedProcessStatus)
                  .isEmpty)
          ? values.first
          : selectedProcessStatus;

      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 168, 211, 237),
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<ProcessModel>(
          underline: Container(color: Colors.transparent),
          value: initialValue,
          isExpanded: true,
          items: values.map((processModel) {
            return DropdownMenuItem<ProcessModel>(
              value: processModel,
              child: Center(
                child: FittedBox(
                  child: Text(
                    processModel.processStatusName ?? '',
                    softWrap: true,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (selectedValue) {
            if (selectedValue != null) {
              setState(() {
                selectedProcessStatus = selectedValue;
                processStatus =
                    selectedProcessStatus?.processStatusId.toString() ?? '';
              });
              _firstLoad();
            }
          },
        ),
      );
    } catch (ex) {
      // print(ex);
      return Container();
    }
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
              child: Column(
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
                                          contentPadding: EdgeInsets.symmetric(
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
                                        _DisplayList = <PMSListViewModel>[];
                                      });
                                      _firstLoad();

                                      Future.delayed(Duration(seconds: 1), () {
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// This Future Builder is Used for Area DropDown list
                          FutureBuilder(
                            future: futureArea,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Expanded(
                                    child: getArea(context, snapshot.data!));
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
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Expanded(
                                    child: getDist(context, snapshot.data!));
                              } else if (snapshot.hasError) {
                                return Container() /*Text(
                                  "Something Went Wrong: " /*+
                                      snapshot.error.toString()*/
                                  ,
                               
                                )*/
                                    ;
                              } else {
                                return Center(child: Container());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (ProcessList != null)
                            Expanded(child: getProcess(context, ProcessList!)),
                          SizedBox(
                            width: 10,
                          ),
                          if (ProcessStatusList != null && process != 'All')
                            Expanded(
                                child: getProcessStatus(
                                    context,
                                    ProcessStatusList!
                                        .where((element) =>
                                            element.processId ==
                                            int.tryParse(process))
                                        .toList())),
                        ],
                      ),
                    ),
                    /* if (ProcessList != null && ProcessList!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: {
                            0: FixedColumnWidth(
                                120), // Chak No. column fixed width
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.blue),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text('CHAK NO.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                      Text('(Distri-Area)',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                for (var process in ProcessList!
                                    .where((e) => e.processId != 0))
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ConvertLongtoShortString(
                                          process.processName!),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    */
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
                                    // SizedBox(height: 150),
                                    if (_isLoadMoreRunning == true) Container(),
                                    if (_hasNextPage == false) Container(),
                                    if (_DisplayList!.isEmpty)
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        padding: EdgeInsets.all(8),
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
                                  ]),
                          ),
                        ),
                      ),
                    ),
                  ])),
        ),
      ),
    );
  }

  /*
  getBody() {
    try {
      var _processlist =
          ProcessList!.where((element) => element.processId != 0).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: {
            0: FixedColumnWidth(120), // Chak No. column fixed width
          },
          children: [
            ..._DisplayList!.map((item) {
              return TableRow(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                children: [
                  // Chak No. + Area
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () async {
                        var source = 'oms';
                        var projectName;
                        var conString;
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'Mechanical', item.mechanical.toString());
                        preferences.setString(
                            'Erection', item.erection.toString());
                        preferences.setString(
                            'DryComm', item.dryCommissioning.toString());
                        preferences.setString('AutoDryComm',
                            item.autoDryCommissioning.toString());
                        conString = preferences.getString('ConString');
                        projectName = preferences.getString('ProjectName')!;

                        conString!.toString().contains('ID=sa')
                            ? Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NodeDetails_SQL(
                                        item, projectName, source, listdatas)),
                                (Route<dynamic> route) => true,
                              ).whenComplete(() {
                                _firstLoad();
                                getDropDownAsync();
                                _controller = ScrollController()
                                  ..addListener(_loadMore);
                              })
                            : Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NodeDetails(
                                        item,
                                        projectName,
                                        source,
                                        viewdata!,
                                        listdatas)),
                                (Route<dynamic> route) => true,
                              ).whenComplete(() {
                                _firstLoad();
                                getDropDownAsync();
                                _controller = ScrollController()
                                  ..addListener(_loadMore);
                              });

                        setState(() {
                          viewdata = item;
                          listdatas = item.omsId;
                        });
                      },
                      child: Column(
                        children: [
                          Text(item.chakNo ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            "(${item.areaName} - ${item.description})",
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Process Status Images
                  ..._processlist.map((process) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        getprocessstatus(
                          process.processName!,
                          getProStatus(process.processName!, item),
                        ),
                        height: 20,
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      );
    } catch (ex, _) {
      return Container();
    }
  }
*/

  getBody() {
    try {
      var _processlist =
          ProcessList!.where((element) => element.processId != 0).toList();
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _DisplayList!.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () async {
                var source = 'oms';
                var projectName;
                var conString;
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.setString(
                    'Mechanical', _DisplayList![index].mechanical.toString());
                preferences.setString(
                    'Erection', _DisplayList![index].erection.toString());
                preferences.setString('DryComm',
                    _DisplayList![index].dryCommissioning.toString());
                preferences.setString('AutoDryComm',
                    _DisplayList![index].autoDryCommissioning.toString());
                conString = preferences.getString('ConString');
                projectName = preferences.getString('ProjectName')!;

                conString!.toString().contains('ID=sa')
                    ? Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NodeDetails_SQL(
                                _DisplayList![index],
                                projectName,
                                source,
                                listdatas)),
                        (Route<dynamic> route) => true,
                      ).whenComplete(() {
                        _firstLoad();
                        getDropDownAsync();
                        _controller = ScrollController()
                          ..addListener(_loadMore);
                      })
                    : Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NodeDetails(
                                _DisplayList![index],
                                projectName,
                                source,
                                viewdata!,
                                listdatas)),
                        (Route<dynamic> route) => true,
                      ).whenComplete(() {
                        _firstLoad();
                        getDropDownAsync();
                        _controller = ScrollController()
                          ..addListener(_loadMore);
                      });

                setState(() {
                  viewdata = _DisplayList![index];
                  listdatas = _DisplayList![index].omsId;
                });
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: colorchnger(index),
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _DisplayList![index].chakNo.toString(),
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            Text(
                              '( ' +
                                  ((_DisplayList![index].areaName ?? '').trim())
                                      .toString() +
                                  ' - ' +
                                  (_DisplayList![index].description ?? '')
                                      .trim()
                                      .toString() +
                                  ' )',
                              softWrap: true,
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.white70),
                            child: SafeArea(
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _processlist.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 4,
                                ),
                                itemBuilder: (BuildContext context, int i) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              ConvertLongtoShortString(
                                                  _processlist[i].processName!),
                                              softWrap: true,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Image(
                                                image: AssetImage(
                                                  getprocessstatus(
                                                    _processlist[i]
                                                        .processName!,
                                                    getProStatus(
                                                      _processlist[i]
                                                          .processName!,
                                                      _DisplayList![index],
                                                    ),
                                                  ),
                                                ),
                                                height: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    } catch (ex, _) {
      return Container();
    }
  }

  getprocessstatus(String pro, int proStatus) {
    String imagepath = 'assets/images/pending.png';
    try {
      if (pro.toLowerCase().contains('auto')) {
        if (proStatus == 1) {
          imagepath = 'assets/images/Completed.png';
        } else if (proStatus == 2) {
          imagepath = 'assets/images/fullydone.png';
        } else if (proStatus == 3) {
          imagepath = 'assets/images/Commented.png';
        } else {
          imagepath = 'assets/images/notcompletted.png';
        }
      } else if (pro.toLowerCase().contains('dry comm')) {
        if (proStatus == 1) {
          imagepath = 'assets/images/Completed.png';
        } else if (proStatus == 2) {
          imagepath = 'assets/images/fullydone.png';
        } else if (proStatus == 3) {
          imagepath = 'assets/images/Commented.png';
        } else {
          imagepath = 'assets/images/notcompletted.png';
        }
      } else {
        if (proStatus == 1) {
          imagepath = 'assets/images/Partially.png';
        } else if (proStatus == 2) {
          imagepath = 'assets/images/Completed.png';
        } else if (proStatus == 3) {
          imagepath = 'assets/images/fullydone.png';
        } else if (proStatus == 4) {
          imagepath = 'assets/images/Commented.png';
        } else {
          imagepath = 'assets/images/notcompletted.png';
        }
      }
    } catch (ex, _) {
      imagepath = 'assets/images/notcompletted.png';
    }
    return imagepath;
  }

  String ConvertLongtoShortString(String str) {
    var list = str.split(' ');
    var tempStr = '';
    for (var i in list)
      if (i.length > 3)
        tempStr += i.substring(0, 4).toUpperCase() + " ";
      else
        tempStr += i.toUpperCase() + " ";

    return tempStr;
  }

  getProStatus(String proStatus, PMSListViewModel model) {
    int? status = 0;
    try {
      proStatus = proStatus.toLowerCase();
      if (proStatus.contains('mechan'))
        status = int.tryParse(model.mechanical ?? '0');
      else if (proStatus.contains('erect'))
        status = int.tryParse(model.erection ?? '0');
      else if (proStatus.contains('auto dry'))
        status = int.tryParse(model.autoDryCommissioning);
      else if (proStatus.contains('auto wet'))
        status = int.tryParse(model.autoWetCommissioning);
      else if (proStatus.contains('dry comm'))
        status = int.tryParse(model.dryCommissioning ?? '0');
      else if (proStatus.contains('wet comm'))
        status = int.tryParse(model.wetCommissioning ?? '0');
    } catch (_) {}
    return status;
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
  // There is next page or not
  bool _hasNextPage = true;
  // Used to display loading indicators when _firstLoad function is running
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
      _isLoadMoreRunning = false;
    });

    try {
      final fetchedData = await getEcmStatusList(
        search: _search!,
        areaId: area,
        distibutoryId: distibutory,
        processId: process,
        subProcessId: processStatus,
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
        final fetchedData = await getEcmStatusList(
          search: _search!,
          areaId: area,
          distibutoryId: distibutory,
          processId: process,
          subProcessId: processStatus,
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

  /*void _firstLoad() async {
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

      final res = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatus?Search=$_search&areaId=$area&DistributoryId=$distibutory&Process=$process&ProcessStatus=$processStatus&pageIndex=$_page&pageSize=$_limit&Source=OMS&conString=$conString'));

      print(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatus?Search=$_search&areaId=$area&DistributoryId=$distibutory&Process=$process&ProcessStatus=$processStatus&pageIndex=$_page&pageSize=$_limit&Source=OMS&conString=$conString');

      var json = jsonDecode(res.body);
      List<PMSListViewModel> fetchedData = <PMSListViewModel>[];
      json['data']['Response']
          .forEach((e) => fetchedData.add(PMSListViewModel.fromJson(e)));
      _DisplayList = [];
      if (fetchedData.length > 0) {
        setState(() {
          _DisplayList!.addAll(fetchedData);
          // viewdata = _DisplayList;
        });
      }
    } catch (err) {
      print('Something went wrong');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
    await ListcolorChanger();
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
        //int? userid = preferences.getInt('userid');
        String? conString = preferences.getString('ConString');
        //String? project = preferences.getString('project');

        final res = await http.get(Uri.parse(
            'http://wmsservices.seprojects.in/api/PMS/ECMReportStatus?Search=$_search&areaId=$area&DistributoryId=$distibutory&Process=$process&ProcessStatus=$processStatus&pageIndex=$_page&pageSize=$_limit&Source=OMS&conString=$conString'));
        var json = jsonDecode(res.body);
        List<PMSListViewModel> fetchedData = <PMSListViewModel>[];
        json['data']['Response']
            .forEach((e) => fetchedData.add(PMSListViewModel.fromJson(e)));
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
*/

  Future addlist(List<PMSChaklistModel>? process) async {
    final existingList = await ListModel.instance.fetchAll();
    for (int i = 0; i < process!.length; i++) {
      final data = process[i];
      final exists = existingList.any((item) =>
          item.processId == data.processId &&
          item.processName == data.processName);
      if (!exists) {
        await ListModel.instance.insert(data.toJson());
      }
    }
    for (int i = 0; i <= process.length; i++) {
      final data = process[i];
      ListModel.instance.insert(data.toJson());
    }
  }
}
