import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://recom-api.xacloud.com/api';

  Future<String?> login(String email, String password) async {
    final String loginUrl = '$baseUrl/1.4/auth/login';

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['accessToken'];

        // Simpan token di SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return token;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAssetInquiry(String tag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print('No token found');
      return null;
    }

    final String assetInquiryUrl = '$baseUrl/1.0/asset-inquiry/$tag';

    try {
      final response = await http.get(
        Uri.parse(assetInquiryUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Failed to get asset inquiry with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during asset inquiry: $e');
      return null;
    }
  }

  Future<String?> getImage(String assetCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print('No token found');
      return null;
    }

    final String imageUrl = '$baseUrl/1.4/image?asset_code=$assetCode';

    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        if (responseData.isNotEmpty) {
          return responseData[0]; // Mengakses URL gambar pertama dalam daftar
        } else {
          return null;
        }
      } else {
        print('Failed to get image with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during image fetch: $e');
      return null;
    }
  }



  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}