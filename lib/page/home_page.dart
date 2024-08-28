import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_getdata/service/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  Future<Map<String, dynamic>?>? _assetData;

  Future<void> _loginAndFetchData() async {
    String? token = await apiService.login('operational-melia@gmail.com', 'admin');
    if (token != null) {
      // Token berhasil didapatkan, ambil data asset inquiry
      setState(() {
        _assetData = apiService.getAssetInquiry('E28069952000501172577268');
      });
    } else {
      print('Failed to log in');
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
              onPressed: _loginAndFetchData,
              child: Text('Login & Get Data'),
            ),
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