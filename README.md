# Ramdet Otomotif

Ramdet Otomotif adalah sistem aplikasi manajemen dan katalog produk otomotif berbasis mobile yang dikembangkan menggunakan arsitektur Monorepo (Monolithic Repository). Arsitektur tersebut merupakan strategi untuk menyimpan beberapa proyek atau komponen aplikasi yang berbeda di dalam satu repositori Git (GitHub) yang sama guna mempermudah kolaborasi tim serta sinkronisasi kode. Sistem ini memisahkan peran antara backend penyedia layanan API dan frontend sebagai antarmuka aplikasi mobile untuk mempermudah pengelolaan data produk, manajemen akun pengguna, serta operasional bisnis otomotif secara terintegrasi.

---

## Tujuan Proyek

Proyek ini dibangun untuk menyederhanakan proses manajemen inventaris produk otomotif seperti velg, ban, knalpot, dan suspensi, sekaligus memberikan kemudahan akses bagi pelanggan dalam melihat katalog produk secara digital. 

---

## Tech Stack

Proyek ini memanfaatkan kombinasi teknologi modern yang efisien untuk pengembangan aplikasi multiplatform:

### Backend (backend_ramdet)
* Bahasa Pemograman: PHP
* Framework: Laravel
* Database: MySQL
* Autentikasi: Laravel Sanctum (Token-based API Authentication)

### Frontend (frontend_ramdet)
* Bahasa Pemograman: Dart
* Framework: Flutter 
* State Management: Menggunakan pustaka manajemen state yang efisien untuk aplikasi mobile

---

## Struktur Folder

Repositori ini menggunakan pendekatan monorepo untuk menyatukan komponen server dan aplikasi client dalam satu tempat:

```text
ramdet_otomotif/
├── backend_ramdet/      # Sumber kode API server berbasis Laravel
├── frontend_ramdet/     # Sumber kode aplikasi mobile berbasis Flutter
└── .gitignore           # Pengaturan pengabaian file Git global
```

---

## Langkah Instalasi dan Pengoperasian
### Prasyarat Sistem

1. PHP versi 8.x atau yang terbaru
2. MySQL Server (bisa menggunakan bawaan Laragon / XAMPP)
3. Composer untuk manajemen dependensi PHP
4. Flutter SDK versi stabil terbaru
5. VS Code atau Android Studio

---

## Panduan Menjalankan Backend

1. Masuk ke dalam direktori backend melalui terminal:

```text
cd backend_ramdet
```

2. Instal semua dependensi PHP yang dibutuhkan:

```text
composer install
```

3. Salin file konfigurasi lingkungan kerja:

```text
cp .env.example .env
```

4. Buka file .env yang baru dibuat, lalu sesuaikan bagian konfigurasi database MySQL berikut (sesuaikan nama database, username, dan password dengan MySQL lokal):

```text
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=backend_ramdet
DB_USERNAME=root
DB_PASSWORD=
```

5. Buat database baru bernama backend_ramdet di MySQL (lewat phpMyAdmin Laragon).

6. Jalankan migrasi tabel beserta penyuntikan data dummy (seeder):

```text
php artisan migrate:fresh --seed
```

7. Aktifkan server lokal Laravel:

```text
php artisan serve
```

## Panduan Menjalankan Frontend

1. Buka jendela terminal baru dan masuk ke direktori frontend:

```text
cd frontend_ramdet
```

2. Unduh seluruh paket dependensi Flutter yang tertulis di pubspec.yaml:

```text
flutter pub get
```

3. Jalankan aplikasi pada perangkat fisik yang terhubung atau emulator:

```text
flutter run
```

## Akun Administrator Bawaan (Default Seeder)

Untuk mempermudah pengujian fitur login pertama kali di sisi aplikasi mobile, gunakan akun administrator bawaan berikut yang otomatis digenerate oleh sistem database seeder:

- Email: admin@ramdet.com

- Password: admin123

- Peran: admin

- Status Keanggotaan: platinum

- Alamat: Bengkel Ramdet

- Nomor Telepon: 087785115589