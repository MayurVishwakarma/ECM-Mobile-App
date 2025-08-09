import 'package:ecm_application/Model/Project/ECMTool/ECM_Checklist_Model.dart';
import 'package:ecm_application/core/utils/translate_helper.dart';
import 'package:flutter/material.dart';
import 'package:ecm_application/Services/RestPmsService.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  bool _isHindi = false;

  List<ECM_Checklist_Model>? checkList;
  List<String> _originalDescriptions = []; // Store original English texts

  @override
  void initState() {
    super.initState();
    GetCheckList();
  }

  void GetCheckList() {
    getECMCheckListByProcessId(199, 1, 'OMS').then((value) {
      setState(() {
        checkList = value;
        // Store original descriptions for re-translation
        _originalDescriptions =
            value.map((item) => item.description ?? '').toList();
      });
    });
  }

  Future<void> _toggleTranslation() async {
    setState(() {
      _isHindi = !_isHindi;
    });

    if (_isHindi) {
      // Translate each checklist item description to Hindi
      if (checkList != null) {
        for (int i = 0; i < checkList!.length; i++) {
          String translated = await TranslationHelper.translateToHindi(
              _originalDescriptions[i]);
          checkList![i].description = translated;
        }
      }
    } else {
      // Revert to original English descriptions
      for (int i = 0; i < _originalDescriptions.length; i++) {
        checkList![i].description = _originalDescriptions[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Translate Demo"),
        actions: [
          Switch(
            value: _isHindi,
            onChanged: (value) => _toggleTranslation(),
          ),
        ],
      ),
      body: checkList == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: checkList!.length,
              itemBuilder: (context, index) {
                final item = checkList![index];
                return ListTile(
                  title: Text(item.description ?? 'No Name'),
                  subtitle: Text('ID: ${item.checkListId}'),
                );
              },
            ),
    );
  }
}
