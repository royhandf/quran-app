import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DzikirScreen extends StatelessWidget {
  const DzikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dzikir & Doa',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, color: AppColors.primary, size: 64),
            SizedBox(height: 16),
            Text(
              'Segera Hadir',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur dzikir dan doa sedang dalam pengembangan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
