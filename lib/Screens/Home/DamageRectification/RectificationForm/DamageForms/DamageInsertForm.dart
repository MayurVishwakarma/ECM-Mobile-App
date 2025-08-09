// ignore_for_file: non_constant_identifier_names, must_be_immutable, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, unused_element, unused_field, prefer_typing_uninitialized_variables, prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, file_names, unnecessary_null_comparison, unused_local_variable, unused_catch_stack, prefer_collection_literals, use_build_context_synchronously, prefer_final_fields

import 'dart:convert';
import 'package:ecm_application/Model/Project/Damage/DamageCommanModel.dart';
import 'package:ecm_application/Model/Project/Damage/Information.dart';
import 'package:ecm_application/Model/Project/Damage/IssuesMasterModel.dart';
import 'package:ecm_application/Model/Project/Damage/MaterialConsumption.dart';
import 'package:ecm_application/Model/Project/Damage/OmsDamageModel.dart';
import 'package:ecm_application/Services/RestDamage.dart';
import 'package:ecm_application/Model/Common/EngineerModel.dart';
import 'package:ecm_application/Model/project/Constants.dart';
import 'package:ecm_application/Services/RestPmsService.dart';
import 'package:ecm_application/core/utils/Common_utils.dart';
import 'package:ecm_application/core/utils/ImageCommpress.dart';
import 'package:ecm_application/core/utils/locationProcessHelper.dart';
import 'package:ecm_application/core/utils/translate_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:ecm_application/Widget/ExpandableTiles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' hide context;

DamageModel? modelData;
List<DamageInsertModel>? _DisplayList = <DamageInsertModel>[];

EngineerNameModel? usernameData;
List<EngineerNameModel>? _UserList = <EngineerNameModel>[];

class DamageInsert extends StatefulWidget {
  String? ProjectName;
  String? Source;

  // ignore: use_key_in_widget_constructors
  DamageInsert(DamageModel? _modelData, String project, String source) {
    modelData = _modelData;
    ProjectName = project;
    Source = source;
  }
  @override
  _DamageInsertState createState() => _DamageInsertState();
}

class _DamageInsertState extends State<DamageInsert> {
  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    super.initState();
    setState(() {
      processList = Set();
      selectedProcess = 'Damage Form';
      _widget = const Center(child: CircularProgressIndicator());
    });
    getECMData(selectedProcess!);
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
  String? _siteEngineerTeamController;
  Widget? _widget;
  var selectedProcess;
  List<DamageInsertModel> imageList = [];
  List<DamageInsertModel>? _ChecklistModel;
  List<MaterialConsumptionModel>? _MaterialCheckListModel;
  List<InfoModel>? _InfoCheckListModel;
  List<InfoModel>? InfoImageList;
  List<DamageIssuesMasterModel>? _IssueCheckListModel;
  List<DamageIssuesMasterModel>? IssuesImageList = [];
  bool _isHindi = false;
  List<String> _originalDescriptions = [];
  List<String> _originalMaterialList = [];
  List<String> _originalInfoList = [];
  List<String> _originalIssueList = [];

  var listdistinctProcess = [
    "Damage Form",
    "Material Consumption",
    "Info",
    "Issues"
  ];

