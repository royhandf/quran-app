import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_tokens.dart';

class SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const SheetShell({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.7;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
      ),
    );
  }
}

class SheetButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const SheetButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SheetOptionTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailingPreview;

  const SheetOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.trailingPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.forest : AppColors.homeOptionSurface(context),
      borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? Colors.white
                      : AppColors.homeInkSecondary(context),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTokens.fontLatin,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.homeInk(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTokens.tileSubtitle(context).copyWith(
                          color: selected
                              ? Colors.white70
                              : AppColors.homeInkSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (trailingPreview != null) ...[
                trailingPreview!,
                const SizedBox(width: 10),
              ],
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.gold,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
