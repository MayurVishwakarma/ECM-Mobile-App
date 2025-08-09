// ignore_for_file: non_constant_identifier_names, must_be_immutable, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, unused_element, unused_field, prefer_typing_uninitialized_variables, prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, file_names, unnecessary_null_comparison, unused_local_variable, unused_catch_stack, prefer_collection_literals

import 'dart:convert';
import 'dart:io';
import 'package:ecm_application/Model/Project/Damage/DamageCommanModel.dart';
import 'package:ecm_application/Model/Project/Damage/OmsSurveyModel.dart';
import 'package:ecm_application/Model/Project/Damage/SurveyInsertModel%20.dart';
import 'package:ecm_application/Services/RestDamage.dart';
import 'package:ecm_application/Model/Common/EngineerModel.dart';
import 'package:ecm_application/Model/project/Constants.dart';
import 'package:ecm_application/core/constants/OMSComponent.dart';
import 'package:ecm_application/core/utils/Common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:ecm_application/Widget/ExpandableTiles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

SurveyModel? modelData;
List<DamageInsertModel>? _DisplayList = <DamageInsertModel>[];

EngineerNameModel? usernameData;
List<EngineerNameModel>? _UserList = <EngineerNameModel>[];

class SurveyInsertPage extends StatefulWidget {
  String? ProjectName;
  String? Source;

  // ignore: use_key_in_widget_constructors
  SurveyInsertPage(SurveyModel? _modelData, String project, String source) {
    modelData = _modelData;
    ProjectName = project;
    Source = source;
  }
  @override
  _SurveyInsertPageState createState() => _SurveyInsertPageState();
}

