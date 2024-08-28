import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_getdata/service/api_service.dart';

class HomePage extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String? token = await apiService.login('operational-melia@gmail.com', 'admin');
            if (token != null) {
              // Token berhasil didapatkan, ambil data asset inquiry
              await apiService.getAssetInquiry('E28069952000501172577268');
            } else {
              print('Failed to log in');
            }
          },
          child: Text('Login & Get Data'),
        ),
      ),
    );
  }
}