import 'package:apptugas/page/kategori.dart';
import 'package:apptugas/services/api_services.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // Pastikan halaman login sudah dibuat

// Halaman profil pengguna
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> categories = []; // Menyimpan data kategori
  int _selectedIndex =
      2; // Indeks untuk menandai tab yang dipilih (default ke Profil)

  // Fungsi untuk menangani perubahan tab bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mengubah indeks berdasarkan tab yang dipilih
    });

    // Jika Home dipilih, arahkan ke halaman ApiServices
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApiServices()),
      );
    }
    // Jika Kategori dipilih, arahkan ke halaman CategoryPage
    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryPage(
            baseUrl: 'https://67729ba5ee76b92dd492d3ad.mockapi.io/',
            onRefresh: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'), // Judul halaman
        backgroundColor: Colors.blueAccent, // Warna latar belakang app bar
        automaticallyImplyLeading:
            false, // Menghilangkan tombol kembali di app bar
        elevation: 5.0, // Menambahkan elevasi app bar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 24.0), // Padding sekitar konten
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar profil pengguna
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nama Pengguna',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Email: pengguna@example.com',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nomor Telepon: +62 123 4567 890',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              // Tombol untuk mengedit profil
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tombol Edit Profil Ditekan')),
                  );
                },
                child: const Text('Ubah Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5.0,
                ),
              ),
              const SizedBox(height: 20),
              // Tombol untuk keluar (logout)
              ElevatedButton(
                onPressed: () {
                  // Kembali ke halaman login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text('Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5.0,
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar untuk navigasi antar halaman
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
        currentIndex: _selectedIndex, // Menandai tab yang aktif
        selectedItemColor: Colors.blueAccent, // Warna tab terpilih
        unselectedItemColor: Colors.black54, // Warna tab yang tidak terpilih
        onTap: _onItemTapped, // Fungsi yang dijalankan ketika tab dipilih
        backgroundColor:
            Colors.blueGrey[50], // Warna latar belakang bottom navigation bar
        elevation: 10.0, // Menambahkan elevasi pada bottom navigation bar
      ),
    );
  }
}
