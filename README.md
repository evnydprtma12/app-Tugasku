# TugasKu - Aplikasi Catatan Tugas

Aplikasi catatan tugas berbasis **Flutter (Dart)** untuk mencatat, mengelompokkan, dan mengelola tugas harian. Data tugas dan kategori disimpan di layanan **MockAPI** sehingga aplikasi tidak memerlukan server sendiri.

Project ini dibuat sebagai tugas perkuliahan Program Studi Teknologi Informasi, Universitas Bina Sarana Informatika (Depok).

## Fitur

- **Login** - masuk ke aplikasi dengan akun yang sudah ditentukan.
- **Beranda** - menampilkan daftar tugas, dengan fitur tambah, ubah, dan hapus tugas (judul, deskripsi, kategori, batas waktu).
- **Kategori** - menambah, mengubah, dan menghapus kategori tugas.
- **Profil** - halaman profil pengguna sederhana dengan tombol ubah profil dan keluar.

## Teknologi

| Komponen | Keterangan |
| --- | --- |
| Bahasa | Dart (SDK >=3.0.0 <4.0.0) |
| Framework | Flutter |
| Paket | [`http`](https://pub.dev/packages/http) ^1.2.2 |
| Backend | [MockAPI](https://mockapi.io) (REST API tiruan) |
| IDE awal | [FlutLab.io](https://flutlab.io) |

## Struktur Folder

```
lib/
├── main.dart                     # Titik awal aplikasi
├── page/
│   ├── login.dart                # Halaman login
│   ├── kategori.dart             # Halaman kategori (lihat, ubah, hapus)
│   └── profile.dart              # Halaman profil
└── services/
    ├── api_services.dart         # Halaman beranda, logika program, dan koneksi API
    ├── add_task_page.dart        # Halaman tambah tugas
    └── add_category_page.dart    # Halaman tambah kategori
```

## Cara Menjalankan

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) terpasang (Dart 3.0 atau lebih baru)
- Koneksi internet (data diambil dari MockAPI)
- Android Studio / VS Code, atau browser Chrome untuk versi web

### Langkah

```bash
# 1. Clone repository
git clone <URL-REPOSITORY-ANDA>
cd <NAMA-FOLDER-REPOSITORY>

# 2. Unduh dependensi
flutter pub get

# 3. Jalankan aplikasi
flutter run            # pilih perangkat/emulator yang tersedia
flutter run -d chrome  # atau jalankan versi web
```

### Build

```bash
flutter build apk   # menghasilkan file APK untuk Android
flutter build web   # menghasilkan versi web
```

## Akun Login

Login saat ini memakai akun tetap yang ditulis langsung di kode (untuk keperluan demonstrasi):

| Field | Nilai |
| --- | --- |
| Email | `admin` |
| Password | `admin` |

## Konfigurasi API

Aplikasi mengambil data dari MockAPI dengan dua endpoint:

- `GET/POST/PUT/DELETE /tasks` - data tugas
- `GET/POST/PUT/DELETE /categories` - data kategori

URL dasar API ada di `lib/services/api_services.dart` pada variabel `baseUrl`. Jika endpoint MockAPI tidak aktif lagi, buat project baru di [mockapi.io](https://mockapi.io) dengan resource `tasks` dan `categories`, lalu ganti nilai `baseUrl` dengan URL milik Anda.

## Catatan

- Autentikasi masih sederhana (hardcode) dan belum terhubung ke database pengguna.
- Tombol "Ubah Profil" masih berupa tampilan awal dan belum menyimpan perubahan.

## Kontak

- **Nama:** [Evan Yudi Pratama]
- **Email:** [evanyudipratama12@gmail.com]