// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetProvider extends ChangeNotifier {
  final String versionNO = '0.0.1';

  late final Stream<String> connectionStream; // 👈 expose this
  String _connectionStatus = 'checking';
  String get connectionStatus => _connectionStatus;

  InternetProvider() {
    connectionStream =
        InternetConnection().onStatusChange.map((status) => status.name);
    connectionStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
    });
  }
}
