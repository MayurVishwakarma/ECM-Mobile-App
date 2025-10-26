// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, sort_child_properties_last, unused_element, prefer_typing_uninitialized_variables, unused_field, non_constant_identifier_names, prefer_const_literals_to_create_immutables, prefer_collection_literals, duplicate_ignore, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, unnecessary_null_in_if_null_operators, must_be_immutable, avoid_function_literals_in_foreach_calls, unused_local_variable, empty_catches, unnecessary_new, curly_braces_in_flow_control_structures, use_build_context_synchronously, file_names, library_private_types_in_public_api, unused_catch_stack, unnecessary_null_comparison, unrelated_type_equality_checks, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Screens/Home/ECM-History/Ecm-HistoryPage.dart';
import 'package:ecm_application/core/SQLite/DbHepherSQL.dart';
import 'package:ecm_application/core/utils/Common_utils.dart';
import 'package:ecm_application/core/utils/ImageCommpress.dart';
import 'package:ecm_application/core/utils/ImagePriviewWidget.dart';
import 'package:ecm_application/core/utils/locationProcessHelper.dart';
import 'package:ecm_application/core/utils/translate_helper.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ecm_application/Model/Common/EngineerModel.dart';
import 'package:ecm_application/Model/project/Constants.dart';
import 'package:flutter/foundation.dart';
import 'package:ecm_application/Model/Project/ECMTool/ECM_Checklist_Model.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSListViewModel.dart';
import 'package:ecm_application/Services/RestPmsService.dart';
import 'package:ecm_application/Widget/ExpandableTiles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ecm_application/core/utils/ImageProcessHelper.dart';

PMSListViewModel? modelData;
List<PMSListViewModel>? _DisplayList = <PMSListViewModel>[];
EngineerNameModel? usernameData;
List<EngineerNameModel>? _UserList = <EngineerNameModel>[];

class NodeDetails extends StatefulWidget {
  String? ProjectName;
  String? Source;
  PMSListViewModel? viewdata;
  int? listdatas;

  NodeDetails(PMSListViewModel? _modelData, String project, String source,
      this.viewdata, this.listdatas) {
    modelData = _modelData ?? null;
    ProjectName = project;
    Source = source;
  }

  @override
  _NodeDetailsState createState() => _NodeDetailsState();
}

class _NodeDetailsState extends State<NodeDetails> {
  bool _isConnected = false;
  StreamSubscription<InternetStatus>? _connectivitySubscription;
  String? conString;
  var Source;
  String subProcessId = "";
  var approved;
  var deviceids;
  var psId;
  // var subProcessname = '';
  var workedondate = '';
  var workdoneby = '';
  var remarkval = '';
  var siteTeamMember = '';
  var approvedon = '';
  var approvedremark = '';
  var approvedby = '';
  var userType = '';
  var userName = '';
  var approvedStatus;
  // DateTime? currDate;
  bool sendData = false;
  Widget? _widget;
  FToast? fToast;
  String? selectedProcess;
  int? processId;
  List<ECM_Checklist_Model>? imageList = [];
  List<ECM_Checklist_Model>? _ChecklistModel;
  List<ECM_Checklist_Model>? listProcess;
  Set<String>? subProcessName;
  Set<String>? listdistinctProcess;
  List<int> isCheckedList = List.generate(6, (_) => 0);
  var approvedId;
  List<ECM_Checklist_Model>? newdata;
  XFile? image;
  bool? isFetchingData = true;
  bool? isSubmited = false;
  bool? hasData = false;
  final ImagePicker picker = ImagePicker();
  Uint8List? imagebytearray;
  String? _remarkController;
  String? _siteEngineerTeamController = '';
  bool? issiteEngAvailable = false;
  List<PMSChaklistModel> listdistinctProcesss = [];
  List<ECM_Checklist_Model> datasoff = [];
  List<PMSListViewModel>? Listdata = [];
  List<PMSListViewModel>? alllistItem = [];
  List<ECM_Checklist_Model> datas = [];
  List<ECM_Checklist_Model>? Addchecklist = [];
  bool isLoading = false;
  String? pdfString;
  bool _isHindi = false;
  List<String> _originalDescriptions = [];
  List<String> _originalSubProcess = [];
  List<String> _subprocessList = [];
  // Controllers for inputs
  final TextEditingController _remarkoffController = TextEditingController();
  final TextEditingController _siteEngineerTeamOffController =
      TextEditingController();

  @override
  void initState() {
    fToast = FToast();
    fToast!.init(context);
    super.initState();
    setState(() {
      listProcess = [];
      listdistinctProcess = Set();
      subProcessName = Set();
      selectedProcess = '';
      _widget = const Center(child: CircularProgressIndicator());
    });
    firstLoad();
    getDeviceid(widget.Source!);
    getUserType();
    _initConnectivity();
    _connectivitySubscription =
        InternetConnection().onStatusChange.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    InternetStatus status =
        (InternetConnection().onStatusChange) as InternetStatus;
    _updateConnectionStatus(status);
  }

  void _updateConnectionStatus(InternetStatus status) {
    setState(() {
      _isConnected = status == InternetStatus.connected;
    });
  }

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

      storeImagesInSharedPref(
        watermarkedFile.path,
        imageList![index].checkListId.toString(),
      );

      setState(() {
        image = XFile(watermarkedFile.path);
        imageList![index].image = image;
        imageList![index].imageByteArray = watermarkedBytes;
      });
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

/*
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

      final tempDir = await getTemporaryDirectory();
      final watermarkedFile = File('${tempDir.path}/${imgPicker.name}');
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      final externalDir = await getExternalStorageDirectory();
      final fileName = basename(watermarkedFile.path);
      await imgPicker.saveTo('${externalDir!.path}/$fileName');

      storeImagesInSharedPref(
        watermarkedFile.path,
        imageList![index].checkListId.toString(),
      );

      setState(() {
        image = XFile(watermarkedFile.path);
        imageList![index].image = image;
        imageList![index].imageByteArray = watermarkedBytes;
      });
    } catch (e) {
      debugPrint('Error in getImage: $e');
      Fluttertoast.showToast(msg: "Failed to process image.");
    }
  }
*/
  //we can upload image from camera or from gallery based on parameter
  Future getPdf(ECM_Checklist_Model model) async {
    var pdf = await picker.pickMedia();
    var imageselected = File(pdf!.path);
    var byte = await pdf.readAsBytes();
    await storeImagePath(pdf);
    final duplicateFilePath = await getExternalStorageDirectory();
    final fileName = basename(pdf.path);
    await pdf.saveTo('${duplicateFilePath!.path}/$fileName');
    // storeImagesInSharedPref(pdf.path, imageList![index].checkListId.toString());
    setState(() {
      hasData = false;
      model.image = pdf;
    });
  }

  Future<void> _toggleTranslation() async {
    setState(() {
      _isHindi = !_isHindi;
    });

    if (_isHindi) {
      if (_ChecklistModel != null) {
        // Translate SubProcessName set
        List<Future<String>> translateSubProcessNameFutures = _subprocessList
            .map((e) => TranslationHelper.translateToHindi(e))
            .toList();

        // Translate subProcessName inside checklist items
        List<Future<String>> translateSubProcessFutures = _originalSubProcess
            .map((e) => TranslationHelper.translateToHindi(e))
            .toList();

        // Translate descriptions
        List<Future<String>> translationFutures = _originalDescriptions
            .map((text) => TranslationHelper.translateToHindi(text))
            .toList();

        // Wait for all translations in parallel
        List<String> translatedSetNames =
            await Future.wait(translateSubProcessNameFutures);
        List<String> translatedSubProcesses =
            await Future.wait(translateSubProcessFutures);
        List<String> translatedDescriptions =
            await Future.wait(translationFutures);

        // Update Set with translated values
        subProcessName!
          ..clear()
          ..addAll(translatedSetNames);

        // Update checklist model fields
        for (int i = 0; i < _ChecklistModel!.length; i++) {
          _ChecklistModel![i].description = translatedDescriptions[i];
          _ChecklistModel![i].subProcessName = translatedSubProcesses[i];
        }
      }
    } else {
      // Restore original descriptions & subProcessName
      for (int i = 0; i < _originalDescriptions.length; i++) {
        _ChecklistModel![i].description = _originalDescriptions[i];
        _ChecklistModel![i].subProcessName = _originalSubProcess[i];
      }

      subProcessName!
        ..clear()
        ..addAll(_subprocessList);
    }

    setState(() {}); // Refresh UI
  }

