// ignore_for_file: unused_local_variable, file_names, non_constant_identifier_names

import 'package:ecm_application/Model/Project/ECMTool/ECM_Checklist_Model.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSChackListModel.dart';
import 'package:ecm_application/Model/Project/ECMTool/PMSListViewModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBSQL {
  static const _databaseName = "SQLDbsss.db3";
  static const _databaseVersion = 1;
  static const table = 'SQL_tbl';

  DBSQL._privateConstructor();
  static final DBSQL instance = DBSQL._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        processId INTEGER,
        subProcessId INTEGER,
        checkListId INTEGER,
        description TEXT,
        seqNo INTEGER,
        inputType TEXT,
        inputText TEXT,
        value TEXT,
        subProcessName TEXT,
        processName TEXT,
        approvedStatus INTEGER,
        workedBy INTEGER,
        workedOn TEXT,
        approvedBy INTEGER,
        approvedOn TEXT,
        tempDT TEXT,
        remark TEXT,
        approvalRemark TEXT,
        isMultiValue INTEGER,
        subChakQty INTEGER,
        deviceType TEXT,
        downlink TEXT,
        macAddress TEXT,
        subscribeTopicName TEXT,
        parameterName TEXT,
        comment TEXT,
        coordinate TEXT,
        dataType TEXT,
        source TEXT,
        deviceId INTEGER,
        conString TEXT,
        userId INTEGER,
        siteTeamEngineer TEXT,
        imageByteArray TEXT,
        issaved TEXT,
        image BLOB,
        issiteTeamEngineer INTEGER,
        IsBullet INTEGER,
        IsBulletHeader INTEGER
      )
    ''');
    print("DBSQL Database table created ✅");
  }

  /// Insert
  Future<void> insert(Map<String, dynamic> value) async {
    final db = await database;
    await db.insert(table, value);
  }

  /// Update
  Future<void> updateChecklist(ECM_Checklist_Model value) async {
    final db = await database;
    await db.update(
      table,
      value.toJson(),
      where: 'checkListId = ? AND deviceId = ?',
      whereArgs: [value.checkListId, value.deviceId],
    );
  }

  /// Delete
  Future<void> deleteChecklist(ECM_Checklist_Model value) async {
    final db = await database;
    await db.delete(
      table,
      where: 'checkListId = ? AND deviceId = ? AND subProcessId = ?',
      whereArgs: [value.checkListId, value.deviceId, value.subProcessId],
    );
  }

  /// Universal fetch helper
  Future<List<ECM_Checklist_Model>> fetchData(
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final maps = await db.query(table, where: where, whereArgs: whereArgs);
    return maps.map((e) => ECM_Checklist_Model.fromJson(e)).toList();
  }

  /// Examples of usage
  Future<List<ECM_Checklist_Model>> fetchAll() => fetchData();

  Future<List<ECM_Checklist_Model>> fetchByDevice(int deviceId) =>
      fetchData(where: 'deviceId = ?', whereArgs: [deviceId]);

  Future<List<ECM_Checklist_Model>> fetchByProcess(
          int deviceId, int processId) =>
      fetchData(
          where: 'deviceId = ? AND processId = ?',
          whereArgs: [deviceId, processId]);

  Future<List<ECM_Checklist_Model>> fetchByType(
          int deviceId, int processId, String deviceType) =>
      fetchData(
          where: 'deviceId = ? AND processId = ? AND deviceType = ?',
          whereArgs: [deviceId, processId, deviceType]);

  /// Delete by device+process
  Future<void> deleteByDeviceProcess(int deviceId, int processId) async {
    final db = await database;
    await db.delete(table,
        where: 'deviceId = ? AND processId = ?',
        whereArgs: [deviceId, processId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

class ListViewModel {
  static const _databaseName = "PMS.db3";
  static const _databaseVersion = 1; // <-- you forgot this

  final String table = 'New_tbl';
  ListViewModel._privateConstructor();
  static final ListViewModel instance = ListViewModel._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
  CREATE TABLE $table (
    OmsId INTEGER,
    ChakNo TEXT,
    AmsId INTEGER,
    AmsNo TEXT,
    RmsId INTEGER,
    RmsNo TEXT,
    IsChecking TEXT,
    GateWayId INTEGER,
    GatewayNo TEXT,
    GatewayName TEXT,
    Process1 TEXT,
    Process2 TEXT,
    Process3 TEXT,
    Process4 TEXT,
    Process5 TEXT,
    Process6 TEXT,
    AreaName TEXT,
    Description TEXT,
    Mechanical TEXT,
    Erection TEXT,
    DryCommissioning TEXT,
    WetCommissioning TEXT,
    projectName TEXT,
    Trenching TEXT,
    PipeInatallation TEXT,
    AutoDryCommissioning TEXT,
    AutoWetCommissioning TEXT,
    Chainage TEXT,
    Coordinates TEXT,
    NetworkType TEXT,
    DeviceType TEXT,
    deviceId TEXT,
    deviceNo TEXT,
    deviceName TEXT,
    isSelected TEXT
  );
""");
    print("ListViewModel Database table created ✅");
  }

  // ---------------- CRUD ---------------- //

  Future<void> insert(Map<String, dynamic> value) async {
    final db = await database;
    await db.insert(table, value);
    print("Inserted data ✅");
  }

  Future<void> update(PMSListViewModel value) async {
    final db = await database;
    await db.update(
      table,
      value.toJson(),
      where: 'omsId = ?',
      whereArgs: [value.omsId],
    );
  }

  // Generic fetch function
  Future<List<PMSListViewModel>> fetchData(
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final maps = await db.query(table, where: where, whereArgs: whereArgs);

    return maps.map((map) => PMSListViewModel.fromJson(map)).toList();
  }

  // Specific fetch shortcuts
  Future<List<PMSListViewModel>> fetchAll() => fetchData();
  Future<List<PMSListViewModel>> fetchByOmsId(int omsId) =>
      fetchData(where: "omsId = ?", whereArgs: [omsId]);
  Future<List<PMSListViewModel>> fetchByAmsId(int amsId) =>
      fetchData(where: "amsId = ?", whereArgs: [amsId]);
  Future<List<PMSListViewModel>> fetchByRmsId(int rmsId) =>
      fetchData(where: "rmsId = ?", whereArgs: [rmsId]);
  Future<List<PMSListViewModel>> fetchByGatewayId(int gatewayId) =>
      fetchData(where: "gateWayId = ?", whereArgs: [gatewayId]);
  Future<List<PMSListViewModel>> fetchByProjectAndDevice(
          String projectName, String deviceType) =>
      fetchData(
          where: "projectName = ? AND deviceType = ?",
          whereArgs: [projectName, deviceType]);

  // Generic delete
  Future<void> deleteBy(String column, int id) async {
    final db = await database;
    await db.delete(table, where: '$column = ?', whereArgs: [id]);
  }

  Future<void> deleteOms(int id) => deleteBy("omsId", id);
  Future<void> deleteAms(int id) => deleteBy("amsId", id);
  Future<void> deleteRms(int id) => deleteBy("rmsId", id);
  Future<void> deleteGateway(int id) => deleteBy("gateWayId", id);

  Future<void> clearTable() async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

class ListModel {
  static const _databaseName = "PMSlist.db3";
  static const _databaseVersion = 1;
  static const table = 'pmslist_tbl';

  ListModel._privateConstructor();
  static final ListModel instance = ListModel._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checkListId INTEGER,
        subProcessId INTEGER,
        processId INTEGER,
        description TEXT,
        seqNo TEXT,
        inputType TEXT,
        inputText TEXT,
        value INTEGER,
        subProcessName TEXT,
        processName TEXT,
        approvedStatus INTEGER,
        workedBy INTEGER,
        workedOn TEXT,
        approvedBy INTEGER,
        approvedOn TEXT,
        tempDT TEXT,
        remark TEXT,
        approvalRemark TEXT,
        imageByteArray TEXT,
        isMultiValue TEXT,
        subChakQty TEXT,
        deviceType TEXT,
        downlink TEXT,
        macAddress TEXT,
        subscribeTopicName TEXT,
        parameterName TEXT,
        comment TEXT,
        dataType TEXT,
        source TEXT,
        deviceId INTEGER,
        conString TEXT,
        userId INTEGER,
        siteTeamEngineer INTEGER,
        IsBullet INTEGER,
        IsBulletHeader INTEGER
      )
    ''');
    print("✅ ListModel Database table created: $table");
  }

  // Insert single row
  Future<void> insert(Map<String, dynamic> value) async {
    final db = await database;
    await db.insert(table, value, conflictAlgorithm: ConflictAlgorithm.replace);
    print("✅ Inserted data into $table");
  }

  // Update row by checkListId
  Future<void> update(PMSChaklistModel value) async {
    final db = await database;
    await db.update(
      table,
      value.toJson(),
      where: 'checkListId = ?',
      whereArgs: [value.checkListId],
    );
    print("✅ Updated row with checkListId=${value.checkListId}");
  }

  // Fetch rows (excluding "All Process")
  Future<List<PMSChaklistModel>> fetchAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: "processName NOT LIKE ?",
      whereArgs: ['%All Process%'],
    );

    return maps.map((map) => PMSChaklistModel.fromJson(map)).toList();
  }

  // Delete everything
  Future<void> clearTable() async {
    final db = await database;
    await db.delete(table);
    print("🗑️ Cleared all data from $table");
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
