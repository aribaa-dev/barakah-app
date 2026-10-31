// lib/features/dashboard/presentation/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardHeader extends StatelessWidget {
  final String businessName;
  final String salesmanName;
  final String? logoImagePath;
  final VoidCallback? onLogoTap;

  const DashboardHeader({
    super.key,
    required this.businessName, // no hidden default: the screen decides
    required this.salesmanName,
    this.logoImagePath,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 10,
          children: [
            _Logo(imagePath: logoImagePath, onTap: onLogoTap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    salesmanName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          spacing: 6,
          children: [
            const Icon(Icons.calendar_month, size: 20, color: Colors.white),
            Expanded(
              child: Text(
                // intl does the weekday/month names for us:
                // "Thursday, 1 October". Replaces 30 lines of manual lists.
                // RIVERPOD: you already have a date provider -> pass it in
                // (or ref.watch it in a small ConsumerWidget) instead of
                // calling DateTime.now() here.
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  const _Logo({this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.storefront, color: Colors.black54);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: imagePath == null
            ? fallback
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => fallback,
                ),
              ),
      ),
    );
  }
}