class _SurveyInsertPageState extends State<SurveyInsertPage> {
  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    super.initState();
    setState(() {
      processList = Set();
      _widget = const Center(child: CircularProgressIndicator());
    });
    getECMData();
  }

  var subProcessname = '';
  var workedondate = '';
  var workdoneby = '';
  var remarkval = '';
  var userName = '';
  var deviceids;
  XFile? image;
  bool? isFetchingData = true;
  bool? isSubmited = false;
  final ImagePicker picker = ImagePicker();
  Uint8List? imagebytearray;
  String? _remarkController;
  String? pressureValue;
  String? cabinateValue;
  Widget? _widget;
  List<SurveyInsertModel> imageList = [];
  List<SurveyInsertModel>? _ChecklistModel;

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

  Future getImage(ImageSource media, int index) async {
    var img = await picker.pickImage(source: media, imageQuality: 30);
    var byte = await img!.readAsBytes();
    final watermarkedBytes = await ImageWatermark.addTextWatermark(
      imgBytes: byte,
      font: null,
      watermarkText: await getCurrentLocation(),
      dstX: 20,
      dstY: 30,
    );

    XFile newimage = XFile.fromData(watermarkedBytes,
        name: img.name, mimeType: 'image/jpeg', path: img.path);

    final tempDir = await getTemporaryDirectory();
    final watermarkedFile = File('${tempDir.path}/${img.name}');
    await watermarkedFile.writeAsBytes(watermarkedBytes);

    setState(() {
      image = XFile(watermarkedFile.path); // Reference the temporary file
      imageList[index].image = image;
      imageList[index].imageByteArray = watermarkedBytes;
    });
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
          content: Container(
              width: 500,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: imageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    trailing: imageList[index].imageByteArray != null
                        ? InkWell(
                            onTap: () => previewAlert(
                                imageList[index].imageByteArray!,
                                index,
                                imageList[index].description),
                            child: Image.memory(
                              imageList[index].imageByteArray!,
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
                              image:
                                  AssetImage('assets/images/uploadimage.png'),
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                            ),
                          ),
                    title: SizedBox(
                      width: 140,
                      child: Text(
                        imageList[index].description!,
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                    ),
                  );
                },
              )),
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
                              builder: (context) =>
                                  PreviewImageWidget(photos))),
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
                        children: const [
                          Icon(Icons.delete),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // hasData = false;
                        Navigator.pop(context);
                        getImage(ImageSource.gallery, index);
                      },
                      child: Row(
                        children: const [
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
                        children: const [
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
                      children: const [
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
                      children: const [
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
                  hintText:
                      'Enter Remark*', // Placeholder text for Remark field
                ),
                onChanged: (value) {
                  _remarkController = value;
                },
                validator: (value) {
                  if (value! == '') {
                    return 'Please enter Remark'; // Validation for Remark field
                  }
                  return null;
                },
              ),
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
                  Navigator.of(context).pop();
                  if (_ChecklistModel!.isNotEmpty) {
                    damageCheckListData(_ChecklistModel!).then((value) =>
                        _showToast(
                            isSubmited!
                                ? "Data Updated Successfully"
                                : "Something Went Wrong!!!",
                            MessageType: isSubmited! ? 0 : 1));
                  } /* else if (_MaterialCheckListModel!.isNotEmpty) {
                    damageCheckListDataForMaterial(
                            _MaterialCheckListModel!, _remarkController ?? "")
                        .then((value) => _showToast(
                            isSubmited!
                                ? "Data Updated Successfully"
                                : "Something Went Wrong!!!",
                            MessageType: isSubmited! ? 0 : 1));
                  } else if (_InfoCheckListModel!.isNotEmpty) {
                    damageCheckListDataForInfotmtion(
                            _InfoCheckListModel!, _remarkController ?? "")
                        .then((value) => _showToast(
                            isSubmited!
                                ? "Data Updated Successfully"
                                : "Something Went Wrong!!!",
                            MessageType: isSubmited! ? 0 : 1));
                  } else if (_IssueCheckListModel!.isNotEmpty) {
                    damageCheckListDataForIssues(
                            _IssueCheckListModel!, _remarkController ?? "")
                        .then((value) => _showToast(
                            isSubmited!
                                ? "Data Updated Successfully"
                                : "Something Went Wrong!!!",
                            MessageType: isSubmited! ? 0 : 1));
                  }*/
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

  String buttonText = 'Edit';
  base64ToPdf(String base64String, String fileName) async {
    var bytes = base64Decode(base64String);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await OpenFile.open("${output.path}/$fileName.pdf");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getAppbarName(widget.Source!)),
          actions: [
            Padding(
              padding: EdgeInsets.all(8),
              child: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    base64ToPdf(OmsCompenents.comPdf, 'Component Manual');
                  }),
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Distri/Zone :",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            )),
                        Text(modelData!.areaName ?? '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Area/Village:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            )),
                        Text(modelData!.description ?? '',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Expandable Tile
                        getDamageFeed(),
                        if (imageList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: imageList
                                            .where((element) =>
                                                element.inputType == 'Image' &&
                                                element.value != null)
                                            .isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              imageListpopup();
                                            },
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/images/imagepreview.png'),
                                              fit: BoxFit.cover,
                                              height: 80,
                                              width: 80,
                                            ))
                                        : GestureDetector(
                                            onTap: () {
                                              imageListpopup();
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
                                            // element.id == Id &&
                                            element.inputType == 'Image' &&
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

                        ElevatedButton(
                          child: Text('Submit'),
                          onPressed: (() async {
                            /*if (buttonText == 'Edit') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Do you want edit ?"),
                                    actions: [
                                      TextButton(
                                          child: Text("Cencel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      TextButton(
                                          child: Text("OK"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            buttonText = 'Update';
                                            isEdit = true;
                                          }),
                                    ],
                                  );
                                },
                              );
                            } else {*/
                            _showAlert(context);
                            // }
                          }),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: Colors.blue),
                        ),

                        if (remarkval.isNotEmpty)
                          Padding(
                              padding: EdgeInsets.all(8),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Update',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'By User: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
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
                                            'On: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            getshortdate(workedondate) ?? "",
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

  getECMData() {
    _ChecklistModel = [];
    imageList = [];
    remarkval = '';

    try {
      if (widget.Source == 'oms') {
        getSurveyformOms(modelData!.omsId!).then((value) {
          setState(() {
            remarkval = value.first.remark ?? '';
            workedondate = (value.first.datetime ?? '').toString();
            getWorkedByNAme((value.first.userId ?? '').toString());
            _ChecklistModel = value;
            imageList
                .addAll(value.where((element) => element.inputType == 'Image'));
            for (var element in _ChecklistModel!) {
              processList!.add(element.type!);
            }
          });
        });
      }
    } catch (_) {}
  }

  getAppbarName(String source) {
    var title;
    try {
      if (source == 'oms') {
        title = modelData!.chakNo.toString();
      } else if (source == 'ams') {
        title = modelData!.amsNo.toString();
      } else if (source == 'rms') {
        title = modelData!.rmsNo.toString();
      } else if (source == 'lora') {
        title = modelData!.gatewayName;
      } else {
        title = '';
      }
    } catch (_) {
      title = '';
    }
    return title;
  }

  Set<String>? processList;

  getWorkedByNAme(String userid) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      final res = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/login/GetUserDetailsByMobile?mobile=""&userid=$userid&conString=$conString'));
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response']);
          setState(() {
            workdoneby = loginResult.firstname.toString();
          });

          return loginResult.firstname.toString();
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (err) {
      userName = '';
      return '';
    }
  }

   var getworkby;
  var getapproveby;
  bool isLoading = false;

  getDamageFeed() {
    Widget? widget = const Center(child: CircularProgressIndicator());
    if (processList!.isNotEmpty && _ChecklistModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in processList!)
            if (subProcess == "Automation" || subProcess == "Mechanical")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ExpandableTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subProcess.toString().toUpperCase(),
                        softWrap: true,
                      ),
                      Text("Survey",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  body: Column(
                    children: [
                      for (var item in _ChecklistModel!.where((e) =>
                          e.type.toString() == subProcess &&
                          e.inputType != 'Image'))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item.description ?? '',
                                    textAlign: TextAlign.left, softWrap: true),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              if (item.inputType == 'cabinet')
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
                                              value: 'Theft 1',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Theft 1'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Theft 2',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Theft 2'),
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

                              if (item.inputType == 'radio5')
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'All Ok',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('All Ok'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '1 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('1 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '2 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('2 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '3 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('3 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '4 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('4 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '5 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('5 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '6 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('6 Damage'),
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
                                              value: 'All Ok',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('All Ok'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '1 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('1 Theft'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '2 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('2 Theft'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '3 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('3 Theft'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '4 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('4 Theft'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '5 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('5 Theft'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: '6 Theft',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('6 Theft'),
                                          ],
                                        ),
                                      ],
                                    )),
                              if (item.inputType == 'radio7')
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
                                              value: 'Not Install',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Not Install'),
                                          ],
                                        ),
                                      ],
                                    )),

                              if (item.inputType == 'radio8')
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Available-1',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Available-1'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Available-2',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Available-2'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Not Installed',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Not Installed'),
                                          ],
                                        ),
                                      ],
                                    )),
                              if (item.inputType == 'radio9')
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
                                        )
                                      ],
                                    )),
                              if (item.inputType == 'radio10')
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Installed',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Installed'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Not Installed',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Not Installed'),
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
                              if (item.inputType == 'solenoid')
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
                                              value: 'Not Install',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Not Install'),
                                          ],
                                        ),
                                      ],
                                    )),
                              if (item.inputType == 'solar')
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
                              if (item.inputType == 'cabinetdamage')
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value
                                                    ?.contains('All Ok') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions
                                                        .add('All Ok');
                                                  } else {
                                                    selectedOptions
                                                        .remove('All Ok');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('All Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Top Side Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions
                                                        .add('Top Side Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Top Side Damage');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Top Side Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Back Side Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Back Side Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Back Side Damage');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Back Side Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value
                                                    ?.contains('Door Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions
                                                        .add('Door Damage');
                                                  } else {
                                                    selectedOptions
                                                        .remove('Door Damage');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Door Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Airvalve Or Manifold Side Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Airvalve Or Manifold Side Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Airvalve Or Manifold Side Damage');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text(
                                              'Airvalve Or Manifold\n Side Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Fully Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      cabinateValue == null ||
                                                              cabinateValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : cabinateValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions
                                                        .add('Fully Damage');
                                                  } else {
                                                    selectedOptions
                                                        .remove('Fully Damage');
                                                  }

                                                  cabinateValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = cabinateValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Fully Damage'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              if (item.inputType == 'pressure')
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value
                                                    ?.contains('All Ok') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions
                                                        .add('All Ok');
                                                  } else {
                                                    selectedOptions
                                                        .remove('All Ok');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('All Ok'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Filter Inlet PT Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Filter Inlet PT Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Filter Inlet PT Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Filter Inlet PT\n Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Filter Outlet PT Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Filter Outlet PT Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Filter Outlet PT Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Filter Outlet PT\n Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT1 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT1 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT1 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT1 Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT2 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT2 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT2 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT2 Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT3 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT3 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT3 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT3 Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT4 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT4 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT4 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT4 Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT5 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT5 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT5 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT5 Damage'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: item.value?.contains(
                                                    'Outlet PT6 Damage') ??
                                                false,
                                            onChanged: (bool? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  final selectedOptions =
                                                      pressureValue == null ||
                                                              pressureValue!
                                                                  .isEmpty
                                                          ? <String>{}
                                                          : pressureValue!
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'[\(\)]'),
                                                                  '') // Remove { and }
                                                              .split('|')
                                                              .map((e) =>
                                                                  e.trim())
                                                              .toSet();

                                                  if (newValue) {
                                                    selectedOptions.add(
                                                        'Outlet PT6 Damage');
                                                  } else {
                                                    selectedOptions.remove(
                                                        'Outlet PT6 Damage');
                                                  }

                                                  pressureValue =
                                                      '(${selectedOptions.join('| ')})';

                                                  item.value = pressureValue;
                                                });
                                              }
                                            },
                                          ),
                                          Text('Outlet PT6 Damage'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
/*                              Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'All Ok',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('All Ok'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Filter Inlet PT Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Filter Inlet PT\n Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Filter Outlet PT Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Filter Outlet PT\n Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT1 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT1 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT2 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT2 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT3 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT3 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT4 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT4 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT5 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT5 Damage'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'Outlet PT6 Damage',
                                              groupValue: item.value,
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    item.value = newValue;
                                                  });
                                                }
                                              },
                                            ),
                                            Text('Outlet PT6 Damage'),
                                          ],
                                        ),
                                      ],
                                    )),*/
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

                              // if (item.inputType == 'boolean')
                              //   Expanded(
                              //       flex: 0,
                              //       child: Checkbox(
                              //         activeColor: Colors.white54,
                              //         checkColor:
                              //             Color.fromARGB(255, 251, 3, 3),
                              //         value: item.value == '1' ? true : false,
                              //         onChanged: (value) {
                              //           setState(() {
                              //             item.value = value! ? '1' : '';
                              //           });
                              //         },
                              //       ))
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
        ],
      );
    }

    /*else if (processList!.isNotEmpty && _MaterialCheckListModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in processList!)
            if (subProcess == "Electrical" ||
                subProcess == "Mechanical" ||
                subProcess == "Tubing")
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ExpandableTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subProcess.toString().toUpperCase(),
                          softWrap: true,
                        ),
                        Text("Qty",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            )),
                      ],
                    ),
                    body: Column(children: [
                      for (var item in _MaterialCheckListModel!
                          .where((e) => e.type.toString() == subProcess))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 15,
                                child: Text(item.rectification!,
                                    textAlign: TextAlign.left, softWrap: true),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                    enabled: isEdit!,
                                    initialValue: item.value,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue), //<-- SEE HERE
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        item.value = value;
                                        value = item.value = value;
                                      });
                                    }),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(""),
                              ),
                            ],
                          ),
                        )
                    ])),
              )
        ],
      );
    } else if (processList!.isNotEmpty && _InfoCheckListModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in processList!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ExpandableTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subProcess.toString().toUpperCase(),
                        softWrap: true,
                      ),
                      Text("Is Available",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  body: Column(children: [
                    for (var item in _InfoCheckListModel!.where((e) =>
                        e.infoTypeName.toString() == subProcess &&
                        e.type != 'image'))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 15,
                              child: Text(item.infoDescription!,
                                  textAlign: TextAlign.left, softWrap: true),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            if (item.infoDescription == 'text')
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                    initialValue: item.value,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue), //<-- SEE HERE
                                      ),
                                      suffixText:
                                          (item.infoDescription != null &&
                                                  item.value!.isNotEmpty)
                                              ? item.value!
                                              : '',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        item.value = value;
                                        value = item.value = value;
                                      });
                                    }),
                              ),
                            Expanded(
                              flex: 2,
                              child: Text(""),
                            ),
                            Expanded(
                                flex: 0,
                                child: Checkbox(
                                  activeColor: Colors.white54,
                                  checkColor: Color.fromARGB(255, 251, 3, 3),
                                  value: item.value == '1' ? true : false,
                                  onChanged: isEdit!
                                      ? (value) {
                                          setState(() {
                                            item.value = value! ? '1' : '';
                                          });
                                        }
                                      : null,
                                ))
                          ],
                        ),
                      )
                  ])),
            )
        ],
      );
    } else if (processList!.isNotEmpty && _IssueCheckListModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in processList!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ExpandableTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subProcess.toString().toUpperCase(),
                        softWrap: true,
                      ),
                      Text("Y/N",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  body: Column(children: [
                    for (var item in _IssueCheckListModel!.where((e) =>
                        e.infoTypeName.toString() == subProcess &&
                        e.type != 'image'))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 15,
                              child: Text(item.infoDescription!,
                                  textAlign: TextAlign.left, softWrap: true),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 0,
                                child: Checkbox(
                                  activeColor: Colors.white54,
                                  checkColor: Color.fromARGB(255, 251, 3, 3),
                                  value: item.value == '1' ? true : false,
                                  onChanged: isEdit!
                                      ? (value) {
                                          setState(() {
                                            item.value = value! ? '1' : '';
                                          });
                                        }
                                      : null,
                                ))
                          ],
                        ),
                      )
                  ])),
            )
        ],
      );
    }*/

    else {
      widget = const Center(child: CircularProgressIndicator());
    }
    return widget;
  }

  getDeviceid(String source) {
    var deviceId;
    try {
      if (source == 'oms') {
        deviceId = modelData!.omsId;
      } else if (source == 'ams') {
        deviceId = modelData!.amsId;
      } else if (source == 'rms') {
        deviceId = modelData!.rmsId;
      } else if (source == 'lora') {
        deviceId = modelData!.gateWayId;
      } else {
        deviceId = '1';
      }
    } catch (_, ex) {
      deviceId = '1';
    }
    setState(() {
      deviceids = deviceId;
    });
    return deviceId;
  }

  Future<bool> damageCheckListData(List<SurveyInsertModel> _checkList) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int flagCounter = 0;
        if (widget.Source == 'oms') {
          respflag = await insertDamageReportCommon(
              _checkList, modelData!.omsId!, widget.Source!);
        } else if (widget.Source == 'ams') {
          respflag = await insertDamageReportCommon(
              _checkList, modelData!.amsId!, widget.Source!);
        } else if (widget.Source == 'rms') {
          respflag = await insertDamageReportCommon(
              _checkList, modelData!.rmsId!, widget.Source!);
        }
        // else if (widget.Source == 'lora') {
        //   respflag = await insertLoraDamageReport(_checkList, modelData!.omsId!, widget.Source!);
        // }

        if (respflag) {
          getECMData();
          setState(() {
            isSubmited = true;
          });
          flag = true;
        }
      }
    } catch (_, ex) {
      flag = false;
    }
    return flag;
  }

