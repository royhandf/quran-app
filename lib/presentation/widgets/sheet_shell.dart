import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_tokens.dart';

/// Bottom sheet bersama: drag handle, judul, dan konten scrollable.
/// Latar mengikuti tema (putih di light, surface gelap di dark).
class SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const SheetShell({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.homeSheetSurface(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTokens.sheetRadius),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.homeDivider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title, style: AppTokens.sheetTitle(context)),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}
