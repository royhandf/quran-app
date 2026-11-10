import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/bookmark.dart';
import '../star_icon_container.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.homeBannerAccent(context);

    return Material(
      color: AppColors.homeSurface(context),
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              StarIconContainer(
                icon: Icons.bookmark_rounded,
                containerColor: AppColors.homeStarSecondary(context),
                iconColor: isDark ? AppColors.gold : AppColors.forest,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PENANDA TERAKHIR',
                      style: AppTokens.cardLabel(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${bookmark.surahName} · Ayat ${bookmark.ayahNumber}',
                      style: AppTokens.bannerTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
