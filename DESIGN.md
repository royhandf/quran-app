# Aturan Desain UI

Pembaruan dari [ARCHITECTURE.md](./ARCHITECTURE.md). Aturan ini mengikat untuk semua
pekerjaan tampilan. Kalau kode UI melanggar aturan di sini, perbaiki ke arah aturan.

## 1. Token terpusat — dilarang hardcode

- Semua warna, radius, spacing, dan gaya teks yang dipakai lebih dari satu tempat
  **wajib** lewat token terpusat: **warna di `AppColors`**, **dimensi & gaya teks
  layar ter-redesign di `AppTokens`**. `AppTextStyles` hanyalah sisa layar lama.
- Nilai baru (warna, ukuran, font) hanya boleh ditambah sebagai token dengan nama
  bermakna — bukan `Color(0xFF...)` atau `fontSize: 13` yang disebbar di widget.
- Satu layar = satu palet yang didefinisikan tokennya dulu, sebelum widget ditulis.
- Ketika mendesain ulang satu layar, jangan mengubah token layar lain.
- **`AppColors` adalah satu-satunya rumah warna.** Konstanta warna lama di dalamnya
  dipensiunkan bertahap: begitu tak terpakai, langsung dihapus. Dilarang ada dua
  konstanta bernama sama dengan nilai berbeda — `gold` kini hanya satu
  (`AppColors.gold`, nilai palet baru).
- Setiap layar yang di-redesign migrasi penuh: warna → `AppColors`, dimensi & gaya
  teks → `AppTokens` (gaya lintas layar dinaikkan jadi shared). Saat konstanta lama
  di `AppColors` dan `AppTextStyles` habis, sisanya dihapus.

## 2. Font

- `fontFamily` hanya boleh menunjuk family yang **terdaftar di `pubspec.yaml`** dan
  filenya benar-benar ada di `assets/fonts/`. Referensi font yang tidak ter-bundle
  adalah bug (contoh lama: `Amiri` sebelum di-bundle).
- Family dan peruntukannya (semua ter-bundle lokal di `assets/fonts/` — **tidak ada
  font yang di-fetch dari jaringan**; dependency `google_fonts` sudah dihapus):
  - `Poppins` — semua teks Latin, semua layar (tema global + home).
  - `Amiri` — teks Arab UI di home (bismillah, nama Arab).
  - `ScheherazadeNew` — ayat Quran di layar baca (default).
  - `Lateef` — varian gaya via setting penulisan di layar baca.
- Angka jam memakai `FontFeature.tabularFigures()`.

## 3. Komponen

- Komponen home hidup di `lib/presentation/widgets/home/`. Komponen yang mulai dipakai
  lintas layar naik ke `lib/presentation/widgets/`.
- Varian (primary/secondary) diturunkan lewat **parameter**, bukan menyalin file widget.
- Umpan balik tekan konsisten: scale `0.96–1.0`, durasi 120 ms.
- Widget tidak boleh menghitung data sendiri; terima data/state lewat parameter,
  kecuali turunan murni dari state yang diterima (mis. format tanggal).

## 4. Aset SVG

- SVG hanya dirender lewat `flutter_svg`.
- Warna aset diganti lewat `ColorFilter.mode(warna, BlendMode.srcIn)` — isi file SVG
  tidak boleh diedit untuk mengubah warna/opacity.
- Aset desain referensi (mis. `ref-home.png`) tidak otomatis masuk repo; tanyakan dulu.

## 5. Teks Arab

- Selalu `textDirection: TextDirection.rtl`.
- Nama/label Arab dengan lebar terbatas: `ConstrainedBox` + `maxLines: 1` +
  `overflow: ellipsis`, dan jika perlu seragam, terapkan pengecilan ke **semua**
  elemen sekelasnya (pola `MenuGrid`: 18px → 16px → 14px bila ada yang tidak muat).

## 6. Layout dan aksesibilitas

- Area sentuh minimum 44×44.
- Tidak ada tinggi tetap untuk konten yang bisa memanjang; gunakan `minHeight`,
  `AspectRatio`, atau biarkan konten menentukan.
- Data eksternal yang panjangnya tak terduga (nama kota, tanggal hijriah, judul)
  dibungkus `FittedBox(scaleDown)` atau `ellipsis` — jangan biarkan terpotong/layout
  pecah.
- Saat font sistem diperbesar, layar tetap utuh: batasi dengan
  `MediaQuery.withClampedTextScaling` bila perlu.
- Setiap state layar digambar: loading, error, dan kosong — bukan cuma state sukses.

## 7. Verifikasi desain

Sebelum desain dinyatakan selesai:

1. `flutter analyze` bersih.
2. Build → install → screenshot perangkat/emulator (`adb shell screencap`).
3. Bandingkan berdampingan dengan desain referensi; perbaiki selisih spacing dan
   perataan yang terlihat.
4. Screenshot diperiksa ulang setelah perbaikan.

## 8. Dokumentasi

- Keputusan desain yang menyimpang dari referensi dicatat di laporan/PR dengan alasan.
- Menambah token, font, atau komponen baru dicatat di bagian terkait dokumen ini.
