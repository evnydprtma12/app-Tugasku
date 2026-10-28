import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/page/kategori.dart';
import '/page/profile.dart';
import 'add_task_page.dart';

class ApiServices extends StatefulWidget {
  @override
  _ApiServicesPageState createState() => _ApiServicesPageState();
}

class _ApiServicesPageState extends State<ApiServices> {
  final String baseUrl =
      'https://6778f775482f42b62e900c6c.mockapi.io/'; // URL API
  List<dynamic> tasks = []; // Daftar tugas
  List<dynamic> categories = []; // Daftar kategori
  int _selectedIndex = 0; // Indeks untuk bottom navigation bar

  @override
  void initState() {
    super.initState();
    _fetchData(); // Mengambil data dari API saat halaman dimulai
  }

  // Mengambil data dari API untuk tugas dan kategori
  Future<void> _fetchData() async {
    try {
      final tasksResponse = await http.get(Uri.parse('$baseUrl/tasks'));
      final categoriesResponse =
          await http.get(Uri.parse('$baseUrl/categories'));

      if (tasksResponse.statusCode == 200 &&
          categoriesResponse.statusCode == 200) {
        setState(() {
          tasks = json.decode(tasksResponse.body);
          categories = json.decode(categoriesResponse.body);
        });
      }
    } catch (e) {
      print('Terjadi kesalahan saat mengambil data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data.')),
      );
    }
  }

  // Menghapus tugas berdasarkan ID
  Future<void> _deleteTask(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await http.delete(Uri.parse('$baseUrl/tasks/$id'));
                  _fetchData(); // Refresh data setelah menghapus tugas
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tugas berhasil dihapus'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Terjadi kesalahan saat menghapus tugas: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus tugas'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengedit tugas
  void _editTask(BuildContext context, Map<String, dynamic> task) {
    final TextEditingController titleController =
        TextEditingController(text: task['title']);
    final TextEditingController descriptionController =
        TextEditingController(text: task['description']);
    final TextEditingController deadlineController = TextEditingController(
      text: task['deadline'] == null || task['deadline'].isEmpty
          ? ''
          : DateTime.parse(task['deadline']).toLocal().toString().split(' ')[0],
    );
    int? selectedCategoryId = task['category_id'];
    DateTime? selectedDeadline = DateTime.tryParse(task['deadline'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah Tugas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: categories.any((cat) =>
                          int.tryParse(cat['id'].toString()) ==
                          selectedCategoryId)
                      ? selectedCategoryId
                      : null,
                  items: categories.map<DropdownMenuItem<int>>((cat) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(cat['id'].toString()),
                      child: Text(cat['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                  },
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      selectedDeadline = pickedDate;
                      deadlineController.text = pickedDate
                          .toLocal()
                          .toString()
                          .split(' ')[0]; // Perbarui tampilan teks
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(labelText: 'Batas Waktu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Buat body data untuk request
                Map<String, dynamic> updatedTask = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'category_id': selectedCategoryId,
                  'deadline': selectedDeadline?.toIso8601String(),
                };

                try {
                  // Kirim data ke server
                  final response = await http.put(
                    Uri.parse('$baseUrl/tasks/${task['id']}'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(updatedTask),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      _fetchData(); // Refresh data
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tugas berhasil diperbarui'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    throw Exception('Gagal menyimpan perubahan');
                  }
                } catch (e) {
                  print('Terjadi kesalahan saat menyimpan perubahan: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan perubahan'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menangani perubahan tab di bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _fetchData();
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryPage(
            baseUrl: baseUrl,
            onRefresh: _fetchData,
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Tugasku'),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'Tugas belum tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final category = categories.firstWhere(
                          (cat) =>
                              int.tryParse(cat['id'].toString()) ==
                              task['category_id'],
                          orElse: () => null);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(Icons.task, color: Colors.blue),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '${task['description'] ?? 'Tidak Ada Deskripsi'}\nDeadline: ${task['deadline'] != null && task['deadline'].isNotEmpty ? DateTime.parse(task['deadline']).toLocal().toString().split(' ')[0] : '-'}\nCategory: ${category != null ? category['name'] : '-'}',
                            style: TextStyle(color: Color(0xff000000)),
                            textAlign: TextAlign.left,
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editTask(context, task),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task['id']),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(
                baseUrl: baseUrl,
                categories: categories,
                onRefresh: _fetchData,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Tugas',
        backgroundColor: Colors.blueAccent,
      ),
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
      ),
    );
  }
}
