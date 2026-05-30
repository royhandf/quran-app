import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  /// Cek update dari Play Store. Return true jika ada update tersedia.
  /// Akan silently fail jika dijalankan di luar Play Store (debug/APK sideload).
  static Future<bool> isUpdateAvailable() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Mulai proses update via Play Store flexible update flow.
  static Future<void> startUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {}
  }

  /// Cek update dan tampilkan dialog jika ada update.
  /// Dipanggil dari home screen setelah app pertama dibuka.
  static Future<void> checkAndShowDialog(BuildContext context) async {
    final hasUpdate = await isUpdateAvailable();
    if (!hasUpdate) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _UpdateDialog(),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2218), Color(0xFF1A3A2A)],
          ),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9B8E).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0F9B8E).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Color(0xFF0F9B8E),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Update Tersedia! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Versi terbaru sudah tersedia di Play Store.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  UpdateService.startUpdate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9B8E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Update Sekarang',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Nanti Saja',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
