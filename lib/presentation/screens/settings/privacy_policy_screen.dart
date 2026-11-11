import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// Salinan teks dari design/store/kebijakan-privasi.md yang dipakai
  /// sebagai URL kebijakan privasi Play Console - ubah keduanya bersamaan.
  static const List<Map<String, Object>> _sections = [
    {
      'title': 'Data yang Diakses',
      'blocks': [
        {
          'heading': 'Lokasi (akurasi kota)',
          'body':
              'Aplikasi meminta izin lokasi akurasi kasar (coarse) untuk '
              'menentukan kota Anda agar jadwal sholat sesuai wilayah, serta '
              'menghitung arah kiblat. Koordinat perkiraan dikirim ke layanan '
              'API jadwal sholat publik (Aladhan) dan tidak menyertakan nama, '
              'email, atau identitas pribadi lain. Aplikasi tidak memiliki '
              'server sendiri dan tidak menyimpan lokasi Anda selain cache '
              'lokal di perangkat.',
        },
        {
          'heading': 'Notifikasi & Alarm',
          'body':
              'Jadwal adzan diproses dan dijadwalkan sepenuhnya di perangkat '
              'Anda melalui sistem Android. Tidak ada data yang dikirim ke '
              'luar perangkat untuk fitur ini.',
        },
        {
          'heading': 'Data yang Disimpan di Perangkat',
          'body':
              'Penanda bacaan, pengaturan aplikasi, dan cache jadwal disimpan '
              'hanya di perangkat Anda. Data ini tidak diunggah, tidak '
              'disinkronkan, dan tidak dibagikan. Menghapus aplikasi akan '
              'menghapus seluruh data tersebut.',
        },
        {
          'heading': 'Jaringan',
          'body':
              'Aplikasi mengunduh metadata surat/ayat dan audio murottal dari '
              'API publik (equran.id, api.aladhan.com) melalui koneksi '
              'internet Anda.',
        },
      ],
    },
    {
      'title': 'Yang Tidak Kami Lakukan',
      'blocks': [
        {
          'heading': '',
          'body':
              'Tidak menampilkan iklan. Tidak menggunakan layanan analitik '
              'pihak ketiga. Tidak menjual atau membagikan data kepada pihak '
              'ketiga. Tidak meminta akun, login, atau data pribadi seperti '
              'nama, email, atau kontak. Tidak mengakses kontak, SMS, log '
              'panggilan, atau file di penyimpanan Anda.',
        },
      ],
    },
    {
      'title': 'Perubahan Kebijakan',
      'blocks': [
        {
          'heading': '',
          'body':
              'Perubahan kebijakan ini akan dipublikasikan di halaman yang '
              'sama dengan tanggal pembaruan terbaru.',
        },
      ],
    },
    {
      'title': 'Kontak',
      'blocks': [
        {
          'heading': '',
          'body':
              'Pertanyaan tentang kebijakan ini dapat dikirim ke '
              'boedakoding@gmail.com.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Kebijakan Privasi', style: AppTokens.pageTitle(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pageMargin,
          4,
          AppTokens.pageMargin,
          32,
        ),
        children: [
          Text(
            'Terakhir diperbarui: 11 November 2026',
            style: AppTokens.tileSubtitle(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Quran Harian adalah aplikasi Al-Quran, jadwal sholat, dan '
            'dzikir. Kami menghargai privasi Anda. Kebijakan ini menjelaskan '
            'data apa yang diakses aplikasi, untuk apa, dan bagaimana '
            'penanganannya.',
            style: AppTokens.tileValue(context).copyWith(height: 1.6),
          ),
          for (final section in _sections) ...[
            const SizedBox(height: 24),
            Text(
              (section['title'] as String).toUpperCase(),
              style: AppTokens.cardLabel(context),
            ),
            const SizedBox(height: 10),
            for (final block in section['blocks']! as List<Map<String, Object>>)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((block['heading'] as String).isNotEmpty) ...[
                      Text(
                        block['heading'] as String,
                        style: AppTokens.tileTitle(context),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      block['body'] as String,
                      style: AppTokens.tileValue(context).copyWith(
                        height: 1.6,
                        color: AppColors.homeInkSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
