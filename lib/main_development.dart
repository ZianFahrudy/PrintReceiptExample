import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pos_print_example/app/app.dart';
import 'package:pos_print_example/bootstrap.dart';

void main() {

WidgetsFlutterBinding.ensureInitialized();

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

  bootstrap(() => const App());
}
