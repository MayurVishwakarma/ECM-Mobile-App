// ignore_for_file: non_constant_identifier_names, camel_case_types, must_be_immutable, file_names

import 'package:ecm_application/Model/Project/ECMTool/ECM_Checklist_Model.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSListViewModel.dart';
import 'package:ecm_application/core/SQLite/DbHepherSQL.dart';
import 'package:flutter/material.dart';

class MySql_Screen extends StatefulWidget {
  int? processId;
  int? deviceId;
  String? ProjectName;
  String? Source;
  PMSListViewModel? modelDatas;

  MySql_Screen(
      {super.key,
      this.modelDatas,
      this.ProjectName,
      this.Source,
      this.processId,
      this.deviceId});

  @override
  State<MySql_Screen> createState() => _MySql_ScreenState();
}

class _MySql_ScreenState extends State<MySql_Screen> {
  List<PMSListViewModel> Listdata = [];
  List<ECM_Checklist_Model> datas = [];
  List<PMSChaklistModel> listdistinctProcesss = [];
  @override
  void initState() {
    super.initState();
    getOfflineData();
  }

  void getOfflineData() async {
    try {
      if (widget.Source == 'oms') {
        fatchFirstloadOms(widget.deviceId ?? 0);
      }
      /* else if (widget.Source == 'rms') {
        fatchFirstloadRms(widget.deviceId!);
      } else if (widget.Source == 'ams') {
        fatchFirstloadAms(widget.deviceId!);
      } else if (widget.Source == 'lora') {
        fatchFirstloadLora(widget.deviceId!);
      }*/
    } catch (e) {
      print('Error fetching offline data: $e');
      throw Exception('Error fetching offline data: $e');
    }
  }

  //oms
  Future fatchFirstloadOms(int omsid) async {
    Listdata = await ListViewModel.instance.fetchByOmsId(omsid);
    listdistinctProcesss = await ListModel.instance.fetchAll();

    datas = await DBSQL.instance.fetchByDevice(omsid);
  }

/*  //ams
  Future fatchFirstloadAms(int amsid) async {
    if (amsid != 0) {
      setState(() => isLoading = true);
      Listdata = await ListViewModel.instance.fetchByAmsId(amsid);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datas = await DBSQL.instance.fetchByDevice(amsid);
      await firstLoad();
      setState(() => isLoading = false);
    }
  }

  //lora
  Future fatchFirstloadLora(int getwayid) async {
    if (getwayid != 0) {
      setState(() => isLoading = true);
      // datas11 = await DBSQL.instance.fatchdataSQLNew();
      Listdata = await ListViewModel.instance.fetchByGatewayId(getwayid);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datas = await DBSQL.instance.fetchByDevice(getwayid);
      await firstLoad();
      setState(() => isLoading = false);
    }
  }

  //rms
  Future fatchFirstloadRms(int rmsid) async {
    if (rmsid != 0) {
      setState(() => isLoading = true);
      // datas11 = await DBSQL.instance.fatchdataSQLNew();
      Listdata = await ListViewModel.instance.fetchByRmsId(rmsid);
      listdistinctProcesss = await ListModel.instance.fetchAll();
      datas = await DBSQL.instance.fetchByDevice(rmsid);
      await firstLoad();
      setState(() => isLoading = false);
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline ${widget.ProjectName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  final item = listdistinctProcesss[index];

                  return ListTile(
                    leading: Text("${index + 1}"),
                    title: Text(item.processName.toString()),
                    subtitle: Text(item.subProcessName.toString()),
                  );
                },
                itemCount: listdistinctProcesss.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics()),
          ),
        ],
      ),
    );
  }
}
