import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatefulWidget {
  final String notificationType;
  final String notificationTitle;

  const NotificationDetailPage({
    super.key,
    required this.notificationType,
    required this.notificationTitle,
  });

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  List<Produk> _produktList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduks();
  }

  Future<void> _loadProduks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Produk> produkList = [];

      switch (widget.notificationType) {
        case 'expired':
          produkList = await DatabaseHelper().getProdukSudahExpired();
          break;
        case 'expiring_soon':
          produkList = await DatabaseHelper().getProdukHampirExpired(days: 7);
          break;
        case 'minimal_stock':
          produkList = await DatabaseHelper().getProdukMinimalStok();
          break;
        default:
          produkList = [];
      }

      setState(() {
        _produktList = produkList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getDetailTitle() {
    switch (widget.notificationType) {
      case 'expired':
        return 'Produk Sudah Kadaluarsa';
      case 'expiring_soon':
        return 'Produk Akan Kadaluarsa';
      case 'minimal_stock':
        return 'Produk Stok Minimal';
      default:
        return 'Detail Notifikasi';
    }
  }

  Color _getHeaderColor() {
    switch (widget.notificationType) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _getDetailTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: _getHeaderColor(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _produktList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getEmptyMessage(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _produktList.length,
                  itemBuilder: (context, index) {
                    final produk = _produktList[index];
                    return _buildProdukCard(produk, index);
                  },
                ),
    );
  }

  Widget _buildProdukCard(Produk produk, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getHeaderColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        produk.codeProduk,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildDetailRow('Kategori', produk.kategori),
            const SizedBox(height: 8),
            _buildDetailRow('Merek', produk.merek),
            const SizedBox(height: 8),
            _buildDetailRow('Satuan', produk.satuanUnit ?? '-'),
            const SizedBox(height: 12),
            _buildDetailSection(produk),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(Produk produk) {
    switch (widget.notificationType) {
      case 'expired':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRowWithColor(
              'Tanggal Kadaluarsa',
              produk.tglExpired,
              Colors.red[400]!,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Stok Tersisa',
                '${produk.stok ?? 0} ${produk.satuanUnit ?? ""}'),
          ],
        );

      case 'expiring_soon':
        final now = DateTime.now();
        final expiredDate = DateFormat('dd-MM-yyyy').parse(produk.tglExpired);
        final daysLeft = expiredDate.difference(now).inDays;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRowWithColor(
              'Tanggal Kadaluarsa',
              produk.tglExpired,
              Colors.orange[400]!,
            ),
            const SizedBox(height: 8),
            _buildDetailRowWithColor(
              'Sisa Hari',
              '$daysLeft hari',
              daysLeft <= 3 ? Colors.red[400]! : Colors.orange[400]!,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Stok Tersisa',
                '${produk.stok ?? 0} ${produk.satuanUnit ?? ""}'),
          ],
        );

      case 'minimal_stock':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRowWithColor(
              'Stok Saat Ini',
              '${produk.stok ?? 0} ${produk.satuanUnit ?? ""}',
              Colors.amber[400]!,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Stok Minimal',
              '${produk.minStok ?? 0} ${produk.satuanUnit ?? ""}',
            ),
            const SizedBox(height: 8),
            if (produk.tglExpired.isNotEmpty)
              _buildDetailRow('Tgl Kadaluarsa', produk.tglExpired),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithColor(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (widget.notificationType) {
      case 'expired':
        return 'Tidak ada produk yang kadaluarsa.\nSemua produk masih dalam kondisi baik!';
      case 'expiring_soon':
        return 'Tidak ada produk yang akan kadaluarsa.\nStok Anda aman!';
      case 'minimal_stock':
        return 'Tidak ada produk dengan stok minimal.\nStok semua produk mencukupi!';
      default:
        return 'Tidak ada data tersedia';
    }
  }
}
