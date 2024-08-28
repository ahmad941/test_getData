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

        // Cek apakah 'accessToken' ada
        if (responseData == null || responseData['accessToken'] == null) {
          print('No access token found in response');
          return null;
        }

        final String token = responseData['accessToken'];
        print('Token received: $token');

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
    print('Fetching asset inquiry for tag: $tag');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print('No token found');
      return null;
    }

    final String assetInquiryUrl = '$baseUrl/1.0/asset-inquiry/$tag';
    print('Using token: $token');

    try {
      final response = await http.get(
        Uri.parse(assetInquiryUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}