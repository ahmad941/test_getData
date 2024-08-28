import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_getdata/service/api_service.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  Future<Map<String, dynamic>?>? _assetData;
  String _scanResult = '';

  Future<void> _loginAndFetchData(String tag) async {
    String? token = await apiService.login('operational-melia@gmail.com', 'admin');
    if (token != null) {
      setState(() {
        _assetData = apiService.getAssetInquiry(tag);
      });
    } else {
      print('Failed to log in');
    }
  }

  Future<void> _scanBarcode() async {
    try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', // Warna garis pemindai
        'Cancel',  // Teks untuk tombol pembatalan
        true,      // Menampilkan tombol untuk membuka lampu
        ScanMode.BARCODE,
      );
      if (scanResult != '-1') {
        setState(() {
          _scanResult = scanResult;
          _loginAndFetchData(scanResult);
        });
      }
    } catch (e) {
      print('Error during barcode scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Scan Barcode'),
            ),
            SizedBox(height: 20),
            Text('Scan Result: $_scanResult'),
            SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>?>(
              future: _assetData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final data = snapshot.data;
                  if (data != null) {
                    return Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16.0),
                        children: [
                          ListTile(
                            title: Text('Asset ID'),
                            subtitle: Text(data['asset_id'].toString()),
                          ),
                          ListTile(
                            title: Text('Asset Name'),
                            subtitle: Text(data['asset_name'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Asset Code'),
                            subtitle: Text(data['asset_code'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Serial Number'),
                            subtitle: Text(data['serial_number'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Item Number'),
                            subtitle: Text(data['item_number'] ?? ''),
                          ),
                          ListTile(
                            title: Text('PIC Name'),
                            subtitle: Text(data['pic_name'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Item Status'),
                            subtitle: Text(data['item_status'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Location Name'),
                            subtitle: Text(data['location_name'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Sub Location Name'),
                            subtitle: Text(data['sub_location_name'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Sub-Sub Location Name'),
                            subtitle: Text(data['sub_sub_location_name'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Tag'),
                            subtitle: Text(data['tag'] ?? ''),
                          ),
                          ListTile(
                            title: Text('Color Code'),
                            subtitle: Text(data['color_code'] ?? ''),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('No data available');
                  }
                } else {
                  return Text('No data available');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}