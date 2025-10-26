import 'package:ecm_application/Model/Project/ECMTool/ECMCountMasterModel.dart';
import 'package:ecm_application/Model/Project/Login/AreaModel.dart';
import 'package:ecm_application/Model/Project/Login/DistibutoryModel.dart';
import 'package:ecm_application/Operations/StatelistOperation.dart';
import 'package:ecm_application/Services/RestPmsService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EcmCountStatusWidget extends StatefulWidget {
  final String source;

  const EcmCountStatusWidget({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<EcmCountStatusWidget> createState() => _EcmCountStatusWidgetState();
}

class _EcmCountStatusWidgetState extends State<EcmCountStatusWidget> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getDropDownAsync();
  }

  var area = 'All';
  var distibutory = 'ALL';

  AreaModel? selectedArea;
  DistibutroryModel? selectedDistributory;

  Future<List<DistibutroryModel>>? futureDistributory;
  Future<List<AreaModel>>? futureArea;
  String? conString, projectName;
  ECMStatusCountMasterModel? value;
  getDropDownAsync() async {
    setState(() {
      futureArea = getAreaid();
      futureDistributory = getDistibutoryid();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    projectName = preferences.getString('project');
    conString = preferences.getString('Constring');
    getECMReportStatusCoun(area, distibutory, widget.source);
  }

  @override
  Widget build(BuildContext context) {
    return getCountPopup();
  }

  getCountPopup() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
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
                                //Heading Part
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
                                              projectName.toString(),
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

                                /*  //DropDown
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// This Future Builder is Used for Area DropDown list
                                    FutureBuilder(
                                      future: futureArea,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return Expanded(
                                              child: getArea(
                                                  context, snapshot.data!));
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
                                    FutureBuilder(
                                      future: futureDistributory,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return Expanded(
                                              child: getDist(
                                                  context, snapshot.data!));
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
*/
                                //Total Node Count
                                // if (isload == false)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.blue.shade200),
                                        width: double.infinity,
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            "Total Node: " +
                                                value!.sCount.toString(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Count Container
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              //Mechenical
                                              if (value!.pendingMechanical != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Mechanical Installation',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingMechanical
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedMechanical
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyMechanical
                                                                              .toString()),
                                                                      Text('FULLY DONE:' +
                                                                          value!
                                                                              .fullyMechanical
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedMechanical
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              //Controll Unit
                                              if (value!.pendingErection != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Control Unit Erection',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingErection
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedErection
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyErection
                                                                              .toString()),
                                                                      Text('FULLY DONE: ' +
                                                                          value!
                                                                              .fullyErection
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedErection
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              //Wet Comm
                                              if (value!.pendingWetComm != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Dry Commissionning',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingDryComm
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedDryComm
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyDryComm
                                                                              .toString()),
                                                                      Text('FULLY DONE: ' +
                                                                          value!
                                                                              .fullyDryComm
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedDryComm
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              //Dry Comm
                                              if (value!.pendingDryComm != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Wet Commissionning',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingWetComm
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedWetComm
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyWetComm
                                                                              .toString()),
                                                                      Text('FULLY DONE: ' +
                                                                          value!
                                                                              .fullyWetComm
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedWetComm
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              //Tower Installation
                                              if (value!.pendingProcess1 != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Tower Installation',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingProcess1
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedProcess1
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyProcess1
                                                                              .toString()),
                                                                      Text('FULLY DONE:' +
                                                                          value!
                                                                              .fullyProcess1
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedProcess1
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (value!.pendingProcess2 != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Control Unit Erection',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingProcess2
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedProcess2
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyProcess2
                                                                              .toString()),
                                                                      Text('FULLY DONE:' +
                                                                          value!
                                                                              .fullyProcess2
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedProcess2
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (value!.pendingProcess3 != 0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Commissioning',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingProcess3
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedProcess3
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyProcess3
                                                                              .toString()),
                                                                      Text('FULLY DONE:' +
                                                                          value!
                                                                              .fullyProcess3
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedProcess3
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (value!.pendingAutoDryComm !=
                                                  0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Auto Dry Commissionning',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingAutoDryComm
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedAutoDryComm
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyAutoDryComm
                                                                              .toString()),
                                                                      Text('FULLY DONE: ' +
                                                                          value!
                                                                              .fullyAutoDryComm
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedWetComm
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (value!.pendingAutoWetComm !=
                                                  0)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            height: 20,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade200),
                                                            child: Center(
                                                              child: Text(
                                                                'Auto Wet Commissionning',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/notcompletted.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Commented.png'),
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Partially.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/Completed.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Image(
                                                                        image: AssetImage(
                                                                            'assets/images/fullydone.png'),
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text('PENDING: ' +
                                                                          value!
                                                                              .pendingAutoWetComm
                                                                              .toString()),
                                                                      Text('COMMENTED: ' +
                                                                          value!
                                                                              .rejectedAutoWetComm
                                                                              .toString()),
                                                                      Text('PARTIALLY DONE: ' +
                                                                          value!
                                                                              .partiallyAutoWetComm
                                                                              .toString()),
                                                                      Text('FULLY DONE: ' +
                                                                          value!
                                                                              .fullyAutoWetComm
                                                                              .toString()),
                                                                      Text('FULLY DONE & APPROVED: ' +
                                                                          value!
                                                                              .fullyApprovedWetComm
                                                                              .toString())
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                                /* if (isload == true)
                                SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                           */
                              ]),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
