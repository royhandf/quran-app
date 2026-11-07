import 'package:flutter/material.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../data/models/bookmark.dart';

/// Banner penanda terakhir (bookmark terbaru). Muncul hanya bila [bookmark]
/// tidak null — pemanggil bertanggung jawab menyembunyikan widget ini.
class BookmarkBanner extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;

  const BookmarkBanner({
    super.key,
    required this.bookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.sageLight,
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 20,
                  color: AppTokens.forest,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PENANDA TERAKHIR',
                      style: AppTokens.cardLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${bookmark.surahName} · Ayat ${bookmark.ayahNumber}',
                      style: AppTokens.bannerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: AppTokens.forest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
