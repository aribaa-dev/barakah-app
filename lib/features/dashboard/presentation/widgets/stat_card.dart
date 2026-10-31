// lib/features/dashboard/presentation/widgets/stat_card.dart
import 'package:flutter/material.dart';
import 'package:order_link/core/theme/app_colors.dart';
import 'package:order_link/core/widgets/app_card.dart';

/// Pure DATA for one card. No widgets inside = easy to test and reuse.
class StatCardModel {
  final String title;
  final String value;
  final bool showCurrency;
  final String footnote;

  /// null  -> no progress bar.
  /// 0..1  -> show a bar filled that much.
  final double? progress;

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool circleBadge;

  const StatCardModel({
    required this.title,
    required this.value,
    required this.footnote,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.showCurrency = false,
    this.progress,
    this.circleBadge = false,
  });
}

/// Pure UI: takes a model, draws it.
class StatCard extends StatelessWidget {
  final StatCardModel model;
  const StatCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded: title takes the leftover space, so a long title
              // can never push the icon off the card.
              Expanded(
                child: Text(
                  model.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _IconBadge(model: model),
            ],
          ),
          const SizedBox(height: 15),
          _ValueText(model: model),
          const SizedBox(height: 12),
          if (model.progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: model.progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            model.footnote,
            style: const TextStyle(fontSize: 10.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  final StatCardModel model;
  const _ValueText({required this.model});

  @override
  Widget build(BuildContext context) {
    const bigStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      letterSpacing: -0.5,
      height: 1.1,
    );

    if (!model.showCurrency) return Text(model.value, style: bigStyle);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Rs. ',
            style: bigStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          TextSpan(text: model.value),
        ],
      ),
      style: bigStyle,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final StatCardModel model;
  const _IconBadge({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: model.iconBackground,
        shape: model.circleBadge ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: model.circleBadge ? null : BorderRadius.circular(10),
      ),
      child: Icon(model.icon, color: model.iconColor, size: 20),
    );
  }
}
