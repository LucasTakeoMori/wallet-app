import 'package:flutter/material.dart';
import 'package:wallet_app/app.dart';
import 'package:wallet_app/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.initDatabaseFactory();
  runApp(const App());
}