//image uploaded by damage
  Future<String?> uploadImage(String ImagePath, XFile? image) async {
    try {
      if (image == null || image.path.isEmpty) {
        debugPrint("Image is null or path is empty.");
        return '';
      }

      // Log the image path for debugging
      debugPrint("Uploading image from path: ${image.path}");

      // Create the multipart file
      var imgData = await http.MultipartFile.fromPath('Image', image.path);

      // Create the request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://wmsservices.seprojects.in/api/PMS?imgDirPath=$ImagePath&Api=2'),
      );

      request.files.add(imgData);

      // Log the request details
      debugPrint("Request prepared: $request");

      // Send the request
      http.StreamedResponse response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        debugPrint("Image uploaded successfully.");
        var path = await response.stream.bytesToString();
        if (path == '""') {
          debugPrint("Empty path returned by the server.");
          return '';
        } else {
          debugPrint("Server returned path: $path");
          return path.replaceAll('"', '');
        }
      } else {
        debugPrint(
            "Failed to upload image. Status code: ${response.statusCode}");
        return '';
      }
    } catch (e) {
      // Catch any errors and log them
      debugPrint("Error during image upload: $e");
      return '';
    }
  }

  /*Future<String?> uploadImage(String ImagePath, XFile? image) async {
    try {
      var imgData = await http.MultipartFile.fromPath('Image', image!.path);

      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://wmsservices.seprojects.in/api/PMS?imgDirPath=$ImagePath&Api=2'));

      request.files.add(imgData);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var path = await response.stream.bytesToString();
        if (path == '""') {
          return '';
        } else {
          return path.replaceAll('"', '');
        }
      } else {
        return '';
      }
    } catch (_, ex) {
      debugPrint("ERROR:${ex.toString()}");
    }
    return '';
  }
*/
//Damage form insert
  Future<bool> insertDamageReportCommon(
      List<SurveyInsertModel> imageList, int Id, String source) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      var projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      var proUserId = preferences.getInt('ProUserId');
      int omsId = getDeviceid(source);
      var imagePath = "$projectName/$source/$Id/";
      int countflag = 0;
      int uploadflag = 0;

      await Future.wait(imageList
          .where((element) =>
              element.inputType == 'Image' && element.image != null)
          .map((element) async {
        String? imagePathValue = await uploadImage(imagePath, element.image);

        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = imageList.map((e) => e.surveyId).toList().join(",");
      var valueData = imageList.map((e) => e.value ?? '').toList().join(",");
      var Insertobj = Map<String, dynamic>();
      if (source == 'oms') {
        Insertobj["omsid"] = Id;
      } else if (source == 'ams') {
        Insertobj["amsid"] = Id;
      } else if (source == 'rms') {
        Insertobj["rmsid"] = Id;
      } else if (source == 'lora') {
        Insertobj["gatewayid"] = Id;
      }
      Insertobj["userid"] = proUserId.toString();
      Insertobj["Damagedata"] = checkListId;
      Insertobj["Valuedata"] = valueData;
      Insertobj["conString"] = conString;
      Insertobj["status"] = "ok";
      Insertobj["remark"] = _remarkController!;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/OMS/InsertOmsSurveyReport'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);
        print(request.body);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            return true;
          } else {
            throw Exception();
          }
        } else {}
      } else {}
      throw Exception();
    } catch (_) {
      throw Exception();
    }
  }

/*
//image uploaded by information
  Future<String> uploadimages(String imagePath, XFile? image) async {
    try {
      var uri = Uri.parse(
          'http://wmsservices.seprojects.in/api/Information?imgDirPath=$imagePath&Api=2');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', image!.path))
        ..fields['fieldKey'] =
            'fieldValue'; // Add any additional fields if needed

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['data'] as String;
      } else {
        return "";
      }
    } catch (error) {
      return "";
    }
  }
*/
}

class InsertObjectModel {
  String? processId;
  String? subProcessId;
  String? checkListData;
  String? Id;
  String? userId;
  String? valuedata;
  String? Remark;
  String? TempDT;
  String? ApprovedStatus;
  String? Source;
  String? conString;
  bool? IsSiteTeamEngineerAvailable;
  String? SiteTeamEngineer;
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
      body: PhotoView(imageProvider: MemoryImage(bytearray!)),
    );
  }
}
