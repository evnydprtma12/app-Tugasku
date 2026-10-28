import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTaskPage extends StatefulWidget {
  final String baseUrl;
  final List<dynamic> categories;
  final VoidCallback onRefresh;

  AddTaskPage(
      {required this.baseUrl,
      required this.categories,
      required this.onRefresh});

  @override
  _AddTaskPageState createState() => _AddTaskPageState(categories: categories);
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  DateTime? _selectedDeadline;

  late List<DropdownMenuItem<int>> _categoryItems;

  _AddTaskPageState({required List<dynamic> categories}) {
    if (categories.isEmpty) {
      // Menangani kasus jika categories kosong
      _categoryItems = [];
    } else {
      _categoryItems = categories
          .where((cat) => cat['id'] != null && cat['name'] != null)
          .map<DropdownMenuItem<int>>((cat) => DropdownMenuItem<int>(
                value: int.parse(cat['id']), // Pastikan value adalah int
                child: Text(cat['name'] as String),
              ))
          .toList();
    }
  }

  Future<void> _addTask(String title, String description, int? categoryId,
      DateTime? deadline) async {
    try {
      // Cek jika categoryId atau title kosong
      if (categoryId == null ||
          title.isEmpty ||
          description.isEmpty ||
          deadline == null) {
        print('Please fill in all fields.');
        return;
      }

      await http.post(
        Uri.parse('${widget.baseUrl}/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'category_id': categoryId, // Pastikan category_id adalah int
          'deadline': deadline.toIso8601String(), // Convert DateTime ke String
        }),
      );
      widget.onRefresh();
      Navigator.of(context).pop();

      // Menampilkan SnackBar setelah berhasil menambah tugas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas berhasil ditambahkan!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Terjadi kesalahan saat mengambil tugas: $e');
      // Menampilkan notifikasi error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan tugas.')),
      );
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(), // Set the minimum date to today
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDeadline) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Judul Tugas',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Deskripsi',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              items: _categoryItems.isNotEmpty
                  ? _categoryItems
                  : [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Tidak ada kategori'),
                      ),
                    ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pilih Kategori',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDeadline(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: _selectedDeadline == null
                          ? 'Pilih Batas Waktu'
                          : _selectedDeadline!
                              .toLocal()
                              .toString()
                              .split(' ')[0]),
                  decoration: InputDecoration(
                    hintText: 'Pilih Batas Waktu',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _selectedCategoryId != null &&
                    _selectedDeadline != null) {
                  _addTask(
                    _titleController.text,
                    _descriptionController.text,
                    _selectedCategoryId,
                    _selectedDeadline,
                  );
                }
              },
              child: Text('Tambah Tugas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
