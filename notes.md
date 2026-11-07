# Notes Proyek

Catatan kondisi terkini, utang teknis, backlog fitur, dan checklist rilis.
Aturan arsitektur ada di [ARCHITECTURE.md](./ARCHITECTURE.md).

Terakhir diperbarui: 2026-11-05

## Cara cepat menjalankan

```bash
flutter --version        # 3.41.6 stable / Dart 3.11.4 (aman untuk targetSdk 36)
flutter pub get
flutter test
flutter run
flutter build appbundle --release   # build/app/outputs/bundle/release/app-release.aab
```

Butuh `.env` di root (tidak di-commit, ada di `.gitignore`):

```env
EQURAN_API_BASE_URL=https://equran.id/api/v2
ALADHAN_API_BASE_URL=https://api.aladhan.com/v1
```

## Yang sudah dirapikan

- Aturan arsitektur ditulis di `ARCHITECTURE.md`.
- Widget tidak lagi memanggil `GetIt`/`Hive` langsung (surah list, search, last read,
  layar jadwal sholat, pengaturan jadwal).
- ID notifikasi dipusatkan di `PrayerAlarmIds` (stabil lintas sesi, tidak lagi
  memakai `hashCode` yang bisa berubah).
- Alarm dijadwalkan untuk 2 kemunculan (hari ini/berikutnya + besok).
- Ikon notifikasi memakai small icon putih (`ic_stat_adzan`).
- In-app update memakai `performImmediateUpdate` (flow flexible sebelumnya salah urutan).
- `.env.example` disamakan dengan kode + nilai default; config divalidasi dengan pesan jelas.
- `usesCleartextTraffic` dihapus.
- Test bawaan yang selalu gagal diganti unit test untuk logika murni.

## Backlog fitur

Prioritas: **P0** = sebelum rilis, **P1** = setelah rilis, **P2** = ide.

| # | Fitur | Prioritas | Effort | File terkait |
|---|---|---|---|---|
| 1 | **Last Read asli**: simpan posisi baca saat scroll berhenti, tampilkan di home (bukan bookmark), badge di daftar surah, lanjutkan bacaan | P0 | M | `hive_service.dart` (`saveLastRead` sudah ada), `surah_detail_screen.dart`, `home_screen.dart`, `surah_list_screen.dart` |
| 2 | **Reschedule notifikasi otomatis** tanpa membuka app (WorkManager + endpoint kalender Aladhan) | P0 | M | `notification_service.dart`, `prayer_cubit.dart` |
| 3 | **Cache daftar surah** agar list tetap tampil offline | P0 | S | `quran_repository.dart`, `hive_service.dart` |
| 4 | Counter dzikir (tap untuk hitung mundur, haptic feedback) | P1 | S | `dzikir_detail_screen.dart`, `dzikir.dart` |
| 5 | Pencarian ayat (bukan hanya nama surah) | P1 | M | `quran_cubit.dart`, `quran_repository.dart` |
| 6 | Pilih lokasi manual (kota) selain GPS | P1 | M | `location_service.dart`, `prayer_cubit.dart` |
| 7 | Audio background + kontrol lock screen | P1 | M | `audio_cubit.dart`, perlu `audio_service` |
| 8 | Download audio per surah untuk offline | P1 | M | `quran_repository.dart`, `audio_cubit.dart` |
| 9 | Tajwid berwarna (butuh dataset tajwid; setting sudah tersimpan) | P2 | L | `settings_screen.dart`, `surah_detail_screen.dart` |
| 10 | **Dark mode varian untuk home redesign** — palet home baru saat ini light-only, sesuai keputusan desain (light dulu, dark belakangan) | P1 | S | `app_tokens.dart`, `home_screen.dart`, komponen `widgets/home/` |
| 11 | Tafsir per ayat | P2 | M | model + repository baru |
| 12 | Widget home screen (jadwal sholat berikutnya) | P2 | M | perlu `home_widget` |
| 13 | Dukungan iOS | P2 | L | folder `ios/` belum ada |
| 14 | Lokalisasi (id/en) | P2 | M | seluruh string UI masih hardcode |

## Utang teknis / known issues

- **Last Read belum berfungsi.** `HiveService.saveLastRead` tidak pernah dipanggil;
  banner "Penanda Terakhir" di home memakai bookmark terbaru, dan layar `Penanda`
  sebenarnya daftar bookmark.
- **Tajwid belum diterapkan.** Toggle tersimpan di Hive, tetapi render ayat hanya
  memakai font, latin, dan terjemahan. Kartu "Tajwid Berwarna" diberi label "Segera Hadir".
- **Notifikasi terbatas 2 hari.** Kalau app tidak dibuka lebih dari 2 hari, alarm berhenti
  (solusi penuh: scheduler background / endpoint kalender).
- **Daftar surah selalu butuh internet.** Hanya ayat yang di-cache per surah.
- **Error mentah ke UI.** Beberapa layar menampilkan `e.toString()` (mis. `PrayerError`).
- **Audio error tidak terlihat.** `AudioCubit` langsung emit `AudioIdle` setelah
  `AudioError`, jadi snackbar/indikator error tidak sempat tampil.
- **`.env` dibundel sebagai asset.** Aman selama isinya hanya base URL publik; jangan
  pernah menaruh API key. Dokumentasikan di PR.
- **Tidak ada crash reporting/analytics.** Belum ada Firebase Crashlytics/Sentry.
- **Belum ada connectivity check** sebelum request; andalkan timeout Dio 15 detik.
- `PrayerTime.to12Hour` mengasumsikan input `HH:mm` 24 jam dari API.

## Checklist rilis Play Store

Sudah siap:

- [x] `key.properties` + keystore release (keduanya di `.gitignore`)
- [x] R8/minify + shrink resources + `proguard-rules.pro`
- [x] `compileSdk`/`targetSdk` 36 (syarat Play mulai 31 Agustus 2026)
- [x] `minSdk` 24
- [x] In-app update memakai immediate update
- [x] Izin lokasi, notifikasi, exact alarm dideklarasikan
- [x] `flutter analyze` bersih, unit test dasar ada
- [x] Cleartext traffic dimatikan

Belum selesai (harus sebelum upload):

- [ ] **Kebijakan privasi** (wajib karena memakai lokasi) dan URL-nya di Play Console
- [ ] **Data safety form**: koordinat dikirim ke API Aladhan untuk jadwal sholat;
      jelaskan data tidak disimpan di server sendiri
- [ ] **Content rating** + target audiens
- [ ] **Store listing**: judul, deskripsi, screenshot ponsel/tablet, ikon 512×512,
      feature graphic 1024×500
- [ ] **Play App Signing** diaktifkan, upload AAB pertama
- [ ] Uji di perangkat fisik: alarm saat app ditutup, Doze mode, battery optimization
      (Xiaomi/Oppo/Vivo), izin notifikasi Android 13+
- [ ] Uji izin lokasi ditolak / GPS mati (pesan error & retry)
- [ ] Uji tanpa internet (list surah, jadwal dari cache, audio)
- [ ] Naikkan `version` di `pubspec.yaml` sebelum setiap upload (`1.0.0+3` saat ini)
- [ ] Justifikasi `SCHEDULE_EXACT_ALARM` untuk waktu sholat di Play Console
- [ ] Pertimbangkan crash reporting sebelum rilis publik

## Perintah verifikasi sebelum merge

```bash
flutter analyze
flutter test
flutter build appbundle --release
```
