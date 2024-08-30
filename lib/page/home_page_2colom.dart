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
  Future<String?>? _assetImage;
  String _scanResult = '';

  Future<void> _loginAndFetchData(String tag) async {
    String? token = await apiService.login('operational-melia@gmail.com', 'admin');
    if (token != null) {
      setState(() {
        _assetData = apiService.getAssetInquiry(tag);
        _assetData?.then((data) {
          if (data != null && data.containsKey('asset_code')) {
            _assetImage = apiService.getImage(data['asset_code']);
          }
        });
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _scanBarcode,
                child: Text('Scan Barcode'),
              ),
              SizedBox(height: 10), // Lebih rapat
              Text('Scan Result: $_scanResult'),
              SizedBox(height: 10), // Lebih rapat
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
                      return Column(
                        children: [
                          _buildDataTile('Asset ID', data['asset_id']?.toString() ?? 'N/A'),
                          _buildDataTile('Asset Name', data['asset_name'] ?? 'N/A'),
                          _buildDataTile('Asset Code', data['asset_code'] ?? 'N/A'),
                          _buildDataTile('Serial Number', data['serial_number'] ?? 'N/A'),
                          _buildDataTile('Item Number', data['item_number'] ?? 'N/A'),
                          _buildDataTile('PIC Name', data['pic_name'] ?? 'N/A'),
                          _buildDataTile('Item Status', data['item_status'] ?? 'N/A'),
                          _buildDataTile('Location Name', data['location_name'] ?? 'N/A'),
                          _buildDataTile('Sub Location Name', data['sub_location_name'] ?? 'N/A'),
                          _buildDataTile('Sub-Sub Location Name', data['sub_sub_location_name'] ?? 'N/A'),
                          _buildDataTile('Tag', data['tag'] ?? 'N/A'),
                          _buildDataTile('Color Code', data['color_code'] ?? 'N/A'),
                          SizedBox(height: 10), // Lebih rapat
                          FutureBuilder<String?>(
                            future: _assetImage,
                            builder: (context, imageSnapshot) {
                              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (imageSnapshot.hasError) {
                                return Text('Error: ${imageSnapshot.error}');
                              } else if (imageSnapshot.hasData && imageSnapshot.data != null) {
                                return Container(
                                  width: 200, // Lebih kecil
                                  height: 200, // Lebih kecil
                                  child: Image.network(
                                    imageSnapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return Text('No Image Available');
                              }
                            },
                          ),
                        ],
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
      ),
    );
  }

  Widget _buildDataTile(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0), // Lebih rapat
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}