// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, unused_element, prefer_typing_uninitialized_variables, unused_field, non_constant_identifier_names, prefer_const_literals_to_create_immutables, prefer_collection_literals, duplicate_ignore, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, unnecessary_null_in_if_null_operators, must_be_immutable, avoid_function_literals_in_foreach_calls, unused_local_variable, use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_catch_stack, unnecessary_null_comparison, camel_case_types, prefer_const_declarations, avoid_print, file_names, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckListModel.dart';
import 'package:ecm_application/Model/Project/RoutineCheck/RoutineCheckModel.dart';
import 'package:ecm_application/Services/RestRoutine.dart';
import 'package:ecm_application/core/utils/Common_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecm_application/Model/Common/EngineerModel.dart';
import 'package:ecm_application/Model/project/Constants.dart';
import 'package:flutter/foundation.dart';
import 'package:ecm_application/Widget/ExpandableTiles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

List<RoutineCheckMasterModel>? _DisplayList = <RoutineCheckMasterModel>[];

EngineerNameModel? usernameData;
List<EngineerNameModel>? _UserList = <EngineerNameModel>[];

class RoutineManual_CheckList extends StatefulWidget {
  String? ProjectName;
  int? OmsId;
  String? Chakno;
  String? Areaname;
  String? Description;
  bool? Mode;
  String? Source;
  String? Coordinate;

  RoutineManual_CheckList(
      int omsid,
      String chakno,
      String areaname,
      String descripton,
      String project,
      bool mode,
      String source,
      String coordinate) {
    OmsId = omsid;
    Chakno = chakno;
    Areaname = areaname;
    Description = descripton;
    ProjectName = project;
    Mode = mode;
    Source = source;
    Coordinate = coordinate;
  }

  @override
  _RoutineManual_CheckListState createState() =>
      _RoutineManual_CheckListState();
}

