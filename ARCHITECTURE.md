# Aturan Arsitektur

Dokumen ini adalah acuan wajib saat menambah atau mengubah kode. Kalau kode yang ada
melanggar aturan di sini, perbaiki ke arah aturan — bukan sebaliknya.

## 1. Lapisan dan arah dependensi

```
presentation  →  data  →  core
      ↓            ↓        ↑
      └────────────┴────────┘
```

| Lapisan | Isi | Boleh bergantung pada | Tidak boleh |
|---|---|---|---|
| `presentation/` | Screens, widgets, Cubit/State | Cubit, model, `core/constants`, `core/utils` | Dio, Hive, `GetIt`, `rootBundle` |
| `data/` | Repository, model, `local/` | `core/services`, model | Widget, `BuildContext`, Cubit |
| `core/` | Service, konstanta, util, DI | Package eksternal | `presentation/`, `data/repositories` |

Aturan keras:

- **Widget tidak boleh** memanggil `Dio`, `Hive`, `dotenv`, atau `GetIt.instance` secara
  langsung. Ambil data lewat Cubit; ambil dependensi lewat constructor/Cubit yang sudah
  disediakan DI.
- **Repository adalah satu-satunya** pintu keluar-masuk data (API + cache). Kalau butuh
  data baru, tambah method repository, bukan panggilan `ApiService` dari layar.
- Cubit boleh mengekspos repository **hanya** untuk membuat Cubit anak di layar
  (mis. `AudioCubit`). Widget tidak boleh memanggil method repository secara langsung.
- **`core/services/` tidak boleh** mengimpor `presentation/`.
- **Model tidak boleh** mengandung logika UI atau `BuildContext`.

## 2. State management (BLoC)

- Satu fitur = satu `XxxCubit` + `XxxState`. Nama file mengikuti `xxx_cubit.dart` /
  `xxx_state.dart`.
- Cubit adalah tempat **logika fitur**: memanggil repository, menyimpan preferensi,
  memicu service. Widget hanya memilih state dan menampilkan.
- State harus **immutable** dan mengimplementasikan `Equatable` supaya rebuild efisien.
  Jangan emit state baru dengan nilai identik — `Equatable` akan menganggapnya sama.
- State yang dipakai lintas layar didaftarkan di root (`app/app.dart`). State yang hanya
  hidup selama satu layar dibuat lokal di layar tersebut (contoh: `QuranCubit` +
  `AudioCubit` di `SurahDetailScreen`).
- Jangan menyimpan `BuildContext`, widget, atau controller di dalam state.
- Efek samping (notifikasi, wakelock, GPS) dipanggil dari Cubit melalui service, bukan
  dari widget.

## 3. Repository dan model

- Repository menerima dependensi lewat constructor (bukan `GetIt`) dan tidak menyimpan
  state UI.
- Strategi cache harus eksplisit: **cache-first** (baca lokal, fallback jaringan) atau
  **network-first** (jaringan, fallback lokal). Tulis di komentar singkat method terkait.
- Model: `final` field, `fromJson`/`toJson` berdampingan, `Equatable` bila dipakai di
  state. Konversi bentuk API **hanya** di model atau repository — bukan di widget.
- Repository konkret tanpa `interface` boleh, selama hanya ada satu implementasi.
  Buat abstraksi baru ketika benar-benar ada implementasi kedua (mis. remote + fake).

## 4. Dependency injection

- Semua registrasi ada di `core/di/injection.dart`. Jangan membuat instance service baru
  di dalam widget.
- Aturan umur objek:
  - Service dan repository → `registerLazySingleton`.
  - Cubit → `registerFactory` (satu instance per layar/provider).
- Widget mengambil dependensi lewat `context.read<XxxCubit>()` atau parameter
  constructor. `GetIt` hanya dipakai di `injection.dart` dan bootstrap (`main.dart`).

## 5. Konfigurasi dan environment

- `.env` hanya untuk konfigurasi **non-rahasia** (base URL, flag). File ini dibundel
  sebagai asset, jadi **jangan pernah** menaruh API key/secret di dalamnya.
- Setiap key baru wajib ditambahkan ke `.env.example` dengan nama yang **persis sama**
  dengan yang dibaca kode.
