import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCategoryPage extends StatefulWidget {
  final String baseUrl;
  final VoidCallback onRefresh;

  AddCategoryPage({required this.baseUrl, required this.onRefresh});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addCategory(String name) async {
    try {
      await http.post(
        Uri.parse('${widget.baseUrl}/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
      widget.onRefresh();
      Navigator.of(context).pop();

      // Menampilkan notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori berhasil ditambahkan!')),
      );
    } catch (e) {
      print('Terjadi kesalahan saat mengambil kategori: $e');
      // Menampilkan notifikasi error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan kategori.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Judul Kategori',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _addCategory(_controller.text);
                }
              },
              child: Text('Tambah Kategori'),
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