  Future getImage(ImageSource media, int index) async {
    try {
      final imgPicker = await picker.pickImage(source: media, imageQuality: 30);
      if (imgPicker == null) return;

      final byteData = await imgPicker.readAsBytes();
      final watermarkText = await getCurrentLocationImage();

      final watermarkedBytes = await compute(
        imageProcessingIsolate,
        ImageProcessingInput(byteData, watermarkText),
      );
      /* await compute(
        imageProcessingIsolate,
        ImageProcessingInput(byteData, watermarkText),
      );*/

      final tempDir = await getTemporaryDirectory();
      final watermarkedFile = File('${tempDir.path}/${imgPicker.name}');
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      final externalDir = await getExternalStorageDirectory();
      final fileName = basename(watermarkedFile.path);
      await imgPicker.saveTo('${externalDir!.path}/$fileName');

      setState(() {
        image = XFile(watermarkedFile.path);
        imageList[index].image = image;
        imageList[index].imageByteArray = watermarkedBytes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image Selected Successfully.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to Load Image'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future getImage1(ImageSource media, int index) async {
    var img = await picker.pickImage(source: media, imageQuality: 30);
    var byte = await img!.readAsBytes();
    setState(() {
      image = img;
      InfoImageList![index].image = img;
      InfoImageList![index].imageByteArray = byte;
    });
  }

  Future getImage2(ImageSource media, int index) async {
    var img = await picker.pickImage(source: media, imageQuality: 30);
    var byte = await img!.readAsBytes();
    setState(() {
      image = img;
      IssuesImageList![index].image = img;
      IssuesImageList![index].imageByteArray = byte;
    });
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

  Widget _buildInfoImageList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: InfoImageList!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildImageListItem1(index);
      },
    );
  }

  Widget _buildIssueImageList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: IssuesImageList!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildImageListItem2(index);
      },
    );
  }

  Widget _buildImageListItem(int index) {
    final imageItem = imageList[index];
    return ListTile(
      trailing: imageItem.imageByteArray != null
          ? InkWell(
              onTap: () => previewAlert(
                  imageItem.imageByteArray!, index, imageItem.damage),
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
          imageItem.damage!,
          style: TextStyle(color: Colors.green, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildImageListItem1(int index) {
    final imageItem = InfoImageList![index];
    return ListTile(
      trailing: imageItem.imageByteArray != null
          ? InkWell(
              onTap: () => previewAlert1(
                  imageItem.imageByteArray!, index, imageItem.infoDescription),
              child: Image.memory(
                imageItem.imageByteArray!,
                fit: BoxFit.fitWidth,
                width: 50,
                height: 50,
              ),
            )
          : GestureDetector(
              onTap: () {
                uploadAlert1(index);
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
          imageItem.infoDescription!,
          style: TextStyle(color: Colors.green, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildImageListItem2(int index) {
    final imageItem = IssuesImageList![index];
    return ListTile(
      trailing: imageItem.imageByteArray != null
          ? InkWell(
              onTap: () => previewAlert1(
                  imageItem.imageByteArray!, index, imageItem.infoDescription),
              child: Image.memory(
                imageItem.imageByteArray!,
                fit: BoxFit.fitWidth,
                width: 50,
                height: 50,
              ),
            )
          : GestureDetector(
              onTap: () {
                uploadAlert2(index);
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
          imageItem.infoDescription!,
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

  Future<void> imageListpopup1() async {
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
          content: Container(width: 500, child: _buildInfoImageList(context)),
        );
      },
    );
  }

  Future<void> imageListpopup2() async {
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
          content: Container(width: 500, child: _buildIssueImageList(context)),
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

  void previewAlert1(var photos, int index, var desc) {
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
                          InfoImageList![index].imageByteArray = imagebytearray;
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
                        getImage1(ImageSource.gallery, index);
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
                        getImage1(ImageSource.camera, index);
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

  void previewAlert2(var photos, int index, var desc) {
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
                          IssuesImageList![index].imageByteArray =
                              imagebytearray;
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
                        getImage1(ImageSource.gallery, index);
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
                        getImage1(ImageSource.camera, index);
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

  void uploadAlert1(int index) {
    if (isEdit!) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Please choose media to select'),
              content: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        Navigator.pop(context);
                        getImage1(ImageSource.gallery, index);
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
                        getImage1(ImageSource.camera, index);
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
  }

  void uploadAlert2(int index) {
    if (isEdit!) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Please choose media to select'),
              content: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        Navigator.pop(context);
                        getImage2(ImageSource.gallery, index);
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
                        getImage2(ImageSource.camera, index);
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
  }

  void uploadAlert(int index) {
    if (isEdit!) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
                  } else if (_MaterialCheckListModel!.isNotEmpty) {
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
                  }
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: listdistinctProcess.length,
      child: Scaffold(
          appBar: AppBar(
            title: Text(getAppbarName(widget.Source!)),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text('Edit:', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: isEdit ?? false,
                      onChanged: (value) {
                        setState(() {
                          isEdit = value;
                          buttonText = value ? 'Update' : 'Edit';
                        });
                      },
                      activeColor: Colors.blue.shade900,
                      inactiveThumbColor: Colors.red,
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () => _toggleTranslation(),
                  icon: Icon(Icons.translate)),
              // Switch(
              //   value: _isHindi,
              //   onChanged: (value) => _toggleTranslation(),
              // ),
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
                if (!(widget.ProjectName!.toLowerCase() == 'cluster-x') &&
                    !(widget.ProjectName!.toLowerCase() == 'cluster-xiii'))
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5.0)),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5.0)),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: listdistinctProcess
                          .map((e) => FittedBox(
                                child: Text(
                                  e.replaceAll(' ', '\n'),
                                  softWrap: true,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ))
                          .toList(),
                      onTap: (value) async {
                        setState(() {
                          _isHindi = false;
                          selectedProcess =
                              listdistinctProcess.elementAt(value);
                        });
                        getECMData(selectedProcess!);
                      },
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
                                                  element.type == 'Image' &&
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
                                              element.type == 'Image' &&
                                              element.value != null)
                                          .isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: SizedBox(
                                              child: Center(
                                                  child:
                                                      Text('Image Uploaded'))))
                                      : Center(
                                          child: Text(
                                            "No Image Uploaded",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          if (InfoImageList!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InfoImageList!
                                              .where((element) =>
                                                  element.type == 'image' &&
                                                  element.value != null)
                                              .isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                imageListpopup1();
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
                                                imageListpopup1();
                                              },
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/images/uploadimage.png'),
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              ))),
                                  InfoImageList!
                                          .where((element) =>
                                              // element.id == Id &&
                                              element.type == 'image' &&
                                              element.value != null)
                                          .isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: SizedBox(
                                              child: Center(
                                                  child:
                                                      Text('Image Uploaded'))))
                                      : Center(
                                          child: Text(
                                            "No Image Uploaded",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          if (IssuesImageList!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IssuesImageList!
                                              .where((element) =>
                                                  element.type == 'image' &&
                                                  element.value != null)
                                              .isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                imageListpopup2();
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
                                                imageListpopup2();
                                              },
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/images/uploadimage.png'),
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              ))),
                                  IssuesImageList!
                                          .where((element) =>
                                              // element.id == Id &&
                                              element.type == 'image' &&
                                              element.value != null)
                                          .isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: SizedBox(
                                              child: Center(
                                                  child:
                                                      Text('Image Uploaded'))))
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
                            child: Text("Submit"),
                            onPressed: () async {
                              if (buttonText == 'Update') {
                                _showAlert(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enable Edit first'),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),

                          if (remarkval.isNotEmpty)
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Container(
                                  width: double.infinity,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  fontWeight:
                                                      FontWeight.normal),
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
                                                  fontWeight:
                                                      FontWeight.normal),
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
          )),
    );
  }

  getECMData(String processname) {
    if (processname == "Issues") {
      _IssueCheckListModel = [];
      _ChecklistModel = [];
      _InfoCheckListModel = [];
      _MaterialCheckListModel = [];
      remarkval = '';
      IssuesImageList = [];
      InfoImageList = [];
      imageList = [];
      processList = Set();
      selectedProcess = Set();
      _originalDescriptions = [];
      _originalMaterialList = [];
      _originalInfoList = [];
      try {
        // if (widget.Source == 'oms') {
        Issues(modelData!.omsId!, widget.Source!).then((value) {
          setState(() {
            remarkval = value.first.remark ?? '';
            workedondate = (value.first.reportedOn ?? '').toString();
            getWorkedByNAme((value.first.reportedBy ?? '').toString());
            _IssueCheckListModel = value;
            for (var element in _IssueCheckListModel!) {
              processList!.add(element.infoTypeName ?? 'ISSUE');
            }
            _originalIssueList =
                value.map((item) => item.infoDescription ?? '').toList();
            IssuesImageList!
                .addAll(value.where((element) => element.type == 'image'));
            selectedProcess = "Issue";
          });
        });
        /*} else if (widget.Source == 'ams') {
          Issues(modelData!.amsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _IssueCheckListModel = value;
              for (var element in _IssueCheckListModel!) {
                processList!.add(element.infoTypeName ?? 'Issues');
              }
              IssuesImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Issues";
            });
          });
        } else if (widget.Source == 'rms') {
          Issues(modelData!.rmsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _IssueCheckListModel = value;
              for (var element in _IssueCheckListModel!) {
                processList!.add(element.infoTypeName ?? 'ISSUE');
              }
              IssuesImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Issues";
            });
          });
        } else if (widget.Source == 'lora') {
          Issues(modelData!.gateWayId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _IssueCheckListModel = value;
              for (var element in _IssueCheckListModel!) {
                processList!.add(element.infoTypeName ?? 'ISSUE');
              }
              IssuesImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Issues";
            });
          });
        }*/
        getECMData(selectedProcess);
      } catch (_, ex) {
        print(ex);
      }
    } else if (processname == "Info") {
      _InfoCheckListModel = [];
      _MaterialCheckListModel = [];
      _IssueCheckListModel = [];
      InfoImageList = [];
      IssuesImageList = [];
      imageList = [];
      processList = Set();
      selectedProcess = Set();
      _originalDescriptions = [];
      _originalMaterialList = [];
      _originalIssueList = [];
      try {
        // if (widget.Source == 'oms') {
        Infomation(modelData!.omsId!, widget.Source!.toUpperCase())
            .then((value) {
          setState(() {
            remarkval = value.first.remark ?? '';
            workedondate = (value.first.reportedOn ?? '').toString();
            getWorkedByNAme((value.first.reportedBy ?? '').toString());
            _InfoCheckListModel = value;
            InfoImageList!
                .addAll(value.where((element) => element.type == 'image'));
            for (var element in _InfoCheckListModel!) {
              processList!.add(element.infoTypeName ?? 'INFORMATION');
            }
            _originalInfoList =
                value.map((item) => item.infoDescription ?? '').toList();
            selectedProcess = "Info";
          });
        });
        /* } else if (widget.Source == 'ams') {
          Infomation(modelData!.amsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName ?? 'INFORMATION');
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        } else if (widget.Source == 'rms') {
          Infomation(modelData!.rmsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName ?? "INFORMATION");
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        } else if (widget.Source == 'lora') {
          Infomation(modelData!.gateWayId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName ?? "INFORMATION");
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        }*/
        getECMData(selectedProcess!);
      } catch (_) {} /*_InfoCheckListModel = [];
      remarkval = '';
      InfoImageList = [];
      processList = Set();
      selectedProcess = Set();
      try {
        if (widget.Source == 'oms') {
          Infomation(modelData!.omsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName!);
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        } else if (widget.Source == 'ams') {
          Infomation(modelData!.amsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName!);
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        } else if (widget.Source == 'rms') {
          Infomation(modelData!.rmsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _InfoCheckListModel = value;
              for (var element in _InfoCheckListModel!) {
                processList!.add(element.infoTypeName!);
              }
              InfoImageList!
                  .addAll(value.where((element) => element.type == 'image'));
              selectedProcess = "Info";
            });
          });
        }
        getECMData(selectedProcess!);
      } catch (_) {}*/
    } else if (processname == "Material Consumption") {
      _MaterialCheckListModel = [];
      _ChecklistModel = [];
      _InfoCheckListModel = [];
      _IssueCheckListModel = [];
      IssuesImageList = [];
      imageList = [];
      InfoImageList = [];
      remarkval = '';
      processList = Set();
      selectedProcess = Set();
      _originalDescriptions = [];
      _originalInfoList = [];
      _originalInfoList = [];
      try {
        // if (widget.Source == 'oms') {
        getDamageformCommon(modelData!.omsId!, widget.Source!).then((value) {
          setState(() {
            remarkval = value.first.remark ?? '';
            workedondate = (value.first.reportedOn ?? '').toString();
            getWorkedByNAme((value.first.reportedBy ?? '').toString());
            _MaterialCheckListModel = value;
            for (var element in _MaterialCheckListModel!) {
              processList!.add(element.type!);
            }
            _originalMaterialList =
                value.map((item) => item.rectification ?? '').toList();
          });
          selectedProcess = "Material Consumption";
        });
        /*} else if (widget.Source == 'ams') {
          getDamageformCommon(modelData!.amsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _MaterialCheckListModel = value;
              for (var element in _MaterialCheckListModel!) {
                processList!.add(element.type!);
              }
            });
            selectedProcess = "Material Consumption";
          });
        } else if (widget.Source == 'rms') {
          getDamageformCommon(modelData!.rmsId!, widget.Source!).then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _MaterialCheckListModel = value;
              for (var element in _MaterialCheckListModel!) {
                processList!.add(element.type!);
              }
            });
            selectedProcess = "Material Consumption";
          });
        } else if (widget.Source == 'lora') {
          getDamageformCommon(modelData!.gateWayId!, widget.Source!)
              .then((value) {
            setState(() {
              remarkval = value.first.remark ?? '';
              workedondate = (value.first.reportedOn ?? '').toString();
              getWorkedByNAme((value.first.reportedBy ?? '').toString());
              _MaterialCheckListModel = value;
              for (var element in _MaterialCheckListModel!) {
                processList!.add(element.type!);
              }
            });
            selectedProcess = "Material Consumption";
          });
        }*/
        getECMData(selectedProcess!);
      } catch (_) {}
    } else {
      _ChecklistModel = [];
      _InfoCheckListModel = [];
      _MaterialCheckListModel = [];
      _IssueCheckListModel = [];
      imageList = [];
      InfoImageList = [];
      IssuesImageList = [];
      remarkval = '';
      selectedProcess = Set();
      _originalInfoList = [];
      _originalMaterialList = [];
      _originalInfoList = [];
      try {
        // if (widget.Source == 'oms') {
        getDamageform(modelData!.omsId!, widget.Source?.toUpperCase())
            .then((value) async {
          setState(() {
            remarkval = value.first.remark ?? '';
            workedondate = (value.first.datetime ?? '').toString();
            getWorkedByNAme((value.first.userId ?? '').toString());
            _ChecklistModel = value;
            imageList.addAll(value.where((element) => element.type == 'Image'));
            _originalDescriptions =
                value.map((item) => item.damage ?? '').toList();
            for (var element in _ChecklistModel!) {
              processList!.add(element.type!);
            }
          });
          selectedProcess = "Damage Form";
        });
        /*} else if (widget.Source == 'ams') {
          getDamageform(modelData!.amsId!, "AMS").then((value) {
            setState(() {
              remarkval = value.first.remark ?? "";
              workedondate = (value.first.datetime ?? '').toString();
              getWorkedByNAme((value.first.userId ?? '').toString());
              _ChecklistModel = value;
              imageList.addAll(value.where((element) =>
                      element.type ==
                      'Image' /*&&
                  element.amsId == modelData!.amsId*/
                  ));
              for (var element in _ChecklistModel!) {
                processList!.add(element.type!);
              }
              selectedProcess = "Damage Form";
            });
          });
        } else if (widget.Source == 'rms') {
          getDamageform(modelData!.rmsId!, 'RMS').then((value) {
            setState(() {
              remarkval = value.first.remark ?? "";
              workedondate = (value.first.datetime ?? '').toString();
              getWorkedByNAme((value.first.userId ?? '').toString());
              _ChecklistModel = value;
              imageList
                  .addAll(value.where((element) => element.type == 'Image'));
              for (var element in _ChecklistModel!) {
                processList!.add(element.type!);
              }
            });
            selectedProcess = "Damage Form";
          });
        } else if (widget.Source == 'lora') {
          getDamageform(modelData!.gateWayId!, 'LORA').then((value) {
            setState(() {
              remarkval = value.first.remark ?? "";
              workedondate = (value.first.datetime ?? '').toString();
              getWorkedByNAme((value.first.userId ?? '').toString());
              _ChecklistModel = value;
              imageList.addAll(value.where((element) =>
                      element.type ==
                      'Image' /*&&
                  element.gatewayId == modelData!.gateWayId!*/
                  ));
              for (var element in _ChecklistModel!) {
                processList!.add(element.type!);
              }
            });
            selectedProcess = "Damage Form";
          });
        }*/

        getECMData(selectedProcess!);
      } catch (_) {}
    }
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
      String? projectId = preferences.getString('ProjectId');
      final res = await http.get(Uri.parse(
          'http://ecmtest.iotwater.in:3011/api/v1/project/users/0/$userid/$projectId'));
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response'][0]);
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
  bool? isEdit = false;

  Future<void> _toggleTranslation() async {
    setState(() {
      _isHindi = !_isHindi;
    });

    if (_isHindi) {
      if (_ChecklistModel != null) {
        _ChecklistModel = await Future.wait(_ChecklistModel!.map((e) async {
          e.damage = await TranslationHelper.translateToHindi(e.damage ?? '');
          return e;
        }));
      }

      if (_MaterialCheckListModel != null) {
        _MaterialCheckListModel =
            await Future.wait(_MaterialCheckListModel!.map((e) async {
          e.rectification =
              await TranslationHelper.translateToHindi(e.rectification ?? '');
          return e;
        }));
      }

      if (_InfoCheckListModel != null) {
        _InfoCheckListModel =
            await Future.wait(_InfoCheckListModel!.map((e) async {
          e.infoDescription =
              await TranslationHelper.translateToHindi(e.infoDescription ?? '');
          return e;
        }));
      }

      if (_IssueCheckListModel != null) {
        _IssueCheckListModel =
            await Future.wait(_IssueCheckListModel!.map((e) async {
          e.infoDescription =
              await TranslationHelper.translateToHindi(e.infoDescription ?? '');
          return e;
        }));
      }
    } else {
      // Revert to originals
      if (_originalDescriptions != null) {
        for (int i = 0; i < _originalDescriptions.length; i++) {
          _ChecklistModel![i].damage = _originalDescriptions[i];
        }
      }
      if (_originalMaterialList != null) {
        for (int i = 0; i < _originalMaterialList.length; i++) {
          _MaterialCheckListModel![i].rectification = _originalMaterialList[i];
        }
      }
      if (_originalInfoList != null) {
        for (int i = 0; i < _originalInfoList.length; i++) {
          _InfoCheckListModel![i].infoDescription = _originalInfoList[i];
        }
      }
      if (_originalIssueList != null) {
        for (int i = 0; i < _originalIssueList.length; i++) {
          _IssueCheckListModel![i].infoDescription = _originalIssueList[i];
        }
      }
    }

    setState(() {});
  }

  Widget getDamageFeed() {
    if (processList == null || processList!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ChecklistModel?.isNotEmpty ?? false) {
      return _buildExpandableSection(
        titleLabel: "Damage",
        processes: ["Electrical", "Mechanical"],
        items: _ChecklistModel!,
        rowBuilder: (item) => _buildDamageRow(item),
      );
    }

    if (_MaterialCheckListModel?.isNotEmpty ?? false) {
      return _buildExpandableSection(
        titleLabel: "Qty",
        processes: ["Electrical", "Mechanical", "Tubing"],
        items: _MaterialCheckListModel!,
        rowBuilder: (item) => _buildMaterialRow(item),
      );
    }

    if (_InfoCheckListModel?.isNotEmpty ?? false) {
      return _buildExpandableSection(
        titleLabel: "Is Available",
        processes: processList!.toList(),
        items: _InfoCheckListModel!,
        rowBuilder: (item) => _buildInfoRow(item),
      );
    }

    if (_IssueCheckListModel?.isNotEmpty ?? false) {
      return _buildExpandableSection(
        titleLabel: "Y/N",
        processes: processList!.toList(),
        items: _IssueCheckListModel!,
        rowBuilder: (item) => _buildIssueRow(item),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildExpandableSection<T>({
    required String titleLabel,
    required List<String> processes,
    required List<T> items,
    required Widget Function(T item) rowBuilder,
  }) {
    return Column(
      children: [
        for (var subProcess in processList!)
          if (processes.contains(subProcess))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ExpandableTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subProcess.toUpperCase(), softWrap: true),
                    Text(titleLabel, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                body: Column(
                  children: [
                    for (var item in items.where((e) {
                      final type = (e as dynamic).type?.toString() ?? '';
                      return type == subProcess && type != 'image';
                    }))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: rowBuilder(item),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

// =============== Row Builders =================

  Widget _buildDamageRow(dynamic item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.damage ?? ''),
              if (_isHindi)
                Text(
                  "(${_originalDescriptions[_ChecklistModel!.indexOf(item)]})",
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        item.damage?.contains('Firmware') ?? false
            ? Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: item.value,
                  enabled: true, // always enable, but control via handler
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                  onChanged: (val) {
                    _handleValueChange(() {
                      setState(() => item.value = val);
                    });
                  },
                ),
              )
            : Expanded(
                flex: 0,
                child: Checkbox(
                  activeColor: Colors.white54,
                  checkColor: const Color.fromARGB(255, 251, 3, 3),
                  value: item.value == '1',
                  onChanged: (_) {
                    _handleValueChange(() {
                      setState(() => item.value = _! ? '1' : '');
                    });
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildMaterialRow(dynamic item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.rectification ?? ''),
              if (_isHindi)
                Text(
                    "(${_originalMaterialList[_MaterialCheckListModel!.indexOf(item)]})"),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: item.value,
              enabled: isEdit, // always enable, but control via handler
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              onChanged: (val) {
                _handleValueChange(() {
                  setState(() => item.value = val);
                });
              },
            )),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildInfoRow(dynamic item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 15, child: Text(item.infoDescription ?? '')),
        const SizedBox(width: 10),
        if (item.infoDescription == 'text')
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: item.value,
              enabled: true, // always enable, but control via handler
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              onChanged: (val) {
                _handleValueChange(() {
                  setState(() => item.value = val);
                });
              },
            ),
          ),
        const Spacer(flex: 2),
        Expanded(
          flex: 0,
          child: Checkbox(
            activeColor: Colors.white54,
            checkColor: const Color.fromARGB(255, 251, 3, 3),
            value: item.value == '1',
            onChanged: (_) {
              _handleValueChange(() {
                setState(() => item.value = _! ? '1' : '');
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIssueRow(dynamic item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 15, child: Text(item.infoDescription ?? '')),
        const SizedBox(width: 10),
        Expanded(
            flex: 0,
            child: Checkbox(
              activeColor: Colors.white54,
              checkColor: const Color.fromARGB(255, 251, 3, 3),
              value: item.value == '1',
              onChanged: (_) {
                _handleValueChange(() {
                  setState(() => item.value = _! ? '1' : '');
                });
              },
            )),
      ],
    );
  }

  void _showEditWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade400,
        content: const Text(
          'Please enable Edit first',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }

  void _handleValueChange(VoidCallback onEditAllowed) {
    if (isEdit!) {
      onEditAllowed();
    } else {
      _showEditWarning();
    }
  }

  /*
  getDamageFeed() {
    Widget? widget = const Center(child: CircularProgressIndicator());
    if (processList!.isNotEmpty && _ChecklistModel!.isNotEmpty) {
      widget = Column(
        children: [
          for (var subProcess in processList!)
            if (subProcess == "Electrical" || subProcess == "Mechanical")
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
                        Text("Damage",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            )),
                      ],
                    ),
                    body: Column(children: [
                      for (var item in _ChecklistModel!.where((e) =>
                          e.type.toString() == subProcess && e.type != 'Image'))
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item.damage!,
                                        textAlign: TextAlign.left,
                                        softWrap: true),
                                    if (_isHindi)
                                      Text(
                                          "(${_originalDescriptions[_ChecklistModel!.indexOf(item)]})",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 12),
                                          softWrap: true),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              if (item.damage!.contains('Firmware'))
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: item.value,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            // inline-size: 1,
                                            color: Colors.blue), //<-- SEE HERE
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        item.value = value;
                                        value = item.value = value;
                                      });
                                    },
                                  ),
                                ),
                              if (!item.damage!.contains('Firmware'))
                                Expanded(
                                    flex: 0,
                                    child: Checkbox(
                                      activeColor: Colors.white54,
                                      checkColor:
                                          Color.fromARGB(255, 251, 3, 3),
                                      value: item.value == '1' ? true : false,
                                      onChanged: isEdit!
                                          ? (value) {
                                              setState(() {
                                                item.value = value! ? '1' : '';
                                              });
                                            }
                                          : (value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.red.shade400,
                                                  content: Text(
                                                    'Please enable Edit first',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      left: 10,
                                                      right: 10),
                                                ),
                                              );
                                            },
                                    ))
                            ],
                          ),
                        )
                    ])),
              )
        ],
      );
    } else if (processList!.isNotEmpty && _MaterialCheckListModel!.isNotEmpty) {
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item.rectification!,
                                        textAlign: TextAlign.left,
                                        softWrap: true),
                                    if (_isHindi)
                                      Text(
                                          "(${_originalMaterialList[_MaterialCheckListModel!.indexOf(item)]})")
                                  ],
                                ),
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
                        (e.infoTypeName ?? 'INFORMATION').toString() ==
                            subProcess &&
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
                        (e.infoTypeName ?? 'Issues').toString() == subProcess &&
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
    } else {
      widget = const Center(child: CircularProgressIndicator());
    }
    return widget;
  }
*/
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

  Future<bool> damageCheckListDataForIssues(
      List<DamageIssuesMasterModel> _checkList, String _Controller) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int flagCounter = 0;
        if (widget.Source == 'oms') {
          respflag = await insertIssues(
              _checkList, _Controller, modelData!.omsId!, widget.Source!);
        } else if (widget.Source?.toLowerCase() == 'ams') {
          respflag = await insertIssues(
              _checkList, _Controller, modelData!.amsId!, widget.Source!);
        } else if (widget.Source == 'rms') {
          respflag = await insertIssues(
              _checkList, _Controller, modelData!.rmsId!, widget.Source!);
        }

        if (respflag) {
          getECMData(selectedProcess!);
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

  Future<bool> damageCheckListDataForInfotmtion(
      List<InfoModel> _checkList, String _Controller) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int flagCounter = 0;
        if (widget.Source == 'oms') {
          respflag = await insertInformation(
              _checkList, _Controller, modelData!.omsId!, widget.Source!);
        } else if (widget.Source == 'ams') {
          respflag = await insertInformation(
              _checkList, _Controller, modelData!.amsId!, widget.Source!);
        } else if (widget.Source == 'rms') {
          respflag = await insertInformation(
              _checkList, _Controller, modelData!.rmsId!, widget.Source!);
        }

        if (respflag) {
          getECMData(selectedProcess!);
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

  Future<bool> damageCheckListDataForMaterial(
      List<MaterialConsumptionModel> _checkList, String _Controller) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int flagCounter = 0;
        if (widget.Source == 'oms') {
          respflag = await insertRectifyCommon(
              _checkList, _Controller, modelData!.omsId!, widget.Source!);
        } else if (widget.Source == 'ams') {
          respflag = await insertRectifyCommon(
              _checkList, _Controller, modelData!.amsId!, widget.Source!);
        } else if (widget.Source == 'rms') {
          respflag = await insertRectifyCommon(
              _checkList, _Controller, modelData!.rmsId!, widget.Source!);
        } else if (widget.Source == 'lora') {
          respflag = await insertRectifyCommon(
              _checkList, _Controller, modelData!.gateWayId!, widget.Source!);
        }

        if (respflag) {
          getECMData(selectedProcess!);
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

  Future<bool> damageCheckListData(List<DamageInsertModel> _checkList) async {
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
        } else if (widget.Source == 'lora') {
          respflag = await insertDamageReportCommon(
              _checkList, modelData!.gateWayId!, widget.Source!);
        }
        if (respflag) {
          getECMData(selectedProcess!);
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

/*
//image uploaded by damage
  Future<String?> uploadImage(String ImagePath, XFile? image) async {
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
    } catch (_) {}
    return '';
  }
*/
//Damage form insert
  Future<bool> insertDamageReportCommon(
      List<DamageInsertModel> imageList, int Id, String source) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? projectId = preferences.getString('ProjectId');
      var projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      var proUserId = preferences.getInt('ProUserId');
      int omsId = getDeviceid(source);
      var imagePath = "$projectName/$source/$Id/";
      int countflag = 0;
      int uploadflag = 0;
      await Future.wait(imageList
          .where((element) => element.type == 'Image' && element.image != null)
          .map((element) async {
        String? imagePathValue = await uploadImageAndGetPath(
            element.image!.path, widget.Source!.toUpperCase(), deviceids);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = imageList.map((e) => e.id).toList().join(",");
      var valueData = imageList.map((e) => e.value ?? '').toList().join(",");

      var data = json.encode({
        "userid": proUserId.toString(),
        "deviceId": Id,
        "Checklistid": checkListId,
        "values": valueData,
        "deviceType": source.toUpperCase(),
        "remark": _remarkController,
        "projectId": projectId
      });

      if (countflag == uploadflag) {
        var result = await uploadDamageReport(data);
        return result;
      } else {
        return false;
      }
      /*String? url;
      if (source == 'oms') {
        url = 'http://wmsservices.seprojects.in/api/OMS/InsertOmsDamageReport';
      } else if (source == 'ams') {
        url = 'http://wmsservices.seprojects.in/api/AMS/InsertAmsDamageReport';
      } else if (source == 'rms') {
        url = 'http://wmsservices.seprojects.in/api/RMS/InsertRmsDamageReport';
      } else if (source == 'lora') {
        url =
            'http://wmsservices.seprojects.in/api/LoRa/InsertLoRaDamageReport';
      }

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request("POST", Uri.parse(url ?? ''));
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
      } else {}*/
    } catch (_) {
      throw Exception();
    }
  }

//Material insertion
  Future<bool> insertRectifyCommon(List<MaterialConsumptionModel> checklist,
      String Remark, int Id, String source) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      int proUserId = preferences.getInt('ProUserId')!;
      String? projectId = preferences.getString('ProjectId');
      int countflag = 0;
      int uploadflag = 0;

      var checkListId = checklist.map((e) => e.id).toList().join(",");
      var valueData = checklist.map((e) => e.value ?? '').toList().join(",");

      var data = json.encode({
        "deviceId": Id,
        "Checklistid": checkListId,
        "values": valueData,
        "userid": proUserId.toString(),
        "remark": _remarkController,
        "deviceType": source.toUpperCase(),
        "projectId": projectId
      });

      if (countflag == uploadflag) {
        var result = await uploadMaterialConsumptionReport(data);
        return result;
      } else {
        return false;
      }
      /*var Insertobj = Map<String, dynamic>();

      Insertobj["id"] = Id;
      Insertobj["rectifydata"] = checkListId;
      Insertobj["valuedata"] = valueData;
      Insertobj["reportedby"] = proUserId.toString();
      Insertobj["remark"] = Remark;
      Insertobj["source"] = source;
      Insertobj["conString"] = conString;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/Rectify/InsertRectifyReport'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            return true;
          } else {
            throw Exception();
          }
        } else {}
      } else {}*/
    } catch (_) {
      throw Exception();
    }
  }

//information Insert
  Future<bool> insertInformation(
      List<InfoModel> checklist, String remark, int id, String source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conString = prefs.getString('ConString');
      final proUserId = prefs.getInt('ProUserId')!;
      final projectName = prefs.getString('ProjectName')!;
      String? projectId = prefs.getString('ProjectId');
      final imagePathPrefix = "$projectName/$source/$id/";

      int uploadCount = 0;

      // Upload images and update checklist values
      final imageItems =
          checklist.where((e) => e.type == 'image' && e.image != null).toList();
      await Future.wait(imageItems.map((item) async {
        final uploadedPath = await uploadImageAndGetPath(
          item.image!.path,
          source.toUpperCase(),
          id,
        );
        if (uploadedPath?.isNotEmpty == true) {
          item.value = uploadedPath;
          uploadCount++;
        }
      }));

      if (uploadCount != imageItems.length) {
        throw Exception(
            "Image upload mismatch: $uploadCount/${imageItems.length}");
      }

      final checkListId = checklist.map((e) => e.id).join(",");
      final valueData = checklist.map((e) => e.value ?? '').join(",");
//  deviceId, Checklistid, values, userid, deviceType, remark, infoType, projectId
      var data = json.encode({
        "deviceId": id,
        "Checklistid": checkListId,
        "values": valueData,
        "userid": proUserId.toString(),
        "deviceType": source.toUpperCase(),
        "remark": _remarkController,
        "infoType": 1,
        "projectId": projectId
      });

      var result = await uploadInfromationReport(data);
      return result;

      /*final payload = {
        "DeviceId": id,
        "infodata": checkListId,
        "Valuedata": valueData,
        "ReportedBy": proUserId,
        "Source": source,
        "Remark": remark,
        "InfoTypeId": 1,
        "conString": conString,
      };

      final response = await http.post(
        Uri.parse(
            'http://wmsservices.seprojects.in/api/infoReport/InsertInfoReport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result["Status"] == "Ok";
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }*/
    } catch (e) {
      debugPrint("Insert info error: $e");
      return false;
    }
  }

  /* Future<bool> insertInformation(
      List<InfoModel> checklist, String Remark, int Id, String source) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      int proUserId = preferences.getInt('ProUserId')!;
      String? projectName = preferences.getString('ProjectName')!;
      var imagePath = "$projectName/$source/$Id/";
      int countflag = 0;
      int uploadflag = 0;
      await Future.wait(checklist
          .where((element) => element.type == 'image' && element.image != null)
          .map((element) async {
        String? imagePathValue = await uploadImageAndGetPath(
            element.image!.path, widget.Source!.toUpperCase(), deviceids);
        // String? imagePathValue = await uploadimages(imagePath, element.image);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = checklist.map((e) => e.id).toList().join(",");
      var valueData = checklist.map((e) => e.value ?? '').toList().join(",");
      var Insertobj = Map<String, dynamic>();
      Insertobj["DeviceId"] = Id;
      Insertobj["infodata"] = checkListId;
      Insertobj["Valuedata"] = valueData;
      Insertobj["ReportedBy"] = proUserId;
      Insertobj["Source"] = source;
      Insertobj["Remark"] = Remark;
      Insertobj["InfoTypeId"] = 1;
      Insertobj["conString"] = conString;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/infoReport/InsertInfoReport'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);
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
*/
  Future<bool> insertIssues(List<DamageIssuesMasterModel> checklist,
      String Remark, int id, String source) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      int proUserId = preferences.getInt('ProUserId')!;
      String? projectName = preferences.getString('ProjectName')!;
      String? projectId = preferences.getString('ProjectId');
      var imagePath = "$projectName/$source/$id/";
      int countflag = 0;
      int uploadflag = 0;
      int uploadCount = 0;

      // Upload images and update checklist values
      final imageItems =
          checklist.where((e) => e.type == 'image' && e.image != null).toList();
      await Future.wait(imageItems.map((item) async {
        final uploadedPath = await uploadImageAndGetPath(
          item.image!.path,
          source.toUpperCase(),
          id,
        );
        if (uploadedPath?.isNotEmpty == true) {
          item.value = uploadedPath;
          uploadCount++;
        }
      }));

      if (uploadCount != imageItems.length) {
        throw Exception(
            "Image upload mismatch: $uploadCount/${imageItems.length}");
      }

      var checkListId = checklist.map((e) => e.id).toList().join(",");
      var valueData = checklist.map((e) => e.value ?? '').toList().join(",");

      var data = json.encode({
        "deviceId": id,
        "Checklistid": checkListId,
        "values": valueData,
        "userid": proUserId.toString(),
        "deviceType": source.toUpperCase(),
        "remark": _remarkController,
        "infoType": 2,
        "projectId": projectId
      });
      if (countflag == uploadflag) {
        var result = await uploadInfromationReport(data);
        return result;
      } else {
        return false;
      }
      /* var Insertobj = Map<String, dynamic>();

      // api/Information?imgDirPath={imgDirPath}&Api={Api}

      Insertobj["DeviceId"] = id;
      Insertobj["infodata"] = checkListId;
      Insertobj["Valuedata"] = valueData;
      Insertobj["ReportedBy"] = proUserId;
      Insertobj["Source"] = source;
      Insertobj["Remark"] = Remark;
      Insertobj["InfoTypeId"] = 2;
      Insertobj["conString"] = conString;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/infoReport/InsertInfoReport'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            return true;
          } else {
            throw Exception();
          }
        } else {}
      } else {}*/
    } catch (e) {
      print('Issue Insert Error:$e');
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
