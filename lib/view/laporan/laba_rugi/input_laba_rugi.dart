import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

class InputLabaRugiPage extends StatefulWidget {
  const InputLabaRugiPage({super.key});

  @override
  State<InputLabaRugiPage> createState() => _InputLabaRugiPageState();
}

class _InputLabaRugiPageState extends State<InputLabaRugiPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late DateTime _selectedDate;

  // Form controllers
  late TextEditingController _gajiPegawaiController;
  late TextEditingController _sewaTempController;
  late TextEditingController _listrikAirGasController;
  late TextEditingController _transportasiController;
  late TextEditingController _penyusutanController;
  late TextEditingController _biayaLainnyaController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    _gajiPegawaiController = TextEditingController();
    _sewaTempController = TextEditingController();
    _listrikAirGasController = TextEditingController();
    _transportasiController = TextEditingController();
    _penyusutanController = TextEditingController();
    _biayaLainnyaController = TextEditingController();

    _loadOperationalExpenses();
  }

  Future<void> _loadOperationalExpenses() async {
    try {
      final expenses = await _dbHelper.getOperationalExpenses(_selectedDate);
      if (expenses != null) {
        setState(() {
          _gajiPegawaiController.text =
              expenses['gajiPegawai']?.toString() ?? '0';
          _sewaTempController.text = expenses['sewaTempat']?.toString() ?? '0';
          _listrikAirGasController.text =
              expenses['listrikAirGas']?.toString() ?? '0';
          _transportasiController.text =
              expenses['transportasi']?.toString() ?? '0';
          _penyusutanController.text =
              expenses['penyusutanPeralatan']?.toString() ?? '0';
          _biayaLainnyaController.text =
              expenses['biayaLainnya']?.toString() ?? '0';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _saveOperationalExpenses() async {
    try {
      final expenses = {
        'tanggal': DateFormat('dd-MM-yyyy').format(_selectedDate),
        'gajiPegawai': double.tryParse(_gajiPegawaiController.text) ?? 0,
        'sewaTempat': double.tryParse(_sewaTempController.text) ?? 0,
        'listrikAirGas': double.tryParse(_listrikAirGasController.text) ?? 0,
        'transportasi': double.tryParse(_transportasiController.text) ?? 0,
        'penyusutanPeralatan': double.tryParse(_penyusutanController.text) ?? 0,
        'biayaLainnya': double.tryParse(_biayaLainnyaController.text) ?? 0,
      };

      await _dbHelper.saveOperationalExpenses(expenses);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Data beban operasional berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadOperationalExpenses();
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '0';
    final amount = double.tryParse(value) ?? 0;
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp${formatter.format(amount)}';
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.topRight,
            child: Text(
              _formatCurrency(controller.text),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gajiPegawaiController.dispose();
    _sewaTempController.dispose();
    _listrikAirGasController.dispose();
    _transportasiController.dispose();
    _penyusutanController.dispose();
    _biayaLainnyaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Beban Operasional',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Operational Expenses Section
            const Text(
              'Beban Operasional',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Input Fields
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputField(
                      label: '1. Gaji Pegawai',
                      controller: _gajiPegawaiController,
                      hint: 'Masukkan gaji pegawai',
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      label: '2. Sewa Tempat',
                      controller: _sewaTempController,
                      hint: 'Masukkan biaya sewa tempat',
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      label: '3. Listrik dan Air',
                      controller: _listrikAirGasController,
                      hint: 'Masukkan biaya listrik dan air',
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      label: '4. Transportasi',
                      controller: _transportasiController,
                      hint: 'Masukkan biaya transportasi',
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      label: '5. Penyusutan Peralatan',
                      controller: _penyusutanController,
                      hint: 'Masukkan biaya penyusutan peralatan',
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      label: '6. Biaya Operasional Lainnya',
                      controller: _biayaLainnyaController,
                      hint: 'Masukkan biaya lainnya',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Total Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Beban Operasional',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(
                      ((double.tryParse(_gajiPegawaiController.text) ?? 0) +
                              (double.tryParse(_sewaTempController.text) ?? 0) +
                              (double.tryParse(_listrikAirGasController.text) ??
                                  0) +
                              (double.tryParse(_transportasiController.text) ??
                                  0) +
                              (double.tryParse(_penyusutanController.text) ??
                                  0) +
                              (double.tryParse(_biayaLainnyaController.text) ??
                                  0))
                          .toString(),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveOperationalExpenses,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Batal'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
