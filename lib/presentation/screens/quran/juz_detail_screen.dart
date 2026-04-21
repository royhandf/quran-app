import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class JuzDetailScreen extends StatelessWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juz $juzNumber')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Fitur Juz tidak tersedia',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
