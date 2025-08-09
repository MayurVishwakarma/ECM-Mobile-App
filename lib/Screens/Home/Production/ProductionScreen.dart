// ignore_for_file: avoid_print, unused_local_variable, use_build_context_synchronously, use_super_parameters, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssemblyUpload extends StatefulWidget {
  final String projectName; // Make it a required final field

  const AssemblyUpload({Key? key, required this.projectName}) : super(key: key);

  @override
  State<AssemblyUpload> createState() => _AssemblyUploadState();
}

class _AssemblyUploadState extends State<AssemblyUpload> {
  List<List<String>> fileData = [];
  String? fileType;

  @override
  void initState() {
    super.initState();
    // getDataString(); // Call the function when the widget initializes
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;

      if (filePath != null) {
        if (filePath.endsWith('.csv')) {
          await _parseCsv(filePath);
        } else if (filePath.endsWith('.xlsx') || filePath.endsWith('.xls')) {
          await _parseExcel(filePath);
        }
      }
    }
  }

  Future<void> _parseCsv(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    setState(() {
      fileType = "CSV";
      fileData = rows
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList();
    });
  }

  Future<void> _parseExcel(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    List<List<String>> tempData = [];
    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows ?? [];
      for (var row in rows) {
        tempData.add(row.map((cell) => cell?.value?.toString() ?? "").toList());
      }
    }

    setState(() {
      fileType = "Excel";
      fileData = tempData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assembly Test - ${widget.projectName}'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: pickFile,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file_outlined),
                    Text('Please select a CSV or Excel file to upload'),
                  ],
                ),
              ),
            ),
            if (fileType != null)
              Text(
                'File Type: $fileType',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (fileData.isNotEmpty) Divider(),
            if (fileData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal scroll
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Vertical scroll
                    child: DataTable(
                      columns: fileData.first
                          .map((header) => DataColumn(
                              label: Text(header,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))))
                          .toList(),
                      rows: fileData.skip(1).map((row) {
                        return DataRow(
                            cells: row
                                .map((cell) => DataCell(Text(cell)))
                                .toList());
                      }).toList(),
                    ),
                  ),
                ),
              ),
            if (fileData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () {
                        connect(context, fileData);
                      },
                      child: const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              "Upload Data On ECM Server",
                              // style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ))),
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> connect(BuildContext context, List<List<String>> data) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      // Insert multiple rows into tbl_ECM_Production
      for (var row in data.skip(1)) {
        if (row.length < 15) {
          print("Skipping row, not enough columns: $row");
          continue;
        }

        String deviceId = "${row[0]}";
        String macId = row[1];
        int batchNo = int.tryParse(row[2]) ?? 0;
        String inletPT0bar = row[3];
        String outletPT0bar = row[4];
        String pt0bar = row[5];
        String inletPT2bar = row[6];
        String outletPT2bar = row[7];
        String pt2bar = row[8];
        String positionSensor = row[9];
        String solenoid = row[10];
        int doorStatus = int.tryParse(row[11]) ?? 0;
        int rtcStatus = int.tryParse(row[12]) ?? 0;
        int flashStatus = int.tryParse(row[13]) ?? 0;
        int doneBy = int.tryParse(row[14]) ?? 0;

        // Handling date parsing correctly
        DateTime? doneOn;
        try {
          String formattedDate = row[15].replaceAll("T", " ");
          final dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
          doneOn = dateFormat.parse(formattedDate);
        } catch (e) {
          print("Date parsing error for row ${row[15]}: $e");
          continue; // Skip this row if date parsing fails
        }

        // Convert to MySQL-compatible format
        String mysqlDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(doneOn);

        Map<String, dynamic> jsondata = {
          "deviceId": deviceId,
          "macId": macId,
          "batchNo": batchNo,
          "inletPT0bar": inletPT0bar,
          "outletPT0bar": outletPT0bar,
          "pt0bar": pt0bar,
          "inletPT2bar": inletPT2bar,
          "outletPT2bar": outletPT2bar,
          "pt2bar": pt2bar,
          "positionSensor": positionSensor,
          "solenoid": solenoid,
          "doorStatus": doorStatus,
          "rtcStatus": rtcStatus,
          "flashStatus": flashStatus,
          "doneBy": doneBy,
          "doneOn": mysqlDate,
        };

        await uploadData(jsondata, conString);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data inserted successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('MySQL Query Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Some thing went wrong! Probably due to incorrect data"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> uploadData(
      Map<String, dynamic> jsonPaylod, String? conString) async {
    var dio = Dio();
    var response = await dio.request(
      'http://wmsservices.seprojects.in/api/Project/InsertProductionDetails?conString=$conString',
      options: Options(
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonPaylod,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      return response.data;
    } else {
      print(response.statusMessage);
    }
  }

/*
  Future<void> connect(List<List<String>> data) async {
    final conn = await MySQLConnection.createConnection(
      host: hostip,
      port: 3306,
      userName: userName!,
      password: password!,
      databaseName: databaseName,
    );

    await conn.connect();

    if (!conn.connected) {
      print("❌ Failed to connect to MySQL");
      return;
    }
    print("✅ Connected to MySQL");

    try {
      // 2️⃣ Insert multiple rows into Assembly_Table
      for (var row in data.skip(1)) {
        if (row.length < 12) {
          print("❌ Skipping row, not enough columns: $row");
          continue;
        }

        int deviceId = int.tryParse(row[0]) ?? 0;
        String macId = row[1] ?? "";
        int batchNo = int.tryParse(row[2]) ?? 0;
        String inletPT0bar = row[3] ?? "";
        String outletPT0bar = row[4] ?? "";
        String pt0bar = row[5] ?? "";
        String inletPT2bar = row[6] ?? "";
        String outletPT2bar = row[7] ?? "";
        String pt2bar = row[8] ?? "";
        String positionSensor = row[9] ?? "";
        String solenoid = row[10] ?? "";
        int doorStatus = int.tryParse(row[11]) ?? 0;
        int rtcStatus = int.tryParse(row[12]) ?? 0;
        int doneBy = int.tryParse(row[13]) ?? 0;
        final dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss"); // Adjust format
        var doneOn = dateFormat.parse(row[14].toString(), true);
        print(doneOn);
        // var doneOn = DateTime.tryParse(row[14]);

        // Construct query with direct values
        String query = '''
    INSERT INTO tbl_ECM_Production (DeviceId,MacId,BatchNo,Inlet_PT_0bar,Outlet_PT_0bar,PT_0bar,Inlet_PT_2bar,Outlet_PT_2bar,PT_2bar,Position_Sensor,Solenoid,Door_Status,RTC_Status,DoneBy,DoneOn) values 
          ( $deviceId , '$macId', $batchNo, '$inletPT0bar', '$outletPT0bar', '$pt0bar',
            '$inletPT2bar', '$outletPT2bar', '$pt2bar', '$positionSensor',
            '$solenoid', $doorStatus, $rtcStatus, $doneBy, '$doneOn');
            ''';

        await conn.execute(query);
        // print("✅ Row inserted successfully: $row");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Data inserted successfully!"),
          backgroundColor: Colors.green.shade300,
          duration: Duration(seconds: 3),
        ),
      );
      print("✅ Data inserted successfully!");
    } catch (e) {
      print('❌ MySQL Query Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'❌ MySQL Query Error: $e'"),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      await conn.close();
      print("✅ MySQL Connection Closed");
    }
  }
*/
}
