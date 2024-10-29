import 'package:flutter/material.dart';

class MerekDialog {
  static void showMerekDialog(
    BuildContext context,
    List<Map<String, dynamic>> listMerek,
    Function(String) onMerekAdded,
    Function(int, String) onMerekEdited,
    Function(int) onMerekDeleted,
    Function(String) onMerekSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Merek',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showTambahMerekDialog(context, onMerekAdded);
                      },
                      icon: const Icon(Icons.add, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: listMerek.length,
                  itemBuilder: (context, index) {
                    final merek = listMerek[index];
                    return ListTile(
                      title: Text(merek['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditMerekDialog(
                            context,
                            merek['id'],
                            merek['name'],
                            onMerekEdited,
                            onMerekDeleted,
                          );
                        },
                      ),
                      onTap: () {
                        onMerekSelected(merek['name']);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showTambahMerekDialog(
    BuildContext context,
    Function(String) onMerekAdded,
  ) {
    final TextEditingController merekBaruController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nama Merek'),
              content: TextField(
                controller: merekBaruController,
                decoration: InputDecoration(
                  hintText: 'Nama Merek',
                  errorText: errorMessage,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    String newMerek = merekBaruController.text.trim();
                    if (newMerek.isEmpty) {
                      setState(() {
                        errorMessage = 'Merek wajib diisi';
                      });
                    } else {
                      onMerekAdded(newMerek);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child:
                      const Text('Simpan', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showEditMerekDialog(
    BuildContext context,
    int id,
    String existingName,
    Function(int, String) onMerekEdited,
    Function(int) onMerekDeleted,
  ) {
    final TextEditingController merekEditController =
        TextEditingController(text: existingName);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Merek'),
              content: TextField(
                controller: merekEditController,
                decoration: InputDecoration(
                  hintText: 'Nama Merek',
                  errorText: errorMessage,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onMerekDeleted(id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Hapus', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    String updatedMerek = merekEditController.text.trim();
                    if (updatedMerek.isEmpty) {
                      setState(() {
                        errorMessage = 'Merek wajib diisi';
                      });
                    } else {
                      onMerekEdited(id, updatedMerek);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child:
                      const Text('Simpan', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
