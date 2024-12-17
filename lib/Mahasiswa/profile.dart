import 'dart:io';
import 'package:firstapp/Mahasiswa/upload_kompetensi.dart';
import 'package:firstapp/Mahasiswa/kompetensi.dart';
import 'package:firstapp/controller/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../bottombar/bottombar.dart';
import 'riwayat.dart';
import 'pekerjaan.dart';
import '../mahasiswa.dart';
import '../widget/popup_logout.dart';
import '../config/config.dart';
import '../controller/profile_service.dart'; // Import ProfileService
import 'notifikasi.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  bool _isPasswordSectionVisible = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _profileImage;
  String _avatarUrl = '';
  String _nama = 'Your Name';
  String _username = 'Username';

  int _notificationCount = 0;


  int _selectedIndex = 3;


  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      return;
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RiwayatPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PekerjaanPage()),
      );
    } else if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MahasiswaDashboard()),
      );
    }
  }


  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      await _updatePhoto(); // Memperbarui foto profil
    }
  }

  // Update Password
  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password baru dan konfirmasi tidak cocok")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ProfileService().updatePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

    if (result == 'Password berhasil diperbarui') {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _isPasswordSectionVisible = false;
      });
    }
  }

  Future<void> _fetchNotificationCount() async {
  try {
    final userId = await AuthService().getUserId();
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${config.baseUrl}/mahasiswa/$userId/notifikasijumlah'), // Your endpoint for notification count
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the token if necessary
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _notificationCount = data['jumlah'];
      });
    } else {
      print('Failed to load notification count');
    }
  } catch (e) {
    print('Error fetching notification count: $e');
  }
}

   // Fungsi untuk memperbarui foto profil
  Future<void> _updatePhoto() async {
    if (_profileImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await ProfileService().updatePhoto(_profileImage!.path);

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));

    if (result == 'Foto profil berhasil diperbarui') {
      await _loadUserData(); // Perbarui data pengguna
    }
  }

  // Fungsi untuk memuat data pengguna dari SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarUrl = prefs.getString('avatarUrl') ?? '';
      _nama = prefs.getString('nama') ?? 'Your Name';
      _username = prefs.getString('username') ?? 'Username';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.blue[800],
                padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 30.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                               backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_avatarUrl.isNotEmpty
                                    ? NetworkImage(_avatarUrl)
                                    : const AssetImage(
                                        'assets/img/polinema.png') as ImageProvider),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_nama,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                        Text(_username,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app,
                          size: 30, color: Colors.red),
                      onPressed: () {
                        PopupLogout.showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              buildSection('Ganti Password', Icons.vpn_key, () {
                setState(() {
                  _isPasswordSectionVisible = !_isPasswordSectionVisible;
                });
              }),
              if (_isPasswordSectionVisible) buildPasswordForm(),
              buildSection('Daftar Kompetensi Mahasiswa', Icons.person_search,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KompetensiMahasiswaPage()));
              }),
              buildSection('Notifikasi', Icons.notification_add,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotifikasiMahasiswaPage()));
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        notificationCount: _notificationCount,
      ),
    );
  }

  // Helper methods
  Widget buildSection(String title, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 25),
          Text(title, style: GoogleFonts.poppins()),
          const Spacer(),
          if (title == 'Notifikasi' && _notificationCount > 0) // Only show if notification count is greater than 0
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_notificationCount', // Display the notification count
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


  Widget buildPasswordForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          buildPasswordField('Password Lama', _currentPasswordController,
              _isOldPasswordVisible),
          const SizedBox(height: 20), // Added spacing between fields
          buildPasswordField(
              'Password Baru', _newPasswordController, _isNewPasswordVisible),
          const SizedBox(height: 20), // Added spacing between fields
          buildPasswordField('Verifikasi Password Baru',
              _confirmPasswordController, _isConfirmPasswordVisible),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updatePassword,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 126, 211)),
            child:
                Text('Okay', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField(
      String label, TextEditingController controller, bool isPasswordVisible) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              if (label == 'Password Lama') {
                _isOldPasswordVisible = !_isOldPasswordVisible;
              } else if (label == 'Password Baru') {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              } else if (label == 'Verifikasi Password Baru') {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }
}
