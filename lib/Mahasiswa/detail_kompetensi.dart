import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/kompetensi_service.dart';

class DetailKompetensiMahasiswa extends StatefulWidget {
  final int kompetensiId;

  const DetailKompetensiMahasiswa({super.key, required this.kompetensiId});

  @override
  State<DetailKompetensiMahasiswa> createState() =>
      _DetailKompetensiMahasiswaState();
}

class _DetailKompetensiMahasiswaState extends State<DetailKompetensiMahasiswa> {
  String nama = '';
  String nim = '';
  String periode = '';
  int periodeId = 0;

  String kompetensiNama = '';
  String pengalaman = '';
  String bukti = '';
  String errorMessage = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetailKompetensiMahasiswa();
  }

  Future<void> _loadDetailKompetensiMahasiswa() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nama = prefs.getString('nama') ?? 'User';
      nim = prefs.getString('username') ?? 'Username';
    });

    int userId = prefs.getInt('userId') ?? 0;

    try {
      if (userId != 0) {
        // Fetch periode data
        var periodeData =
            await KompetensiService().fetchPeriodeByUserId(userId);

        // Fetch kompetensi detail
        var kompetensiDetail =
            await KompetensiService().fetchKompetensiDetail(widget.kompetensiId);

        setState(() {
          periodeId = periodeData['periode_id'] ?? 0;
          periode = periodeData['periode'] ?? 'Periode Tidak Ditemukan';
          kompetensiNama = kompetensiDetail?.kompetensiNama ?? 'Tidak Tersedia';
          pengalaman = kompetensiDetail?.pengalaman ?? 'Tidak Tersedia';
          bukti = kompetensiDetail?.bukti ?? 'Tidak Tersedia';
        });
      } else {
        throw Exception("User ID tidak ditemukan.");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildBoxLihatDetailKompetensi(String title, String description) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Container
          Container(
            width: double.infinity,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFF4D03F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Description Container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 60,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1A6FD3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Kompetensi',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.poppins(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        buildBoxLihatDetailKompetensi("Nama", nama),
                        const SizedBox(height: 8),
                        buildBoxLihatDetailKompetensi("NIM", nim),
                        const SizedBox(height: 8),
                        buildBoxLihatDetailKompetensi("Periode", periode),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.black, thickness: 3),
                        const SizedBox(height: 8),
                        buildBoxLihatDetailKompetensi(
                            "Kompetensi", kompetensiNama),
                        const SizedBox(height: 8),
                        buildBoxLihatDetailKompetensi(
                            "Pengalaman", pengalaman),
                        const SizedBox(height: 8),
                        buildBoxLihatDetailKompetensi("Bukti", bukti),
                      ],
                    ),
                  ),
                ),
    );
  }
}
