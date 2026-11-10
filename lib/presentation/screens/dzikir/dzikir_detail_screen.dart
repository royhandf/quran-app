import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/dzikir.dart';

class DzikirDetailScreen extends StatelessWidget {
  final DzikirCategory category;

  const DzikirDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = category.items;
    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.title, style: AppTokens.tileTitle(context)),
            Text(category.subtitle, style: AppTokens.tileSubtitle(context)),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pageMargin,
          8,
          AppTokens.pageMargin,
          32,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.itemGap),
        itemBuilder: (context, index) {
          final item = items[index];
          return _DzikirCard(item: item);
        },
      ),
    );
  }
}

class _DzikirCard extends StatelessWidget {
  final DzikirItem item;

  const _DzikirCard({required this.item});

  static final RegExp _ornamentRegex = RegExp(r'[\uFD3E\uFD3F\u0660-\u0669]+');

  List<TextSpan> _buildArabicSpans(BuildContext context) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _ornamentRegex.allMatches(item.arabic)) {
      if (match.start > last) {
        spans.add(TextSpan(text: item.arabic.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(color: AppColors.gold),
        ),
      );
      last = match.end;
    }
    if (last < item.arabic.length) {
      spans.add(TextSpan(text: item.arabic.substring(last)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.count > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '${item.count}x',
                style: TextStyle(
                  fontFamily: AppTokens.fontLatin,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, item.count > 1 ? 8 : 16, 16, 0),
            child: Text.rich(
              TextSpan(
                children: _buildArabicSpans(context),
                style: TextStyle(
                  fontFamily: AppTokens.fontArabic,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.homeInk(context),
                  height: 2.2,
                ),
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 24, color: AppColors.homeDivider(context)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              item.transliteration,
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.homeInk(context),
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              item.translation,
              style: AppTokens.tileSubtitle(context).copyWith(height: 1.6),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.homeStarSecondary(context),
            child: Text(
              item.source,
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.homeInkSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
