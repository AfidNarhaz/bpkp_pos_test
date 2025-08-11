import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Untuk mengatur teks mulai dari kiri
            children: [
              Container(
                padding: EdgeInsets.all(16.0), // Jarak di dalam Container
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Warna latar belakang notifikasi
                  borderRadius:
                      BorderRadius.circular(8.0), // Membuat sudut melengkung
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Agar teks rata kiri
                  children: [
                    Text(
                      'Judul Informasi Notifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0, // Ukuran font judul
                      ),
                    ),
                    SizedBox(height: 8.0), // Memberi jarak antar teks
                    Text(
                      'Isi Informasi Notifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0, // Ukuran font isi
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
