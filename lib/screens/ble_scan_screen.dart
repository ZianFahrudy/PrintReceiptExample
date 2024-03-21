import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class BleScanScreen extends StatefulWidget {
  BleScanScreen({Key? key}) : super(key: key);

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  // Get Printer List
  Future<void> startScan() async {
    await _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters();
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      log(event.map((e) => e.name).toList().toString());
      setState(() {
        printers = event;
        // printers.removeWhere((element) =>
        //     element.name == null ||
        //     element.name == '' ||
        //     !element.name!.toLowerCase().contains('print'));
      });
    });
  }

  void getUsbDevices() async {
    await _flutterThermalPrinterPlugin.getUsbDevices();
  }

  @override
  void initState() {
    // startScan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              startScan();
            },
            child: const Text('Get Printers'),
          ),
          Text(printers.length.toString()),
          Expanded(
            child: ListView.builder(
              itemCount: printers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    if (printers[index].isConnected ?? false) {
                      await _flutterThermalPrinterPlugin
                          .disconnect(printers[index]);
                    } else {
                      Printer();
                      final isConnected = await _flutterThermalPrinterPlugin
                          .connect(printers[index]);
                      log("Devices: $isConnected");
                    }
                  },
                  title: Text(printers[index].name ?? 'No Name'),
                  subtitle: Text(
                      "VendorId: ${printers[index].address} - Connected: ${printers[index].isConnected}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.connect_without_contact),
                    onPressed: () async {
                      final profile = await CapabilityProfile.load();
                      final generator = Generator(PaperSize.mm58, profile);
                      List<int> bytes = [];
                      bytes += generator.text(
                        'Maguwoharjo, Denokan, Depok Sub-District, Sleman Regency, Special Region of Yogyakarta',
                        styles: PosStyles(
                          align: PosAlign.center,
                          height: PosTextSize.size1,
                          width: PosTextSize.size1,
                        ),
                      );
                      bytes += generator.hr();
                      bytes += generator.hr(len: 1);
                      bytes += generator.row([
                        PosColumn(
                            text: 'Nota', width: 6, styles: const PosStyles()),
                        PosColumn(
                            text: "1/SO/ASM/FEB/2021",
                            width: 6,
                            styles: const PosStyles(align: PosAlign.right)),
                      ]);
                      bytes += generator.row([
                        PosColumn(
                            text: 'Date', width: 6, styles: const PosStyles()),
                        PosColumn(
                            text: '15 February 2021 00:00',
                            width: 6,
                            styles: const PosStyles(align: PosAlign.right)),
                      ]);

                      bytes += generator.row(
                        [
                          PosColumn(
                            text: 'Sub Total',
                            width: 6,
                            styles: const PosStyles(
                              align: PosAlign.left,
                              bold: true,
                            ),
                          ),
                          PosColumn(
                            text: '289.000',
                            width: 6,
                            styles: const PosStyles(
                              align: PosAlign.right,
                            ),
                          ),
                        ],
                      );

                      bytes += generator.cut();
                      await _flutterThermalPrinterPlugin.printData(
                        printers[index],
                        bytes,
                        longData: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
