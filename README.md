# Contre Store - Aplikasi Mobile Manajemen Toko ATK

Aplikasi mobile Flutter untuk manajemen toko alat tulis (ATK) "Contre Store", terhubung ke backend Node.js/Express + MySQL melalui REST API.

## Teknologi
- Flutter, Dart
- Dio, Provider, Flutter Secure Storage, Image Picker, Cached Network Image
- Material Design 3

## Struktur Folder
Lihat folder `lib/` (modular: core, models, services, providers, screens, widgets, app).

## Instalasi
1. Pastikan Flutter SDK terpasang (`flutter --version`).
2. `cd "uji level umkm frontend"`
3. `flutter pub get`

## Menjalankan
- Backend harus aktif: di folder backend jalankan `npm run dev` (port 5000).
- Jalankan aplikasi: `flutter run` (emulator Android).

## Konfigurasi Base URL
File: `lib/core/constants/api_constants.dart`
- Emulator Android: `http://10.0.2.2:5000`
- HP fisik: `http://<IP_KOMPUTER>:5000`
- Web/Desktop: `http://localhost:5000`

## Autentikasi JWT
Login via `/api/auth/login`, token disimpan di Flutter Secure Storage, dikirim via header `Authorization: Bearer <token>`. Token kadaluarsa/invalid → redirect login.

## Role
- Admin: CRUD produk & kategori, upload gambar.
- User: lihat produk, detail, kategori, profil.
Role diperoleh dari backend, register hanya user.

## Halaman
Splash, Login, Register, Home (dashboard), Produk (list/detail/form), Kategori (list/form), Profil.

## Integrasi API
Endpoint sesuai backend Contre Store (auth, categories, products, upload). Upload multipart field `image`.

## Pengujian
1. Register user.
2. Login admin/user.
3. Logout.
4. JWT storage.
5. Role redirect.
6. List/detail produk.
7. CRUD produk & kategori admin.
8. Upload gambar & tampil Cloudinary.
9. Penolakan akses user.
10. Error handling.

## Akun Pengujian
- Admin: admin@contre.com / admin123
- User: user@contre.com / user123

Jalankan `flutter analyze` sebelum run.