class _RoutineManual_CheckListState extends State<RoutineManual_CheckList> {
  String? userType = '';

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    super.initState();
    setState(() {
      listProcess = [];
      // listdistinctProcess = Set();
      subProcessName = Set();
      // selectedProcess = '';
      _widget = const Center(child: CircularProgressIndicator());
    });
    firstLoad();
    getUserType();
  }

  var subProcessname = '';
  var workedondate = '';
  var nextscheduledate = '';
  var workdoneby = '';
  var routinecheckType = '';
  var remarkval = '';
  var siteTeamMember = '';
  var approvedon = '';
  var approvedremark = '';
  var approvedby = '';
  var userName = '';
  var userTypr = '';
  var approvedStatus;
  String? pressureValue;
  String? cabinateValue;

  DateTime? currDate;
  XFile? image;
  bool? isFetchingData = true;
  bool? isSubmited = false;
  bool? hasData = false;
  final ImagePicker picker = ImagePicker();
  Uint8List? imagebytearray;
  String? _remarkController;

  Future<String> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    final position = await Geolocator.getCurrentPosition();
    return "Lat: ${position.latitude}, Lon: ${position.longitude}";
  }

  Widget _buildImageList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: imageList.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildImageListItem(index);
      },
    );
  }

  Future getImage(ImageSource media, int index) async {
    var img = await picker.pickImage(source: media, imageQuality: 30);

    var byte = await img!.readAsBytes();

    final watermarkedBytes = await ImageWatermark.addTextWatermark(
      imgBytes: byte,
      font: null, //ImageFont.readOtherFontZip(file!),
      watermarkText: await getCurrentLocation(),
      dstX: 20,
      dstY: 30,
    );

    XFile newimage = XFile.fromData(watermarkedBytes,
        name: img.name, mimeType: 'image/jpeg', path: img.path);

    // saveImageToDevice(
    //   newimage,
    // );
    // Create a temporary file to store the watermarked image
    final tempDir = await getTemporaryDirectory();
    final watermarkedFile = File('${tempDir.path}/${img.name}');
    await watermarkedFile.writeAsBytes(watermarkedBytes);

    setState(() {
      image = XFile(watermarkedFile.path); // Reference the temporary file
      imageList[index].mediaFile = image;
      imageList[index].imageByteArray = watermarkedBytes;
      hasData = false;
      // image = newimage;
      // imageList[index].image = newimage;
      // imageList[index].imageByteArray = watermarkedBytes;
    });
  }

  Widget _buildImageListItem(int index) {
    final imageItem = imageList[index];
    return ListTile(
      trailing: imageItem.imageByteArray != null
          ? InkWell(
              onTap: () => previewAlert(
                  imageItem.imageByteArray!, index, imageItem.description),
              child: Image.memory(
                imageItem.imageByteArray!,
                fit: BoxFit.fitWidth,
                width: 50,
                height: 50,
              ),
            )
          : GestureDetector(
              onTap: () {
                uploadAlert(index);
              },
              child: Image(
                image: AssetImage('assets/images/uploadimage.png'),
                fit: BoxFit.cover,
                height: 50,
                width: 50,
              ),
            ),
      title: SizedBox(
        width: 140,
        child: Text(
          imageItem.description,
          style: TextStyle(color: Colors.green, fontSize: 15),
        ),
      ),
    );
  }

  Future<void> imageListpopup() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          iconColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Container(width: 500, child: _buildImageList(context)),
        );
      },
    );
  }

  void previewAlert(var photos, int index, var desc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            iconColor: Colors.red,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            // title: Text('Please choose media to select'),
            content: Container(
              margin: EdgeInsets.only(left: 4, right: 4, bottom: 7),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreviewImageWidget(photos
                                  // imagebytearray!
                                  ))),
                      child: Image.memory(
                        photos!,
                        //to show image, you type like this.

                        fit: BoxFit.fitWidth,
                        width: 250,
                        height: 250,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        setState(() {
                          imageList[index].imageByteArray = imagebytearray;
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Icon(Icons.delete),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        // hasData = false;
                        Navigator.pop(context);
                        getImage(ImageSource.gallery, index);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.image),
                          Text('From Gallery'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      //if user click this button. user can upload image from camera
                      onPressed: () {
                        // hasData = false;
                        Navigator.pop(context);
                        getImage(ImageSource.camera, index);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera),
                          Text('From Camera'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void uploadAlert(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            iconColor: Colors.red,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery, index);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera, index);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showAlert(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Remark*',
                ),
                onChanged: (value) {
                  _remarkController = value;
                },
                validator: (value) {
                  if (value! == '') {
                    return 'Please enter Remark';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('OK'),
              onPressed: () {
                if (_remarkController != null) {
                  currDate = DateTime.now();
                  insertRoutineCheckListData(
                          _ChecklistModel!, _remarkController!)
                      .then(
                    (value) {
                      switch (value) {
                        case 1:
                          _showToast(
                              "Partially done is not allow in this process",
                              MessageType: 1);
                          break;
                        case 2:
                          _showToast("Data Updated Successfully",
                              MessageType: 0);
                          break;
                        case 3:
                          _showToast("Minimum 3 Images are required to proceed",
                              MessageType: 1);
                          break;
                        case 4:
                          _showToast("Something Went Wrong!!!", MessageType: 1);
                          break;
                      }
                    },
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  FToast? fToast;

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

  firstLoad() async {
    _ChecklistModel = [];
    imageList = [];
    subProcessName = Set();
    var workedBy = '';
    await getRoutineCheckList(
            widget.OmsId.toString(), widget.Source!.toString())
        .then((value) {
      for (var element in value) {
        if (element.inputType != 'image' &&
            element.routineTestType == 'MANUAL CHECK') {
          setState(() {
            subProcessName!.add(element.processType!);
            subProcessname = (element.processType ?? '').toString();
            workedondate = (element.workedOn ?? '').toString();
            nextscheduledate = (element.nextScheduleDate ?? '').toString();
            remarkval = (element.remark ?? '').toString();
            workedBy = (element.workedBy ?? '').toString();
            routinecheckType = ((element.routineTestType ?? '')).toString();
          });
        }
      }
      getWorkedByNAme((workedBy).toString());
      setState(() {
        _ChecklistModel!.addAll(value
            .where((element) => element.routineTestType == 'MANUAL CHECK'));
        imageList.addAll(value.where((element) =>
            element.inputType == 'image' &&
            element.routineTestType == 'MANUAL CHECK'));
      });
    });
  }

  Widget? _widget;
  List imageList = [];
  List<RoutineCheckListModel>? _ChecklistModel;
  List<RoutineCheckListModel>? listProcess;
  Set<String>? subProcessName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text((widget.Chakno ?? '')),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Distibutory : ${widget.Areaname!}'),
                              SizedBox(
                                width: 130,
                                child:
                                    Text('Sub Area : ${widget.Description!}'),
                              )
                            ],
                          ),
                        ),

                        //Expandable Tile
                        getECMFeed(
                            pos: widget.Coordinate!.trim().replaceAll('°', '')),
                        //Image Selection Tile
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: imageList
                                          .where((element) =>
                                              element.inputType == 'image' &&
                                              element.routineTestType ==
                                                  'MANUAL CHECK' &&
                                              element.value != null)
                                          .isNotEmpty
                                      ? GestureDetector(
                                          onTap: () async {
                                            await imageListpopup();
                                          },
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/imagepreview.png'),
                                            fit: BoxFit.cover,
                                            height: 80,
                                            width: 80,
                                          ))
                                      : GestureDetector(
                                          onTap: () async {
                                            await imageListpopup();
                                          },
                                          child: Image(
                                            image: AssetImage(
                                                'assets/images/uploadimage.png'),
                                            fit: BoxFit.cover,
                                            height: 80,
                                            width: 80,
                                          ))),
                              imageList
                                      .where((element) =>
                                          element.inputType == 'image' &&
                                          element.routineTestType ==
                                              'MANUAL CHECK' &&
                                          element.value != null)
                                      .isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: SizedBox(
                                          child: Center(
                                              child: Text('Image Uploaded'))))
                                  : Center(
                                      child: Text(
                                        "No Image Uploaded",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        //Submit Button

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                child: Text(
                                  "Submit",
                                ),
                                onPressed: (() async {
                                  await btnSubmit_Clicked();
                                  // _showAlert(context);
                                }),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        //Submittion Tile
                        if (remarkval.isNotEmpty)
                          Padding(
                              padding: EdgeInsets.all(8),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Last Routine check done By: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            workdoneby.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'On Date : ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            getshortdate(workedondate),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Next Schedule Date : ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            getshortdate(nextscheduledate),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Remark: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Text(
                                              remarkval,
                                              softWrap: true,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ]),
                ),
              ),
            ],
          ),
        ));
  }

  getECMFeed({String? pos}) {
    Widget? widget = const Center(child: CircularProgressIndicator());
    if (subProcessName!.isNotEmpty && _ChecklistModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in subProcessName!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ExpandableTile(
                  title: Text(
                    subProcess.toUpperCase(),
                    softWrap: true,
                  ),
                  body: Column(children: [
                    for (var item in _ChecklistModel!.where((e) =>
                        e.processType == subProcess &&
                        e.routineTestType == 'MANUAL CHECK' &&
                        e.inputType != 'image' &&
                        e.processType != 'image'))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(item.description!,
                                  textAlign: TextAlign.left, softWrap: true),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            if (item.inputType == 'ACP')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'ACP',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('ACP'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Liner Sheet',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Liner Sheet'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Not Available',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Not Available'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio1')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Ok',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Damage',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Damage'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio2')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Damage',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Not Available',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Not Available'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio3')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Ok',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Damage',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Theft',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Theft'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio4')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Available',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Available'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Damage',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Theft',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Theft'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio5')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Ok',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Theft',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Theft'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'radio6')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Yes',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Yes'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'No',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('No'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'SolenoidType')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Old',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Old'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'New',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('New'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'Not Available',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Not Available'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'SolarType')
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: '6 Watt',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('6 Watt'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: '10 Watt',
                                            groupValue: item.value,
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  item.value = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('10 Watt'),
                                        ],
                                      ),
                                    ],
                                  )),
                            if (item.inputType == 'text')
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  // enabled: isEdit,
                                  initialValue: item.value,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blue),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      item.value = value;
                                    });
                                  },
                                ),
                              ),
                            if (item.inputType == 'boolean')
                              Expanded(
                                  flex: 0,
                                  child: Checkbox(
                                    activeColor: Colors.white54,
                                    checkColor: Colors.green,
                                    value: item.value == 'OK' ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        item.value = value! ? 'OK' : '';
                                      });
                                    },
                                  )),
                          ],
                        ),
                      )
                  ])),
            )
        ],
      );
    } else {
      widget = const Center(child: CircularProgressIndicator());
    }
    return widget;
  }

  /*Widget getSignalDetails(String details) {
    try {
      List<dynamic> signalDetails = ['', '', '', '', '', ''];
      signalDetails = details.split(' ');
      var lat = signalDetails.elementAt(0) ?? '';
      var lon = signalDetails.elementAt(1) ?? '';
      var distance = signalDetails.elementAt(2) ?? '';
      var rssi = signalDetails.elementAt(3) ?? '';
      var snr = signalDetails.elementAt(4) ?? '';
      return Container(
        // height: 100,
        width: 160,
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 43, 40, 40)),
            borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Latitude: $lat"),
              Text("Longitude: $lon"),
              Text("Distance: $distance KM"),
              Text("RSSI: $rssi dB"),
              Text("SNR: $snr dB"),
            ],
          ),
        ),
      );
    } catch (ex, _) {
      return Container(
        height: 35,
        width: 160,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5)),
        child: Center(child: Text('N/A')),
      );
    }
  }
*/
  getWorkedByNAme(String userid) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');

      final res = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/login/GetUserDetailsByMobile?mobile=""&userid=$userid&conString=$conString'));

      print(
          'http://wmsservices.seprojects.in/api/login/GetUserDetailsByMobile?mobile=""&userid=$userid&conString=$conString');

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response']);
          setState(() {
            workdoneby = loginResult.firstname.toString();
          });
          print(loginResult.firstname.toString());
          return loginResult.firstname.toString();
        } else
          return '';
      } else {
        return '';
      }
    } catch (err) {
      userName = '';
      return '';
    }
  }

  getUserType() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      userType = pref.getString('usertype');
    } catch (_, ex) {
      userType = '';
    }
  }

  String generateRandomString({int length = 6}) {
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<String?> uploadImage(String ImagePath, XFile? image) async {
    try {
      var uniqueIdentifier =
          generateRandomString(); // Generate a random alphanumeric string
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var imageName = '$uniqueIdentifier-$timestamp.jpg';
      var imgData = await http.MultipartFile.fromPath('Image', image!.path,
          filename: imageName);
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://wmsservices.seprojects.in/api/Routine?imgDirPath=$ImagePath&Api=2'));
      print(
          'http://wmsservices.seprojects.in/api/Routine?imgDirPath=$ImagePath&Api=2');

      request.files.add(imgData);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var path = await response.stream.bytesToString();

        if (path == '""')
          return '';
        else
          return path.replaceAll('"', '');
      } else {
        return '';
      }
    } catch (_) {}
    return '';
  }

  Future<String> GetImagebyPath(String imgPath) async {
    String img64base = "";
    try {
      var request = http.Request(
          'GET',
          Uri.parse(
              'http://wmsservices.seprojects.in/api/Image/GetImage?imgPath=$imgPath'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        img64base = await response.stream.bytesToString();
      } else {
        print(response.reasonPhrase);
      }
    } catch (_, ex) {}
    return img64base;
  }

  Future btnSubmit_Clicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool allow = true;
      String _proj = prefs.getString("ProjectName")!.toLowerCase();

      if (allow) {
        _showAlert(context);
      }
    } catch (ex, _) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(ex.toString()),
            actions: <Widget>[
              TextButton(
                child: Text(WebApiStatusOk),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<int> insertRoutineCheckListData(
      List<RoutineCheckListModel> _checkList, String _remark) async {
    bool flag = false;
    // int _routineStatus = 0;
    try {
      var _list = _checkList
          .where((item) =>
              !item.inputType!.contains("image") &&
              item.routineTestType!.toString().contains('MANUAL CHECK'))
          .toList();

      var _listdataWithoutNullValue = _checkList
          .where((item) =>
              !item.inputType!.contains("image") &&
              item.value != null &&
              item.value!.isNotEmpty &&
              item.routineTestType!.toString().contains('MANUAL CHECK'))
          .toList();

      var _imglist = _checkList
          .where((item) =>
              item.inputType!.contains("image") &&
              item.routineTestType!.toString().contains('MANUAL CHECK'))
          .toList();

      var _imglistdataWithoutNullValue = _checkList
          .where((item) =>
              item.inputType!.contains("image") &&
              item.mediaFile != null &&
              item.routineTestType!.toString().contains('MANUAL CHECK'))
          .toList();

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? project = preferences.getString('ProjectName');
      int? proUserId = preferences.getInt('ProUserId');

      String? projectId = preferences.getString('ProjectId');
      var omsId = widget.OmsId;
      String submitDate = DateFormat('ddMMyyyy-HHmmss').format(currDate!);
      final _userName = preferences.getString('firstname');
      final dirPath = "$project/$omsId/$_userName$submitDate/";
      final _routineStatus = 2;

      int countflag = 0;
      int uploadflag = 0;
      if (_listdataWithoutNullValue.isEmpty) {
        return 1;
      }
      if (_imglistdataWithoutNullValue.length < 3) {
        return 3;
      } else {
        await Future.wait(_imglistdataWithoutNullValue
            .where((element) =>
                element.inputType == 'image' && element.mediaFile != null)
            .map((element) async {
          String? imagePathValue = await uploadRoutineImage(
              element.mediaFile!.path, widget.Source!.toUpperCase(), omsId!);
          // String? imagePathValue =
          //     await uploadRoutineImage(dirPath, element.mediaFile);
          if (imagePathValue!.isNotEmpty) {
            element.value = imagePathValue;
            uploadflag++;
          }
          countflag++;
        }));
      }
      final checkListId = _list.map((x) => x.id.toString()).join(',') +
          ',' +
          _imglist.map((x) => x.id.toString()).join(',');
      debugPrint(checkListId);

      final valueData = _list.map((x) => x.value?.trim() ?? '').join(',') +
          ',' +
          _imglist.map((x) => x.value?.trim() ?? '').join(',');

      var data = json.encode({
        "Checklistid": checkListId,
        "deviceId": widget.OmsId,
        "userid": proUserId,
        "values": valueData,
        "remark": _remark,
        "routineStatus": _routineStatus,
        "projectId": projectId
      });

      if (countflag == uploadflag) {
        var result = await uploadRoutineReport(data);
        isSubmited = true;
        firstLoad();
        return 2;
      } else {
        throw Exception();
      }
      /*var Insertobj = Map<String, dynamic>();

      Insertobj["checkListData"] = checkListId;
      Insertobj["OmsId"] = widget.OmsId;
      Insertobj["userId"] = proUserId.toString();
      Insertobj["valuedata"] = valueData;
      Insertobj["Remark"] = _remark;
      Insertobj["RoutineStatus"] = _routineStatus;
      Insertobj["conString"] = conString;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/Routine/InsertRoutineReport'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);
        print(request.body);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            isSubmited = true;
            firstLoad();
            return 2;
          } else
            throw Exception();
        } else
          throw Exception();
      } else {
        throw Exception();
      }*/
    } catch (_) {
      return 4;
    }
  }
}

class InsertObjectModel {
  String? checkListData;
  String? OmsId;
  String? userId;
  String? valuedata;
  String? Remark;
  String? RoutineStatus;
  String? conString;
}

class PreviewImageWidget extends StatelessWidget {
  Uint8List? bytearray;
  PreviewImageWidget(this.bytearray) {
    super.key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview Image')),
      body: Container(
        child: PhotoView(imageProvider: MemoryImage(bytearray!)),
      ),
    );
  }
}
