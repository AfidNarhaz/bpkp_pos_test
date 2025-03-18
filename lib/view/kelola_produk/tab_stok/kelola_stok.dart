import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/services.dart';

class KelolaStokPage extends StatefulWidget {
  final int produkId; // Change productId to produkId

  const KelolaStokPage({super.key, required this.produkId});

  @override
  KelolaStokPageState createState() => KelolaStokPageState();
}

class KelolaStokPageState extends State<KelolaStokPage> {
  bool _isChecked = false;
  final TextEditingController stokProdukController = TextEditingController();
  final TextEditingController minimumStokController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stokData = await _dbHelper.getStokData(widget.produkId);
    print('Loaded stok data: $stokData'); // Log loaded data
    if (stokData != null) {
      setState(() {
        stokProdukController.text = stokData['stokProduk'].toString();
        '';
        minimumStokController.text = stokData['minimumStok'].toString();
        '';
        _isChecked = stokData['isChecked'] == 1;
      });
    }
  }

  Future<void> _saveData() async {
    await _dbHelper.saveStokData(
      widget.produkId,
      stokProdukController.text,
      minimumStokController.text,
      _isChecked,
    );
    print('Saved stok data: ${{
      'produkId': widget.produkId,
      'stokProduk': stokProdukController.text,
      'minimumStok': minimumStokController.text,
      'isChecked': _isChecked,
    }}'); // Log saved data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Set background color
      appBar: AppBar(
        title: const Text('Kelola Stok'),
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: stokProdukController,
                  decoration: const InputDecoration(
                    labelText: 'Stok Produk',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: minimumStokController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stok',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: const Text(
                      'Kirim notifikasi saat stok mencapai batas minimum'),
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final shouldCancel = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Data stok belum tersimpan, yakin batal?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Yakin'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldCancel == true) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveData();
                        if (mounted) {
                          if (context.mounted) {
                            Navigator.pop(context, {
                              'stokProduk':
                                  int.parse(stokProdukController.text),
                              'minimumStok':
                                  int.parse(minimumStokController.text),
                              'isChecked': _isChecked,
                            });
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