  Widget _buildImageList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: imageList!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildImageListItem(index);
      },
    );
  }

  Widget _buildImageListItem(int index) {
    final imageItem = imageList![index];

    String _formatSize(int bytes) {
      double kb = bytes / 1024;
      double mb = kb / 1024;
      if (mb >= 1) {
        return "${mb.toStringAsFixed(2)} MB";
      } else {
        return "${kb.toStringAsFixed(2)} KB";
      }
    }

    return ListTile(
      trailing: imageItem.imageByteArray != null
          ? InkWell(
              onTap: () => previewAlert(
                imageItem.imageByteArray!,
                index,
                imageItem.description,
              ),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            imageItem.description ?? '',
            style: TextStyle(color: Colors.green, fontSize: 15),
          ),
          if (imageItem.imageByteArray != null)
            Text(
              "Size: ${_formatSize(imageItem.imageByteArray!.lengthInBytes)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        builder: (context) => PreviewImageWidget(photos),
                      ),
                    ),
                    child: Image.memory(
                      photos!,
                      fit: BoxFit.fitWidth,
                      width: 250,
                      height: 250,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        imageList![index].image = null;
                        imageList![index].imageByteArray = null;
                        imageList![index].value = null;
                        Navigator.pop(context);
                      });
                    },
                    child: Row(children: [Icon(Icons.delete), Text('Delete')]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery, index);
                    },
                    child: Row(
                      children: [Icon(Icons.image), Text('From Gallery')],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera, index);
                    },
                    child: Row(
                      children: [Icon(Icons.camera), Text('From Camera')],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  void _showAlert(BuildContext context) {
    String? remark; // to store the value of Remark field
    String? siteTeamMembers; // to store the value of Site Team Members field

    showDialog(
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
                  remark = value;
                  _remarkController = value;
                },
                validator: (value) {
                  if (value! == '') {
                    return 'Please enter Remark'; // Validation for Remark field
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText:
                      'Enter Site Team Members', // Placeholder text for Site Team Members field
                ),
                onChanged: (value) {
                  siteTeamMembers = value;
                  _siteEngineerTeamController = value;
                  issiteEngAvailable =
                      _siteEngineerTeamController!.isNotEmpty ? true : false;
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
              onPressed: () async {
                // final snackBar = SnackBar(
                //   content: const Text('Save Sucessfully'),
                // );
                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                if (remark != null) {
                  await Future.sync(() =>
                      insertCheckListDataWithSiteTeamEngineer(_ChecklistModel!)
                          .whenComplete(() => _showToast(
                              isSubmited!
                                  ? "Data Updated Successfully"
                                  : "Something Went Wrong!!!",
                              MessageType: isSubmited! ? 0 : 1)));
                  // for (int j = 0; j <= _ChecklistModel!.length; j++) {
                  //   _ChecklistModel![j].remark = _remarkController;
                  // lsitdata = _ChecklistModel;
                  // }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showApproveAlert(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Approve'),
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
              SizedBox(height: 16.0),
              if (conString!.contains('ID=dba'))
                TextFormField(
                  decoration: InputDecoration(
                    hintText:
                        'Enter Site Team Members', // Placeholder text for Site Team Members field
                  ),
                  onChanged: (value) {
                    _siteEngineerTeamController = value;
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
                  approveCheckListDataWithSiteTeamEngineer(_ChecklistModel!)
                      .whenComplete(() => _showToast(
                          isSubmited!
                              ? "Data Updated Successfully"
                              : "Something Went Wrong!!!",
                          MessageType: isSubmited! ? 0 : 1));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showCommentAlert(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText:
                      'Enter Comment*', // Placeholder text for Remark field
                ),
                onChanged: (value) {
                  _remarkController = value;
                },
                validator: (value) {
                  if (value! == '') {
                    return 'Please enter Comment'; // Validation for Remark field
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              if (conString!.contains('ID=dba'))
                TextFormField(
                  decoration: InputDecoration(
                    hintText:
                        'Enter Site Team Members', // Placeholder text for Site Team Members field
                  ),
                  onChanged: (value) {
                    _siteEngineerTeamController = value;
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
                  commentCheckListDataWithSiteTeamEngineer(_ChecklistModel!)
                      .whenComplete(() => _showToast(
                          isSubmited!
                              ? "Data Updated Successfully"
                              : "Something Went Wrong!!!",
                          MessageType: isSubmited! ? 0 : 1));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> addAll(List<ECM_Checklist_Model> imageList) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? project = preferences.getString('ProjectName');
      String? projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      int? proUserId = preferences.getInt('ProUserId');

      var omsId = getDeviceid(widget.Source!);
      String submitDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      var source = widget.Source;
      var imagePath = "$projectName/$source/$omsId/";

      int countflag = 0;
      int uploadflag = 0;

      // Map each element in imageList to a Future returned by uploadImage,
      // then use Future.wait to wait for all the Futures to complete
      // before continuing
      await Future.wait(imageList
          .where((element) =>
              element.inputType == 'image' && element.image != null)
          .map((element) async {
        // String? imagePathValue = await uploadImage(imagePath, element.image);
        String? imagePathValue = await uploadImageAndGetPath(
            element.image!.path, widget.Source!.toUpperCase(), deviceids);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      return true;
    } catch (_, ex) {
      return false;
    }
  }

  _showToast(String? msg, {int? MessageType}) {
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
    await getECMProcess(widget.Source!).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          listProcess = value;
        });
      }
    }).whenComplete(() {
      setState(() {
        for (var element in listProcess!
            .where((e) => e.processId != 17 && e.processId != 18)) {
          listdistinctProcess!.add(element.processName!);
        }
        selectedProcess = listdistinctProcess!.first;
        imageList = [];
      });
    });
    getECMData(selectedProcess!);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: listdistinctProcess?.length ?? 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(getAppbarName(widget.Source ?? "")),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EcmHistoryScreen(
                              nodeDetails: widget.viewdata!,
                              source: widget.Source,
                            )),
                    (Route<dynamic> route) => true,
                  );
                },
                icon: Icon(Icons.info_outline_rounded)),
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
              _buildTabBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getECMFeed(),
                      if (imageList!.isNotEmpty) _buildImageSelectionTile(),
                      if (datasoff.isNotEmpty) _buildOfflineSaveText(),
                      if (isSubmit()) _buildSubmitButtons(),
                      if (isApproved()) _buildApprovalButtons(),
                      if (siteTeamMember.isNotEmpty) _buildSiteTeamMemberText(),
                      if (remarkval.isNotEmpty)
                        _buildRemarkTile(
                            "Submitted", workdoneby, workedondate, remarkval),
                      if (approvedremark.isNotEmpty)
                        _buildRemarkTile(
                            "Approved", approvedby, approvedon, approvedremark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.blue[300],
          borderRadius: BorderRadius.circular(5.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: listdistinctProcess!
            .map((e) => FittedBox(
                  child: Text(
                    e.replaceAll(' ', '\n'),
                    softWrap: true,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        onTap: (value) async {
          setState(() {
            _isHindi = false;
            selectedProcess = listdistinctProcess!.elementAt(value);
            subProcessName?.clear(); // Clear existing subprocesses
            _ChecklistModel = []; // Clear existing checklist items
          });
          getECMData(selectedProcess!);
        },
      ),
    );
  }

  Widget _buildImageSelectionTile() {
    final hasImage = imageList!.any((element) =>
        element.processId == processId &&
        element.inputType == 'image' &&
        element.value != null);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: imageListpopup,
            child: Image(
              image: AssetImage(hasImage
                  ? 'assets/images/imagepreview.png'
                  : 'assets/images/uploadimage.png'),
              fit: BoxFit.cover,
              height: 80,
              width: 80,
            ),
          ),
          SizedBox(
            child: Center(
              child: Text(hasImage ? 'Image Uploaded' : 'No Image Uploaded',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSaveText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(datasoff.first.issaved!),
      ),
    );
  }

  Widget _buildSubmitButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (!datasoff.isNotEmpty || _isConnected)
            ElevatedButton(
              child: Text("Submit"),
              onPressed: btnSubmit_Clicked,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          if (!_isConnected)
            ElevatedButton(
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              onPressed: () {
                _showSaveConfirmationDialog();
              },
            ),
          if (datasoff.isNotEmpty)
            ElevatedButton(
              child: Text("Upload"),
              onPressed: () {
                _showUploadConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: Text("Approve"),
            onPressed: btnApproveClicked,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton(
            child: Text("Comment"),
            onPressed: btnCommentClicked,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteTeamMemberText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'Site Team Member: ',
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            siteTeamMember,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkTile(String title, String by, String date, String remark) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
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
                    'By: ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    by,
                    style: TextStyle(color: Colors.black, fontSize: 14),
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
                    getshortdate(date),
                    style: TextStyle(color: Colors.black, fontSize: 14),
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
                      remark,
                      softWrap: true,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String approvedTitle() {
    if (selectedProcess!.toLowerCase().contains('dry comm')) {
      return approvedStatus == 3 ? 'Commented' : 'Approved';
    } else {
      return approvedStatus == 4 ? 'Commented' : 'Approved';
    }
  }

  bool isApproved() {
    var flag = userType.toLowerCase().contains('manager') ||
        userType.toLowerCase().contains('admin');
    if (!selectedProcess!.toLowerCase().contains('dry commissioning')) {
      return approvedStatus == 2 && flag;
    } else {
      return approvedStatus == 1 && flag;
    }
  }

  bool isSubmit() {
    var flag = userType.toLowerCase().contains('manager') ||
        userType.toLowerCase().contains('admin');
    if (flag) {
      return false;
    } else {
      if (!selectedProcess!.toLowerCase().contains('dry comm')) {
        return (approvedStatus == 3) ? false : true;
      } else {
        return (approvedStatus == 2) ? false : true;
      }
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
    } catch (_, ex) {
      title = '';
    }
    return title;
  }

  getFilename() {
    var title;
    try {
      if (widget.Source == 'oms') {
        title = modelData!.chakNo.toString();
      } else if (widget.Source == 'ams') {
        title = modelData!.amsNo.toString();
      } else if (widget.Source == 'rms') {
        title = modelData!.rmsNo.toString();
      } else if (widget.Source == 'lora') {
        title = modelData!.gatewayName;
      } else {
        title = '';
      }
    } catch (_, ex) {
      title = '';
    }
    return title;
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

  getECMData(String processName) async {
    _ChecklistModel = [];
    subProcessName = Set();
    setState(() {
      processId = listProcess!
          .firstWhere(
            (item) => item.processName == processName,
          )
          .processId;
    });
    setState(() {
      psId = processId;
    });

    try {
      if (widget.Source == 'oms') {
        await fatchFirstloadoms();
      } else if (widget.Source == 'rms') {
        await fatchFirstloadRms();
      } else if (widget.Source == 'ams') {
        await fatchFirstloadams();
      } else if (widget.Source == 'lora') {
        await fatchFirstloadlora();
      }
    } catch (_) {
      debugPrint('Error');
    }

    try {
      int deviceId = getDeviceid(widget.Source!);
      getECMCheckListByProcessId(deviceId, processId!, widget.Source!)
          .then((value) {
        for (var element in value) {
          setState(() {
            subProcessName!.add(element.subProcessName!);
            _subprocessList.add(element.subProcessName!);
          });
        }
        getWorkedByNAme((value.first.workedBy ?? '').toString());
        getApprovedbyName((value.first.approvedBy ?? '').toString());
        setState(() {
          _ChecklistModel = value;
          workedondate = (value.first.workedOn ?? '').toString();
          remarkval = (value.first.remark ?? '').toString();
          siteTeamMember = (value.first.siteTeamEngineer ?? '').toString();
          approvedon = (value.first.approvedOn ?? '').toString();
          approvedremark = (value.first.approvalRemark ?? '').toString();
          approvedStatus = value.first.approvedStatus;
          _originalDescriptions =
              value.map((item) => item.description ?? '').toList();
          _originalSubProcess =
              value.map((e) => e.subProcessName ?? '').toList();
          imageList =
              value.where((element) => element.inputType == 'image').toList();
        });
      });
    } catch (ex) {
      debugPrint('Error: $ex');
    }
  }

  bool isEdit() {
    var flag = userType.toLowerCase().contains('manager') ||
        userType.toLowerCase().contains('admin');
    if (flag) {
      return false;
    } else {
      if (!selectedProcess!.toLowerCase().contains('dry comm')) {
        return (approvedStatus == 3) ? false : true;
      } else {
        return (approvedStatus == 2) ? false : true;
      }
    }
  }

  Widget getECMFeed() {
    if (subProcessName!.isEmpty || _ChecklistModel!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter subprocesses by the selected process
    return Column(
      children: subProcessName!.map((subProcess) {
        // Filter checklist items by subprocess and exclude 'image' type
        var filteredItems = _ChecklistModel!
            .where((item) =>
                item.subProcessName == subProcess && item.inputType != 'image')
            .toList();

        // Return an empty container if no items match the filter
        if (filteredItems.isEmpty) return SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ExpandableTile(
            title: Text(
              subProcess.toUpperCase(),
              softWrap: true,
            ),
            body: Column(
              children: () {
                Map<int, int> subProcessCounters =
                    {}; // Stores the counter for each subProcessId
                return filteredItems.map((item) {
                  int? subProcessId;
                  if (item.isBullet != 1) {
                    subProcessId = item.subProcessId;
                  }

                  subProcessCounters[subProcessId ?? 0] =
                      (subProcessCounters[subProcessId] ?? 0) + 1;

                  return _buildChecklistItem(
                      item, subProcessCounters[subProcessId] ?? 0);
                }).toList();
              }(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChecklistItem(ECM_Checklist_Model item, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (item.isBullet != 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("$index .",
                      textAlign: TextAlign.left, softWrap: true),
                ),
              if (item.isBullet == 1)
                Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.circle, size: 8, color: Colors.black),
                    ),
                  ],
                ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.description!,
                        textAlign: TextAlign.left, softWrap: true),
                    if (_isHindi)
                      Text(
                          "(${_originalDescriptions[_ChecklistModel!.indexOf(item)]})",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12),
                          softWrap: true),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              if ((item.inputType == 'text' || item.inputType == 'float') &&
                  item.isBulletHeader != 1)
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    enabled: isEdit(),
                    initialValue: item.value,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blue),
                      ),
                      suffixText: item.inputText?.isNotEmpty == true
                          ? item.inputText
                          : '',
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
                    value: item.value == 'OK',
                    onChanged: isEdit()
                        ? (value) {
                            setState(() {
                              item.value = value! ? 'OK' : '';
                            });
                          }
                        : null,
                  ),
                ),
              // if (item.inputType == 'pdf')
              if (item.inputType == 'pdf')
                Expanded(
                  flex: 0,
                  child: IconButton(
                    icon: Image.asset(
                      "assets/images/pdf.png",
                      cacheHeight: 25,
                    ),
                    onPressed: () async {
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
                            content: SizedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: IconButton(
                                      // User can upload only PDF
                                      onPressed: () async {
                                        File? file = await getPdf(item);
                                        if (file != null &&
                                            file.path
                                                .toLowerCase()
                                                .endsWith('.pdf')) {
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Please select a valid PDF file.')),
                                          );
                                        }
                                      },
                                      icon: Column(
                                        children: [
                                          Icon(Icons.upload),
                                          Text('Upload PDF'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (item.image != null && item.value == null)
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: IconButton(
                                        onPressed: () async {
                                          await OpenFile.open(item.image?.path);
                                        },
                                        icon: Column(
                                          children: [
                                            Icon(
                                                Icons.document_scanner_rounded),
                                            Text('View PDF'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (item.value != null)
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: IconButton(
                                        onPressed: () async {
                                          await GetPDFbyPath(item.value ?? '');
                                          base64ToPdf(
                                              pdfString ?? '', getFilename());
                                        },
                                        icon: Column(
                                          children: [
                                            Icon(
                                                Icons.document_scanner_rounded),
                                            Text('View PDF'),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

              if (item.inputType == 'json')
                Expanded(
                    flex: 0,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/images/pdf.png",
                        // height: 10,
                        cacheHeight: 25,
                      ),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                icon: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                                iconColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                content: SizedBox(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: IconButton(
                                          //if user click this button, user can upload image from gallery
                                          onPressed: () {
                                            Navigator.pop(context);
                                            getPdf(item);
                                          },
                                          icon: Column(
                                            children: [
                                              Icon(Icons.upload),
                                              Text('Upload JSON'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (item.image != null &&
                                          item.value == null)
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: IconButton(
                                            //if user click this button. user can upload image from camera
                                            onPressed: () async {
                                              await OpenFile.open(
                                                  item.image?.path);
                                            },
                                            icon: Column(
                                              children: [
                                                Icon(Icons
                                                    .document_scanner_rounded),
                                                Text('View PDF'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (item.value != null)
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: IconButton(
                                            //if user click this button. user can upload image from camera
                                            onPressed: () async {
                                              await GetPDFbyPath(
                                                  item.value ?? '');
                                              base64ToPdf(pdfString ?? '',
                                                  getFilename());
                                            },
                                            icon: Column(
                                              children: [
                                                Icon(Icons
                                                    .document_scanner_rounded),
                                                Text('View PDF'),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    ))
            ],
          ),
          Divider(
            color: Colors.black,
            height: 1,
          )
        ],
      ),
    );
  }

  Future<String> GetPDFbyPath(String path) async {
    String pdf64base = "";
    try {
      var request = http.Request(
          'GET',
          Uri.parse(
              'http://wmsservices.seprojects.in/api/Image/GetImage?imgPath=$path'));
      debugPrint(
          'http://wmsservices.seprojects.in/api/Image/GetImage?imgPath=$path');

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        pdf64base = await response.stream.bytesToString();
        setState(() {
          pdfString = pdf64base.replaceAll('"', '');
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (_, ex) {
      throw Exception(ex);
    }
    return pdf64base.replaceAll('"', '');
  }

  base64ToPdf(String base64String, String fileName) async {
    var bytes = base64Decode(base64String);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await OpenFile.open("${output.path}/$fileName.pdf");
  }

  getWorkedByNAme(String userid) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String? projectId = preferences.getString('ProjectId');

      final res = await http.get(Uri.parse(
          'http://ecmv2.iotwater.in:3011/api/v1/project/users/0/$userid/$projectId'));

      print(
          'http://ecmv2.iotwater.in:3011/api/v1/project/users/0/$userid/$projectId');

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response'][0]);
          setState(() {
            workdoneby = loginResult.firstname.toString();
          });

          return loginResult.firstname.toString();
        }
      } else {
        return '';
      }
    } catch (err) {
      userName = '';
      return '';
    }
  }

  getApprovedbyName(String userid) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? projectId = preferences.getString('ProjectId');

      final res = await http.get(Uri.parse(
          'http://ecmv2.iotwater.in:3011/api/v1/project/users/0/$userid/$projectId'));

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == WebApiStatusOk) {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response'][0]);
          setState(() {
            approvedby = loginResult.firstname.toString();
            approvedId = userid;
          });

          // print(loginResult.firstname.toString());
          return loginResult.firstname.toString();
        }
        // else
        //   return '';
        // throw Exception("Login Failed");
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
      userType = pref.getString('usertype')!;
    } catch (_, ex) {
      userType = '';
    }
  }

  Future<String?> uploadImageNew(
      int index, List<ECM_Checklist_Model> imageListNew) async {
    try {
      if (imageListNew[index].imageByteArray != null) {
        XFile? image = await getPrefImage(imageListNew[index].checkListId);
        await clearImageFromSharedPreferences(
            imageListNew[index].checkListId.toString());

        String? testpath = await uploadImageAndGetPath(
            image.path, widget.Source!.toUpperCase(), deviceids);
        return testpath;
      } else {
        return '';
      }
    } catch (_) {}
    return '';
  }

  Future<bool> approveCheckListDataWithSiteTeamEngineer(
      List<ECM_Checklist_Model> _checkList) async {
    bool flag = false;

    var respflag;
    try {
      if (_checkList != null) {
        int approveStatus = 0;
        int checkCount = _checkList
            .where((e) =>
                (e.value == null || e.value!.isEmpty) && e.inputType != "image")
            .length;
        int imageCount = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) || e.image != null) &&
                e.inputType == "image")
            .length;
        if (!selectedProcess!.toLowerCase().contains('dry comm')) {
          approveStatus = 3;
        } else {
          approveStatus = 2;
        }

        int flagCounter = 0;
        for (var subpro in subProcessName!) {
          var list = _checkList
              .where((element) =>
                  element.subProcessName!.toLowerCase() == subpro.toLowerCase())
              .toList();

          respflag = await approveCheckListDataWithSiteTeamEngineer_func(
              list, list.first.subProcessId!,
              apporvedStatus: approveStatus);
          if (respflag) {
            flagCounter++;
          }
        }
        if (flagCounter == subProcessName!.length) {
          getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
          });
          flag = true;
        } else
          throw new Exception();
      }
    } catch (_, ex) {
      flag = false;
    }
    return flag;
  }

  Future<bool> approveCheckListDataWithSiteTeamEngineer_func(
      List<ECM_Checklist_Model> imageList, int subprocessId,
      {int apporvedStatus = 0}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? project = preferences.getString('ProjectName');
      String? projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      int? proUserId = preferences.getInt('ProUserId');

      var omsId = getDeviceid(widget.Source!);
      String submitDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      var source = widget.Source;
      var imagePath = "$projectName/$source/$omsId/";

      int countflag = 0;
      int uploadflag = 0;

      // Map each element in imageList to a Future returned by uploadImage,
      // then use Future.wait to wait for all the Futures to complete
      // before continuing
      await Future.wait(imageList
          .where((element) =>
              element.inputType == 'image' && element.image != null)
          .map((element) async {
        // String? imagePathValue = await uploadImage(imagePath, element.image);
        String? imagePathValue = await uploadImageAndGetPath(
            element.image!.path, widget.Source!.toUpperCase(), deviceids);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = imageList.map((e) => e.checkListId).toList().join(",");
      var valueData = imageList.map((e) => e.value ?? '').toList().join(",");
      var aproveStatus = apporvedStatus;
      var Insertobj = new Map<String, dynamic>();

      Insertobj["processId"] = processId;
      Insertobj["subProcessId"] = subprocessId;
      Insertobj["checkListData"] = checkListId;
      Insertobj["OmsId"] = getDeviceid(widget.Source!);
      Insertobj["userId"] = proUserId.toString();
      Insertobj["valuedata"] = valueData;
      Insertobj["Remark"] = _remarkController;
      Insertobj["TempDT"] = submitDate;
      Insertobj["ApprovedStatus"] = aproveStatus;
      Insertobj["conString"] = conString;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
            "POST",
            Uri.parse(
                'http://wmsservices.seprojects.in/api/PMS/UpdateECMApprovedStatus'));
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            return true;
          } else
            throw new Exception();
        } else
          throw new Exception();
      } else {
        throw new Exception();
      }
    } catch (_, ex) {
      return false;
    }
  }

  Future<bool> commentCheckListDataWithSiteTeamEngineer(
      List<ECM_Checklist_Model> _checkList) async {
    bool flag = false;

    var respflag;
    try {
      if (_checkList != null) {
        int approveStatus = 0;
        int checkCount = _checkList
            .where((e) =>
                (e.value == null || e.value!.isEmpty) && e.inputType != "image")
            .length;
        int imageCount = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) || e.image != null) &&
                e.inputType == "image")
            .length;
        if (!selectedProcess!.toLowerCase().contains('dry comm') ||
            !selectedProcess!.toLowerCase().contains('wet comm')) {
          approveStatus = 4;
        } else {
          approveStatus = 3;
        }
        /*bool isPartialProcess =
            selectedProcess!.toLowerCase().contains("dry") ||
                selectedProcess!.toLowerCase().contains('auto');
        if (checkCount !=
                _checkList.where((e) => e.inputText != "image").length ||
            imageCount != 0) {
          if (imageCount >= 3 && checkCount == 0)
            approveStatus = isPartialProcess ? 1 : 2;
          else if (!isPartialProcess) {
            approveStatus = 1;
          } else {
            if (imageCount < 3) 
            print("atleast 3 image must be uploaded");
            if (checkCount != 0)
            print("Partially done is not allow in this process");
            return false;
          }
        } else {
          return false;
        }*/

        int flagCounter = 0;
        for (var subpro in subProcessName!) {
          var list = _checkList
              .where((element) =>
                  element.subProcessName!.toLowerCase() == subpro.toLowerCase())
              .toList();

          respflag = await approveCheckListDataWithSiteTeamEngineer_func(
              list, list.first.subProcessId!,
              apporvedStatus: approveStatus);
          if (respflag) {
            flagCounter++;
          }
        }
        if (flagCounter == subProcessName!.length) {
          getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
          });
          flag = true;
        } else
          throw new Exception();
      }
    } catch (_, ex) {
      flag = false;
    }
    return flag;
  }

  Future<bool> insertCheckListDataWithSiteTeamEngineer(
      List<ECM_Checklist_Model> checklist) async {
    bool isSuccess = false;

    try {
      if (checklist.isEmpty) return false;

      // Count incomplete text fields (excluding image/pdf)
      int incompleteTextCount = checklist
          .where((item) =>
              (item.value == null || item.value!.isEmpty) &&
              item.inputType != "image" &&
              item.inputType != "pdf" &&
              item.inputType != "")
          .length;

      // Count image/pdf fields that are empty or have imageByteArray
      int incompleteMediaCount = checklist
          .where((item) =>
              (item.inputType == "image" || item.inputType == "pdf") &&
              ((item.value == null || item.value!.isEmpty) ||
                  item.imageByteArray != null))
          .length;

      // Check if process is partial (i.e., "dry", "auto", or "wet")
      bool isPartialProcess = selectedProcess!.toLowerCase().contains("dry") ||
          selectedProcess!.toLowerCase().contains("auto") ||
          selectedProcess!.toLowerCase().contains("wet");

      // Get image/pdf items with imageByteArray
      var validImages = imageList!
          .where((item) =>
              (item.inputType!.contains("image") ||
                  item.inputType!.contains("pdf")) &&
              item.imageByteArray != null)
          .toList();

      int approveStatus = 0;

      // Validation logic
      if (!isPartialProcess) {
        bool allFieldsFilled = incompleteTextCount == 0;
        bool enoughImages = validImages.length >= 3;

        if (!allFieldsFilled || incompleteMediaCount != 0) {
          if (!enoughImages) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Message"),
                content: Text("Minimum 3 Images are required to proceed"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  ),
                ],
              ),
            );
            return false;
          } else if (allFieldsFilled) {
            approveStatus = 2;
          } else {
            approveStatus = 1;
          }
        } else {
          return false;
        }
      } else {
        approveStatus = 1; // Partial processes can skip image requirement
      }

      // Submit data subprocess-wise
      int submittedCount = 0;

      for (var subProcess in subProcessName!) {
        var subList = checklist
            .where((item) =>
                item.subProcessName!.toLowerCase() == subProcess.toLowerCase())
            .toList();

        bool response = await insertCheckListDataWithSiteTeamEngineer_func(
          subList,
          subList.first.subProcessId!,
          apporvedStatus: approveStatus,
        );

        if (response) submittedCount++;
      }

      if (submittedCount == subProcessName!.length) {
        getECMData(selectedProcess!);
        setState(() {
          isSubmited = true;
          Source = widget.Source;
        });
        isSuccess = true;
      }
    } catch (e) {
      // Log or handle exception if needed
      isSuccess = false;
    }

    return isSuccess;
  }

  Future<bool> insertCheckListDataWithSiteTeamEngineer_func(
      List<ECM_Checklist_Model> imageList, int subprocessId,
      {int apporvedStatus = 0}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? project = preferences.getString('ProjectName');
      String? projectId = preferences.getString('ProjectId');
      String? projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      int? proUserId = preferences.getInt('ProUserId');
      var omsId = getDeviceid(widget.Source!);
      String submitDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      var source = widget.Source;
      var imagePath = "$projectName/$source/$omsId/";
      int countflag = 0;
      int uploadflag = 0;

      // Map each element in imageList to a Future returned by uploadImage,
      // then use Future.wait to wait for all the Futures to complete
      // before continuing
      await Future.wait(imageList
          .where((element) =>
              (element.inputType == 'image' || element.inputType == 'pdf') &&
              element.image != null)
          .map((element) async {
        String? imagePathValue = await uploadImageAndGetPath(
            element.image!.path, widget.Source!.toUpperCase(), deviceids);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = imageList.map((e) => e.checkListId).toList().join(",");
      var valueData = imageList.map((e) => e.value ?? '').toList().join(",");
      var aproveStatus = apporvedStatus;
/*      var Insertobj = new Map<String, dynamic>();

      Insertobj["processId"] = processId;
      Insertobj["subProcessId"] = subprocessId;
      Insertobj["checkListData"] = checkListId;
      Insertobj["deviceId"] = getDeviceid(widget.Source!);
      Insertobj["userId"] = proUserId.toString();
      Insertobj["valuedata"] = valueData;
      Insertobj["Remark"] = imageList.first.remark;
      Insertobj["TempDT"] = submitDate;
      Insertobj["ApprovedStatus"] = aproveStatus;
      Insertobj["Source"] = widget.Source;
      Insertobj["conString"] = conString;
      Insertobj["IsSiteTeamEngineerAvailable"] = issiteEngAvailable;
      Insertobj["SiteTeamEngineer"] = imageList.first.siteTeamEngineer;

      if (countflag == uploadflag) {
        var headers = {'Content-Type': 'application/json'};
        final request = http.Request(
          "POST",
          Uri.parse(
            'http://wmsservices.seprojects.in/api/PMS/InsertECMReport_WithSiteTeamEngineer',
          ),
        );
        request.headers.addAll(headers);
        request.body = json.encode(Insertobj);
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          dynamic json = jsonDecode(await response.stream.bytesToString());
          if (json["Status"] == "Ok") {
            return true;
          } else
            throw new Exception();
        } else
          throw new Exception();
      } else {
        throw new Exception();
      }
*/

      var data = json.encode({
        "ProcessId": processId,
        "SubProcessId": subprocessId,
        "Checklistid": checkListId,
        "deviceId": getDeviceid(widget.Source!),
        "userid": proUserId.toString(),
        "values": valueData,
        "remark": _remarkController,
        "approvestatus": aproveStatus,
        "workedOn": submitDate,
        "deviceType": widget.Source!.toUpperCase(),
        "siteEngineer": _siteEngineerTeamController,
        "projectId": projectId
      });

      if (countflag == uploadflag) {
        var result = await uploadECMReport(data);
        try {
          if (selectedProcess!.toLowerCase().contains('mech')) {
            preferences.setString('Mechanical', aproveStatus.toString());
          } else if (selectedProcess!.toLowerCase().contains('cont')) {
            preferences.setString('Erection', aproveStatus.toString());
          } else if (selectedProcess!.toLowerCase().contains('dry')) {
            preferences.setString('DryComm', aproveStatus.toString());
          } else if (selectedProcess!.toLowerCase().contains('wet')) {
            preferences.setString('WetComm', apporvedStatus.toString());
          } else {
            debugPrint('Process Not Found');
          }
        } catch (e) {
          debugPrint('Error While Changing Status');
        }
        return result;
      } else {
        return false;
      }
    } catch (_, ex) {
      return false;
    }
  }

/*
  Future<bool> insertCheckListDataWithSiteTeamEngineer(
      List<ECM_Checklist_Model> _checkList) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int approveStatus = 0;
        int checkCount = _checkList
            .where((e) =>
                (e.value == null || e.value!.isEmpty) &&
                e.inputType != "image" &&
                e.inputType != "pdf" &&
                e.inputType != "")
            .length;
        int imageCount = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) ||
                        e.imageByteArray != null) &&
                    e.inputType == "image" ||
                e.inputType == 'pdf')
            .length;

        bool isPartialProcess =
            selectedProcess!.toLowerCase().contains("dry") ||
                selectedProcess!.toLowerCase().contains('auto') ||
                selectedProcess!.toLowerCase().contains('wet');

        var _imglistdataWithoutNullValue = imageList!
            .where((item) =>
                (item.inputType!.contains("image") ||
                    item.inputType!.contains("pdf")) &&
                item.imageByteArray != null)
            .toList();

        // Skip image check if isPartialProcess is true
        if (!isPartialProcess) {
          if (checkCount !=
                  _checkList
                      .where(
                          (e) => e.inputText != "image" && e.inputType != "pdf")
                      .length ||
              imageCount != 0) {
            if (checkCount == 0 && _imglistdataWithoutNullValue.length < 3) {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Message"),
                    content: Text("Minimum 3 Images are required to proceed"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
              return false;
            } else if (imageCount >= 3 && checkCount == 0) {
              approveStatus = 2;
            } else {
              approveStatus = 1;
            }
          } else {
            return false;
          }
        } else {
          approveStatus =
              1; // For "auto" or "dry" processes, approval is allowed without 3 images
        }

        int flagCounter = 0;
        for (var subpro in subProcessName!) {
          var list = _checkList
              .where((element) =>
                  element.subProcessName!.toLowerCase() == subpro.toLowerCase())
              .toList();
          respflag = await insertCheckListDataWithSiteTeamEngineer_func(
              list, list.first.subProcessId!,
              apporvedStatus: approveStatus);
          if (respflag) {
            flagCounter++;
          }
        }
        if (flagCounter == subProcessName!.length) {
          getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
            Source = widget.Source;
          });
          flag = true;
        } else {
          throw new Exception();
        }
      }
    } catch (_, ex) {
      flag = false;
    }
    return flag;
  }
*/

  // offline data send to server
  Future<bool> insertCheckListDataWithSiteTeamEngineer_off(
      List<ECM_Checklist_Model> _checkList) async {
    bool flag = false;
    var respflag;
    try {
      if (_checkList != null) {
        int approveStatus = 0;
        int checkCount = _checkList
            .where((e) =>
                (e.value == null || e.value!.isEmpty) && e.inputType != "image")
            .length;
        int imageCount = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) ||
                    e.imageByteArray != null) &&
                e.inputType == "image")
            .length;
        int imagewithvalue = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) || e.image != null) &&
                e.inputType == "image")
            .length;
        bool isPartialProcess =
            selectedProcess!.toLowerCase().contains("dry") ||
                selectedProcess!.toLowerCase().contains('auto');

        var _imglistdataWithoutNullValue = _checkList
            .where((item) =>
                item.inputType!.contains("image") &&
                item.imageByteArray != null)
            .toList();

        if (checkCount !=
                _checkList.where((e) => e.inputText != "image").length ||
            imageCount != 0) {
          if (checkCount == 0 && _imglistdataWithoutNullValue.length < 3) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Message"),
                  content: Text("Minimum 3 Images are required to proceed"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
            return false;
          } else if (imageCount >= 3 && checkCount == 0) {
            approveStatus = isPartialProcess ? 1 : 2;
          } else if (!isPartialProcess) {
            approveStatus = 1;
          } else {
            if (imageCount < 3)
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Message"),
                    content: Text("Minimum 3 Images are required to proceed"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            if (checkCount != 0)
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Message"),
                    content:
                        Text("Partially done is not allow in this process"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            // print("Partially done is not allow in this process");
            return false;
          }
        } else {
          return false;
        }

        int flagCounter = 0;
        for (var subpro in subProcessName!) {
          var list = _checkList
              .where((element) =>
                  element.subProcessName!.toLowerCase() == subpro.toLowerCase())
              .toList();
          respflag = await insertCheckListDataWithSiteTeamEngineer_send(
              list, list.first.subProcessId!,
              apporvedStatus: approveStatus);
          if (respflag) {
            flagCounter++;
          }
        }
        if (flagCounter == subProcessName!.length) {
          getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
          });
          setState(() {
            Source = widget.Source;
          });

          await listdatacheckup();
          await DBSQL.instance.deleteChecklist(datasoff.first);
          await getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
          });
          setState(() {
            Source = widget.Source;
          });
          flag = true;
        } else
          throw new Exception();
      }
      /* if (_checkList != null) {
        int approveStatus = 0;
        int checkCount = _checkList
            .where((e) =>
                (e.image == null || e.imageByteArray!.isEmpty) &&
                e.inputType != "image")
            .length;
        int imageCount = _checkList
            .where((e) =>
                ((e.image == null || e.imageByteArray!.isEmpty) ||
                    e.image != null) &&
                e.inputType == "image")
            .length;
        int imagewithvalue = _checkList
            .where((e) =>
                ((e.value == null || e.value!.isEmpty) || e.image != null) &&
                e.inputType == "image")
            .length;
        bool isPartialProcess =
            selectedProcess!.toLowerCase().contains("dry") ||
                selectedProcess!.toLowerCase().contains('auto');
        if (checkCount !=
                _checkList.where((e) => e.inputText != "image").length ||
            imageCount != 0) {
          if (imageCount >= 3 && checkCount == 0)
            approveStatus = isPartialProcess ? 1 : 2;
          else if (!isPartialProcess) {
            approveStatus = 1;
          } else {
            if (imageCount < 3)
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Message"),
                    content: Text("Minimum 3 Images are required to proceed"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            if (checkCount != 0)
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Message"),
                    content:
                        Text("Partially done is not allow in this process"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            // print("Partially done is not allow in this process");
            return false;
          }
        } else {
          return false;
        }

        int flagCounter = 0;
        for (var subpro in subProcessName!) {
          var list = _checkList
              .where((element) =>
                  element.subProcessName!.toLowerCase() == subpro.toLowerCase())
              .toList();

          respflag = await insertCheckListDataWithSiteTeamEngineer_send(
              list, list.first.subProcessId!,
              apporvedStatus: approveStatus);
          if (respflag) {
            flagCounter++;
          }
        }
        if (flagCounter == subProcessName!.length) {
          final snackBar = SnackBar(
            content: const Text('Uploaded Sucessfully'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          await listdatacheckup();
          await DBSQL.instance.deleteCheckListData(
              datasoff.first.deviceId!, datasoff.first.processId!);
          await getECMData(selectedProcess!);
          setState(() {
            isSubmited = true;
          });
          setState(() {
            Source = widget.Source;
          });
          flag = true;
        } else
          throw new Exception();
      }*/
    } catch (_, ex) {
      flag = false;
    }
    return flag;
  }

  Future<bool> insertCheckListDataWithSiteTeamEngineer_send(
      List<ECM_Checklist_Model> imageList, int subprocessId,
      {int apporvedStatus = 0}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? project = preferences.getString('ProjectName');
      String? projectId = preferences.getString('ProjectId');
      String? projectName =
          preferences.getString('ProjectName')!.replaceAll(' ', '_');
      int? proUserId = imageList.first.workedBy;

      var omsId = getDeviceid(widget.Source!);
      String submitDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      var source = widget.Source;

      int countflag = 0;
      int uploadflag = 0;
      await Future.wait(imageList
          .where((element) =>
              element.inputType == 'image' && element.imageByteArray != null)
          .map((element) async {
        int index = imageList.indexOf(element);
        String? imagePathValue = await uploadImageNew(index, imageList);
        if (imagePathValue!.isNotEmpty) {
          element.value = imagePathValue;
          uploadflag++;
        }
        countflag++;
      }));

      var checkListId = imageList.map((e) => e.checkListId).toList().join(",");
      var valueData = imageList.map((e) => e.value ?? '').toList().join(",");
      var aproveStatus = apporvedStatus;

      var data = json.encode({
        "ProcessId": processId,
        "SubProcessId": subprocessId,
        "Checklistid": checkListId,
        "deviceId": getDeviceid(widget.Source!),
        "userid": proUserId.toString(),
        "values": valueData,
        "remark": _remarkController,
        "approvestatus": aproveStatus,
        "workedOn": submitDate,
        "deviceType": widget.Source!.toUpperCase(),
        "siteEngineer": _siteEngineerTeamController,
        "projectId": projectId
      });

      // if (countflag == uploadflag) {
      var result = await uploadECMReport(data);
      try {
        if (selectedProcess!.toLowerCase().contains('mech')) {
          preferences.setString('Mechanical', aproveStatus.toString());
        } else if (selectedProcess!.toLowerCase().contains('cont')) {
          preferences.setString('Erection', aproveStatus.toString());
        } else if (selectedProcess!.toLowerCase().contains('dry')) {
          preferences.setString('DryComm', aproveStatus.toString());
        } else if (selectedProcess!.toLowerCase().contains('wet')) {
          preferences.setString('WetComm', apporvedStatus.toString());
        } else {
          debugPrint('Process Not Found');
        }
      } catch (e) {
        debugPrint('Error While Changing Status');
      }
      return result;
      // } else {
      //   return false;
      // }
      /*var Insertobj = new Map<String, dynamic>();

      Insertobj["processId"] = processId;
      Insertobj["subProcessId"] = subprocessId;
      Insertobj["checkListData"] = checkListId;
      Insertobj["deviceId"] = getDeviceid(widget.Source!);
      Insertobj["userId"] = proUserId.toString();
      Insertobj["valuedata"] = valueData;
      Insertobj["Remark"] = imageList.first.remark;
      Insertobj["TempDT"] = submitDate;
      Insertobj["ApprovedStatus"] = aproveStatus;
      Insertobj["Source"] = widget.Source;
      Insertobj["conString"] = conString;
      Insertobj["IsSiteTeamEngineerAvailable"] = issiteEngAvailable;
      Insertobj["SiteTeamEngineer"] = imageList.first.siteTeamEngineer;

      var headers = {'Content-Type': 'application/json'};
      final request = http.Request(
          "POST",
          Uri.parse(
              'http://wmsservices.seprojects.in/api/PMS/InsertECMReport_WithSiteTeamEngineer'));
      request.headers.addAll(headers);
      request.body = json.encode(Insertobj);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        dynamic json = jsonDecode(await response.stream.bytesToString());
        if (json["Status"] == "Ok") {
          return true;
        } else
          throw new Exception();
      } else {
        return false;
      }*/
    } catch (_, ex) {
      return false;
    }
  }

  Future btnSubmit_Clicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool allow = false;
      String mech = prefs.getString("Mechanical") ?? '';
      String erec = prefs.getString("Erection") ?? '';
      String dry = prefs.getString("DryComm") ?? '';
      String autodry = prefs.getString("AutoDryComm") ?? '';
      String tower = prefs.getString("TowerInst") ?? '';
      String control = prefs.getString("ControlUnit") ?? '';
      String comms = prefs.getString("Comission") ?? '';
      String _proj = (prefs.getString("ProjectName") ?? '').toLowerCase();

      if (processId! == 4) {
        if (selectedProcess!.toLowerCase().contains("mechanical"))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains("erection"))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains("dry") &&
            (mech == 2.toString() || mech == 3.toString()) &&
            (erec == 2.toString() || erec == 3.toString()) &&
            !_proj.toLowerCase().contains('alirajpur'))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains("wet") &&
            (mech == 2.toString() || mech == 3.toString()) &&
            (erec == 2.toString() || erec == 3.toString()) &&
            ((dry == 1.toString() || dry == 2.toString()) ||
                (autodry == 1.toString() || autodry == 2.toString())))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains('tower'))
          allow = true;
        else
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Message"),
                content: Text("Please complete the previous process"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
      } else {
        if (selectedProcess!.toLowerCase().contains("mechanical"))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains("erection"))
          allow = true;
        else if (_proj.toLowerCase().contains('alirajpur demo') ||
            selectedProcess!.toLowerCase().contains("dry comm") &&
                (erec == 2.toString() || erec == 3.toString()))
          allow = true;
        else if (selectedProcess!.toLowerCase().contains("wet commissioning") &&
            (erec == 2.toString() || erec == 3.toString()) &&
            (dry == 1.toString() || dry == 2.toString()))
          allow = true;
        else
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Message"),
                content: Text("Please complete the previous process"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
      }

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

  Future<void> btnApproveClicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      bool isAllow = prefs.getBool("isAllowed")!;

      if (isAllow) {
        _showApproveAlert(context);
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Contact to Administrator"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (ex) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(ex.toString()),
            actions: [
              TextButton(
                child: Text("OK"),
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

  Future<void> btnCommentClicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      bool isAllow = prefs.getBool("isAllowed")!;

      if (isAllow) {
        _showCommentAlert(context);
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Contact to Administrator"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (ex) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(ex.toString()),
            actions: [
              TextButton(
                child: Text("OK"),
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

  Future<void> _showSaveConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ARE YOU SURE TO SAVE'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAlertOff(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUploadConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ARE YOU SURE TO UPLOAD'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (datasoff.isNotEmpty) {
                  await insertCheckListDataWithSiteTeamEngineer_off(datasoff);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlertOff(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? conString = preferences.getString('ConString');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _remarkoffController,
                decoration: const InputDecoration(
                  hintText: 'Enter Remark*',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter Remark';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _siteEngineerTeamOffController,
                decoration: const InputDecoration(
                  hintText: 'Enter Site Team Members',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (_remarkoffController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remark is required!')),
                  );
                  return;
                }

                // Update all checklist models
                for (final checklist in _ChecklistModel ?? []) {
                  checklist
                    ..remark = _remarkoffController.text.trim()
                    ..deviceId = deviceids
                    ..source = widget.Source
                    ..conString = conString
                    ..approvalRemark = approvedremark
                    ..image = image
                    ..workedBy = preferences.getInt('ProUserId')
                    ..approvedOn = approvedon
                    ..siteTeamEngineer =
                        _siteEngineerTeamOffController.text.trim()
                    ..issaved = "Save Offline Data!"
                    ..approvedBy = approvedId
                    ..tempDT = DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(DateTime.now());
                }

                Addchecklist = _ChecklistModel;

                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved Successfully')),
                );

                // Perform async operations
                await fatchdata11();
                await addList();
                await fatchdataSQL();
                await addNew();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /*void _showAlert_off(BuildContext context) async {
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
                  hintText:
                      'Enter Remark*', // Placeholder text for Remark field
                ),
                onChanged: (value) {
                  _remarkController = value;
                },
                validator: (value) {
                  if (value == '') {
                    return 'Please enter Remark'; // Validation for Remark field
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Site Team Members',
                ),
                onChanged: (value) {
                  _siteEngineerTeamController = value;
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
                final snackBar = SnackBar(
                  content: const Text('Save Sucessfully'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                if (_remarkController != null) {
                  Navigator.of(context).pop();
                }
                for (int j = 0; j <= _ChecklistModel!.length; j++) {
                  _ChecklistModel![j].remark = _remarkController;
                  _ChecklistModel![j].deviceId = deviceids;
                  _ChecklistModel![j].source = widget.Source;
                  _ChecklistModel![j].conString = conString;
                  _ChecklistModel![j].approvalRemark = approvedremark;
                  _ChecklistModel![j].image = image;
                  _ChecklistModel![j].workedBy =
                      preferences.getInt('ProUserId');
                  _ChecklistModel![j].approvedOn = approvedon;
                  _ChecklistModel![j].siteTeamEngineer = siteTeamMember;
                  _ChecklistModel![j].approvalRemark = approvedremark;
                  _ChecklistModel![j].issaved = "Save Offline Data!";
                  _ChecklistModel![j].approvedBy = approvedId;
                  _ChecklistModel![j].tempDT =
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                  Addchecklist = _ChecklistModel;
                }
              },
            ),
          ],
        );
      },
    );

    await fatchdata11();
    await addList();
    await fatchdataSQL();
    await addNew();
  }
*/

  Future fatchFirstloadoms() async {
    if (modelData!.omsId != 0) {
      setState(() => isLoading = true);
      Listdata = await ListViewModel.instance
          .fetchByProjectAndDevice(widget.ProjectName!, widget.Source!);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datasoff = await DBSQL.instance.fetchByProcess(modelData!.omsId!, psId!);
      setState(() => isLoading = false);
    }
  }

  Future fatchFirstloadams() async {
    if (modelData!.amsId != 0) {
      setState(() => isLoading = true);
      datasoff = await DBSQL.instance.fetchData();
      Listdata = await ListViewModel.instance
          .fetchByProjectAndDevice(widget.ProjectName!, widget.Source!);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datasoff = await DBSQL.instance.fetchByProcess(modelData!.amsId!, psId!);

      setState(() => isLoading = false);
    }
  }

  Future fatchFirstloadlora() async {
    if (modelData!.gateWayId != 0) {
      setState(() => isLoading = true);
      // datas11 = await DBSQL.instance.fatchdataSQLNew();
      Listdata = await ListViewModel.instance
          .fetchByProjectAndDevice(widget.ProjectName!, widget.Source!);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datasoff =
          await DBSQL.instance.fetchByProcess(modelData!.gateWayId!, psId!);

      setState(() => isLoading = false);
    }
  }

  Future fatchFirstloadRms() async {
    if (modelData!.rmsId != 0) {
      setState(() => isLoading = true);
      // datas11 = await DBSQL.instance.fatchdataSQLNew();
      Listdata = await ListViewModel.instance
          .fetchByProjectAndDevice(widget.ProjectName!, widget.Source!);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datasoff = await DBSQL.instance.fetchByProcess(modelData!.rmsId!, psId!);

      setState(() => isLoading = false);
    }
  }

  Future fatchdataSQL() async {
    setState(() => isLoading = true);
    Listdata = await ListViewModel.instance.fetchData();
    datas = await DBSQL.instance.fetchByProcess(deviceids, processId!);
    //  listdistinctProcesss = await ListModel.instance.fetchAll();
    setState(() => isLoading = false);
  }

  //send adata
  Future fatchdataSend() async {
    setState(() => isLoading = true);
    Listdata = await ListViewModel.instance.fetchData();
    datas = await DBSQL.instance
        .fetchByType(deviceids, processId!, Listdata!.first.deviceType);
    //  listdistinctProcesss = await ListModel.instance.fetchAll();
    setState(() => isLoading = false);
  }

  Future fatchdata11() async {
    if (widget.listdatas == modelData!.omsId) {
      setState(() => isLoading = true);
      alllistItem = await ListViewModel.instance.fetchData();
      Listdata = await ListViewModel.instance.fetchByOmsId(widget.listdatas!);

      setState(() => isLoading = false);
    }
    if (widget.listdatas == modelData!.amsId) {
      setState(() => isLoading = true);
      alllistItem = await ListViewModel.instance.fetchData();
      Listdata = await ListViewModel.instance.fetchByAmsId(widget.listdatas!);

      setState(() => isLoading = false);
    }
    if (widget.listdatas == modelData!.rmsId) {
      setState(() => isLoading = true);
      alllistItem = await ListViewModel.instance.fetchData();
      Listdata = await ListViewModel.instance.fetchByRmsId(widget.listdatas!);

      setState(() => isLoading = false);
    }
    if (widget.listdatas == modelData!.gateWayId) {
      setState(() => isLoading = true);
      alllistItem = await ListViewModel.instance.fetchData();
      Listdata =
          await ListViewModel.instance.fetchByGatewayId(widget.listdatas!);

      setState(() => isLoading = false);
    }
  }

  Future addNew() async {
    if (datas.isEmpty) {
      for (int i = 0; i <= Addchecklist!.length; i++) {
        final data = Addchecklist![i];
        DBSQL.instance.insert(data.toJson());
      }
    }
    for (int i = 0; i <= Addchecklist!.length; i++) {
      final data = Addchecklist![i];
      DBSQL.instance.updateChecklist(data);
    }
  }

  Future addList() async {
    if (Listdata!.isEmpty) {
      modelData!.projectName = widget.ProjectName;
      modelData!.deviceType = widget.Source;
      final data = modelData!;
      ListViewModel.instance.insert(data.toJson());
    } else {
      modelData!.projectName = widget.ProjectName;
      modelData!.deviceType = widget.Source;
      final data = modelData!;
      ListViewModel.instance.update(data);
    }
  }

  Future listdatacheckup() async {
    if (modelData!.omsId != 0) {
      await ListViewModel.instance.deleteOms(modelData!.omsId!);
    }
    if (modelData!.amsId != 0) {
      await ListViewModel.instance.deleteAms(modelData!.amsId!);
    }
    if (modelData!.rmsId != 0) {
      await ListViewModel.instance.deleteRms(modelData!.rmsId!);
    }
    if (modelData!.gateWayId != 0) {
      await ListViewModel.instance.deleteGateway(modelData!.gateWayId!);
    }
  }
}

class InsertObjectModel {
  String? processId;
  String? subProcessId;
  String? checkListData;
  String? deviceId;
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
