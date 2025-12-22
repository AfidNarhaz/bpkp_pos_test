import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/home/notification/notification_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifikasiList = [];

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    final list = await DatabaseHelper().getNotifikasi();
    setState(() {
      // Convert ke list yang mutable (bisa diubah)
      _notifikasiList = List.from(list);
    });
  }

  // Fungsi untuk determine tipe notifikasi
  String _getNotificationType(String judul) {
    // Check 'Akan Kadaluarsa' lebih dulu sebelum 'Kadaluarsa'
    if (judul.contains('Akan Kadaluarsa')) {
      return 'expiring_soon'; // Produk akan kadaluarsa
    } else if (judul.contains('Kadaluarsa')) {
      return 'expired'; // Produk sudah kadaluarsa
    } else if (judul.contains('Minimal')) {
      return 'minimal_stock'; // Stok produk minimal
    }
    return 'unknown';
  }

  // Fungsi untuk delete notifikasi
  Future<void> _deleteNotifikasi(int index) async {
    try {
      final notif = _notifikasiList[index];
      final notifId = notif['id'];

      if (notifId != null) {
        await DatabaseHelper().deleteNotifikasi(notifId);

        // Remove dari list lokal
        setState(() {
          _notifikasiList.removeAt(index);
        });

        // Show snackbar konfirmasi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi dihapus'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error deleting notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus notifikasi: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _notifikasiList.isEmpty
            ? const Center(child: Text('Belum ada notifikasi'))
            : ListView.builder(
                itemCount: _notifikasiList.length,
                itemBuilder: (context, index) {
                  final notif = _notifikasiList[index];
                  final notificationType =
                      _getNotificationType(notif['judul'] ?? '');

                  // Format tanggal
                  String formattedDate = '';
                  if (notif['tanggal'] != null) {
                    try {
                      final dateTime =
                          DateTime.parse(notif['tanggal'].toString());
                      formattedDate =
                          DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
                    } catch (e) {
                      formattedDate = notif['tanggal'].toString();
                    }
                  }

                  return Dismissible(
                    key: Key(notif['id'].toString()),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      _deleteNotifikasi(index);
                    },
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate ke notification detail dengan tipe notifikasi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailPage(
                              notificationType: notificationType,
                              notificationTitle: notif['judul'] ?? 'Notifikasi',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(notificationType),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(51),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif['judul'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _getNotificationIcon(notificationType),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              notif['stok'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Fungsi untuk mendapatkan warna berdasarkan tipe notifikasi
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'expired':
        return Colors.red[400]!;
      case 'expiring_soon':
        return Colors.orange[400]!;
      case 'minimal_stock':
        return Colors.amber[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  // Fungsi untuk mendapatkan icon berdasarkan tipe notifikasi
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'expired':
        return Icons.warning;
      case 'expiring_soon':
        return Icons.schedule;
      case 'minimal_stock':
        return Icons.inventory_2;
      default:
        return Icons.notifications;
    }
  }
}
