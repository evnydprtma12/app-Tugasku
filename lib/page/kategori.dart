import 'package:apptugas/page/profile.dart';
import 'package:apptugas/services/api_services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/services/add_category_page.dart';

class CategoryPage extends StatefulWidget {
  final String baseUrl; // URL dasar untuk API
  final Function onRefresh; // Fungsi untuk menyegarkan data dari luar halaman

  const CategoryPage(
      {required this.baseUrl, required this.onRefresh, super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

/// Bertanggung jawab untuk logika pengambilan data, pengelolaan kategori,
/// dan navigasi dalam halaman ini.
class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> categories = []; // Daftar kategori yang diambil dari API
  int _selectedIndex = 1; // Indeks item yang dipilih pada NavigationBar
  bool _isLoading = true; // Indikator status pengambilan data
  String? _errorMessage; // Pesan error jika pengambilan data gagal

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Memulai pengambilan data kategori saat inisialisasi
  }

  /// Fungsi untuk mengambil daftar kategori dari API
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response =
          await http.get(Uri.parse('${widget.baseUrl}/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('gagal memuat kategori');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat mengambil kategori: $e';
        _isLoading = false;
      });
    }
  }

// Menghapus kategori berdasarkan ID
  Future<void> _deleteCategory(String id) async {
    // Menampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content:
              const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final response = await http
                      .delete(Uri.parse('${widget.baseUrl}/categories/$id'));
                  if (response.statusCode == 200) {
                    widget.onRefresh();
                    _fetchCategories();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kategori berhasil dihapus!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    throw Exception('Kategori gagal dihapus!');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Terjadi masalah saat menghapus!: $e')),
                  );
                }
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk mengedit kategori yang sudah ada
  Future<void> _editCategory(
      BuildContext context, Map<String, dynamic> category) async {
    final TextEditingController nameController =
        TextEditingController(text: category['name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Kategori'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final updatedCategory = {
                  'name': nameController.text,
                };

                try {
                  final response = await http.put(
                    Uri.parse('${widget.baseUrl}/categories/${category['id']}'),
                    body: json.encode(updatedCategory),
                    headers: {'Content-Type': 'application/json'},
                  );
                  if (response.statusCode == 200) {
                    widget.onRefresh();
                    _fetchCategories();
                    Navigator.of(context).pop();

                    // Tampilkan pesan sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kategori berhasil diubah!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    throw Exception('Gagal mengupdate kategori');
                  }
                } catch (e) {
                  print('Terjadi masalah saat update: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi masalah saat update: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk menangani perubahan halaman di BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApiServices(),
        ),
      ); // Navigate to TaskManagementPage
    } else if (index == 1) {
      _fetchCategories();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ),
      ); // Navigate to ProfilePage
    }
  }

  //Tampilan Halaman Kategori
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : categories.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 8,
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(
                                    category['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.orange),
                                        onPressed: () =>
                                            _editCategory(context, category),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteCategory(category['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

      // button tambah kategori
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoryPage(
                baseUrl: widget.baseUrl,
                onRefresh: _fetchCategories,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Kategori',
        backgroundColor: Colors.blueAccent,
      ),

      // Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey[50],
      ),
    );
  }
}
