import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/services/dzikir_service.dart';
import '../../../data/models/dzikir.dart';
import '../../widgets/star_icon_container.dart';
import 'dzikir_detail_screen.dart';

class DzikirScreen extends StatefulWidget {
  const DzikirScreen({super.key});

  @override
  State<DzikirScreen> createState() => _DzikirScreenState();
}

class _DzikirScreenState extends State<DzikirScreen> {
  late Future<List<DzikirCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = DzikirService.loadCategories();
  }

  static IconData _iconFromString(String name) {
    switch (name) {
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'nights_stay':
        return Icons.nights_stay_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      default:
        return Icons.self_improvement_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Dzikir', style: AppTokens.pageTitle(context)),
      ),
      body: FutureBuilder<List<DzikirCategory>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data',
                style: AppTokens.tileSubtitle(context),
              ),
            );
          }
          final categories = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageMargin,
              8,
              AppTokens.pageMargin,
              32,
            ),
            itemCount: categories.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTokens.itemGap),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _CategoryCard(
                category: cat,
                icon: _iconFromString(cat.icon),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DzikirDetailScreen(category: cat),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final DzikirCategory category;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.homeSurface(context),
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
          child: Row(
            children: [
              StarIconContainer(
                icon: widget.icon,
                containerColor: AppColors.homeStarSecondary(context),
                iconColor: AppColors.homeArabicSecondary(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.category.title,
                      style: AppTokens.menuLabel(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category.subtitle,
                      style: AppTokens.tileSubtitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.category.items.length} bacaan',
                      style: TextStyle(
                        fontFamily: AppTokens.fontLatin,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.homeInkSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
