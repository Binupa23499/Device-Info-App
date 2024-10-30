import 'dart:io'; // Import for platform checks
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Gen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRGenPage(),
    );
  }
}

class QRGenPage extends StatefulWidget {
  const QRGenPage({super.key});

  @override
  State<QRGenPage> createState() => _QRGenPageState();
}

class _QRGenPageState extends State<QRGenPage> {
  String _deviceInfo = 'Fetching device info...';

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  Future<void> _fetchDeviceInfo() async {
    // Request permission for accessing phone state to get IMEI
    if (await Permission.phone.request().isGranted) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        String deviceData = 'Unknown device';
        String? deviceSerial;
        String? deviceImei;

        final androidInfo = await deviceInfo.androidInfo;

        // IMEI and Serial Number Fallbacks
        if (Platform.isAndroid) {
          deviceImei = androidInfo.id; // Unique ID as IMEI fallback
          deviceSerial = androidInfo.serialNumber ?? androidInfo.id; // Serial Number or unique ID
        } else {
          deviceImei = "Not available";
          deviceSerial = "Not available";
        }

        // Build device data string
        deviceData = 'Brand: ${androidInfo.brand}\n'
            'Model: ${androidInfo.model}\n'
            'IMEI/Unique ID: $deviceImei\n'
            'Serial Number: $deviceSerial\n'
            'Android Version: ${androidInfo.version.release}';

        if (mounted) {
          setState(() {
            _deviceInfo = deviceData;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _deviceInfo = 'Failed to retrieve device info: $e';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _deviceInfo = 'Permission denied. Cannot access device information.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scan This QR:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            //Text(_deviceInfo),
            const SizedBox(height: 20),
            QrImageView(
              data: _deviceInfo,       // Pass the device information here
              version: QrVersions.auto, // Automatically adjusts version based on data size
              size: 200.0,              // Adjusts QR size
            ),
          ],
        ),
      ),
    );
  }
}