- Variabel dibaca lewat `core/constants/api_constants.dart` (atau konstanta serupa),
  bukan `dotenv.env[...]` tersebar di layar.
- Nilai yang hilang tidak boleh memakai `null!`. Config publik boleh punya default di
  kode (seperti base URL), sedangkan nilai wajib harus gagal cepat dengan pesan jelas.

## 6. Penyimpanan lokal (Hive)

Box yang sudah dipakai — jangan tambah box baru tanpa memperbarui daftar ini:

| Box | Tipe | Isi |
|---|---|---|
| `bookmark` | `Map` | Penanda ayat, key `"{surahId}_{ayah}"` |
| `settings` | `dynamic` | Preferensi, `last_read`, `cached_prayer` |
| `prayer_alarms` | `bool` | Toggle alarm per nama sholat |
| `quran_verses` | `List` | Cache ayat per nomor surah (offline) |

- Semua akses box lewat `HiveService`. Layar tidak boleh memanggil `Hive.box(...)`.
- Key string didefinisikan sebagai konstanta di `HiveService`, bukan literal tersebar.

## 7. Penanganan error

- Error dari jaringan/IO dibungkus di service/repository dengan pesan yang bisa
  ditampilkan ke pengguna (bahasa Indonesia).
- Cubit mengubah error menjadi state `XxxError` atau field `errorMessage`. Widget tidak
  boleh menampilkan `e.toString()` mentah ke pengguna.
- Operasi yang bisa gagal senyap (update Play Store, reverse geocoding) tetap harus
  menelan error dengan aman dan tidak membuat app crash.

## 8. Gaya kode dan penamaan

- `flutter_lints` wajib bersih: `flutter analyze` harus `No issues found`.
- Nama: `XxxScreen`, `XxxCubit`, `XxxState`, `XxxRepository`, `XxxService`, `XxxModel`.
- Konstanta global di `core/constants/`, helper murni di `core/utils/`.
- Tidak menambah komentar untuk kode yang sudah jelas. Komentar hanya untuk keputusan
  non-obvious (alasan cache, workaround platform, batasan API).
- Warna, ukuran font, dan teks gaya diambil dari `AppColors` / `AppTextStyles`, bukan
  hardcode baru di layar.

## 9. Testing

- Logika murni (perhitungan waktu, konversi, ID notifikasi) **wajib** punya unit test di
  `test/`.
- Widget test minimal memastikan layar utama bisa dirender tanpa exception.
- `flutter test` harus hijau sebelum merge. Jangan meninggalkan test bawaan yang gagal.

## 10. Git dan commit

- **Commit hanya dibuat saat diminta eksplisit.** Jangan pernah commit otomatis di
  akhir tugas.
- Sebelum commit: perlihatkan daftar file yang akan masuk (`git status --short`) dan
  pastikan tidak ada file yang tidak seharusnya — artefak build, kredensial
  (`.env`, `key.properties`, keystore), `local.properties`, dan file kerja pribadi
  (gambar referensi, catatan, dump sementara).
- `git add -A` hanya boleh dipakai setelah isi working tree diperiksa. File baru yang
  bukan bagian dari kode (referensi desain, catatan pribadi) ditanyakan dulu kepada
  pemilik proyek sebelum masuk commit.
- Pesan commit menjelaskan **kenapa**, bukan hanya daftar file.
- Commit dibuat per langkah yang kohesif (satu topik satu commit), bukan satu
  commit raksasa campur aduk.

## 11. Definisi selesai (Definition of Done)

1. `flutter analyze` bersih.
2. `flutter test` hijau.
3. Tidak ada akses `GetIt`/Hive/Dio dari widget.
4. Key `.env` baru tercatat di `.env.example`.
5. Perubahan perilaku dicatat di `notes.md` bila menyentuh backlog/rilis.
6. `flutter build appbundle --release` berhasil bila perubahan menyentuh Android,
   dependency, atau konfigurasi rilis.
7. Perubahan UI mematuhi [DESIGN.md](./DESIGN.md).
8. Tidak ada commit yang dibuat tanpa permintaan eksplisit.
