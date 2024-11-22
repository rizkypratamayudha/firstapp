import 'dart:convert';
import 'package:firstapp/Model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class AuthService {
  final _storage = FlutterSecureStorage();

  // Fungsi login
Future<Map<String, dynamic>> login(
    String username, String password, String role) async {
  final url = Uri.parse('${config.baseUrl}/loginAPI');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    // Log respons server untuk debugging
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['success'] == true) {
        // Simpan token
        // Simpan token di FlutterSecureStorage
        await _storage.write(key: 'token', value: responseData['token']);

        // Simpan data user lain di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', responseData['user']['name']);
        await prefs.setString('username', responseData['user']['username']);
        await prefs.setInt('userId', responseData['user']['id']);
        await prefs.setString('user_id',
            responseData['user']['id'].toString()); // Simpan user_id sebagai string
        await prefs.setString('avatarUrl', responseData['user']['avatar']); // Simpan avatar URL

        final user = UserModel.fromJson(responseData['user']);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': responseData['message']};
      }
    } else {
      // Tangani status kode selain 200
      return {
        'success': false,
        'message': responseData['message'] ??
            'Terjadi kesalahan, silakan coba lagi'
      };
    }
  } catch (error) {
    print('Error: $error');
    return {
      'success': false,
      'message': 'Tidak dapat terhubung ke server. Periksa koneksi Anda.'
    };
  }
}

  // Mendapatkan token dari FlutterSecureStorage
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data pengguna di SharedPreferences
    await _storage.delete(key: 'token');
  }
}
