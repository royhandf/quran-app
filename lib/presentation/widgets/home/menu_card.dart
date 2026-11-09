import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import 'star_icon_container.dart';

class MenuItem {
  final String label;
  final String arabic;
  final IconData icon;
  final VoidCallback onTap;

  const MenuItem({
    required this.label,
    required this.arabic,
    required this.icon,
    required this.onTap,
  });
}

/// Kartu menu home. [isPrimary] memakai warna gelap dengan teks putih.
class MenuCard extends StatefulWidget {
  final MenuItem item;
  final bool isPrimary;
  final double arabicFontSize;

  const MenuCard({
    super.key,
    required this.item,
    required this.isPrimary,
    required this.arabicFontSize,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.96,
    upperBound: 1.0,
  )..value = 1.0;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.isPrimary;
    final background = primary
        ? AppColors.homePrimarySurface(context)
        : AppColors.homeSurface(context);
    final labelColor = primary ? Colors.white : AppColors.homeInk(context);
    final arabicColor = primary
        ? Colors.white
        : AppColors.homeArabicSecondary(context);
    final containerColor = primary
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.homeStarSecondary(context);
    final iconColor = primary ? Colors.white : AppColors.homeInk(context);

    final arabicStyle = AppTokens.menuArabic(
      context,
      widget.arabicFontSize,
    ).copyWith(color: arabicColor);

    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.item.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _press,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarIconContainer(
                    icon: widget.item.icon,
                    containerColor: containerColor,
                    iconColor: iconColor,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          widget.item.arabic,
                          style: arabicStyle,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                widget.item.label,
                style: AppTokens.menuLabel(
                  context,
                ).copyWith(color: labelColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid 2x3. Jika salah satu nama Arab tidak muat di lebar 110px pada 18px,
/// SEMUA kartu memakai 16px, lalu 14px.
class MenuGrid extends StatelessWidget {
  final List<MenuItem> items;

  const MenuGrid({super.key, required this.items});

  static const double _maxArabicWidth = 110;

  double _resolveArabicFontSize(BuildContext context) {
    for (final size in const [18.0, 16.0, 14.0]) {
      final fitsAll = items.every((item) {
        final painter = TextPainter(
          text: TextSpan(
            text: item.arabic,
            style: AppTokens.menuArabic(context, size),
          ),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: double.infinity);
        return painter.width <= _maxArabicWidth;
      });
      if (fitsAll) return size;
    }
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    final arabicFontSize = _resolveArabicFontSize(context);
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppTokens.itemGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MenuCard(
                  item: items[i],
                  isPrimary: i == 0,
                  arabicFontSize: arabicFontSize,
                ),
              ),
              const SizedBox(width: AppTokens.itemGap),
              if (i + 1 < items.length)
                Expanded(
                  child: MenuCard(
                    item: items[i + 1],
                    isPrimary: false,
                    arabicFontSize: arabicFontSize,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}
