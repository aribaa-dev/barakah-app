// lib/features/dashboard/presentation/widgets/voice_hint_card.dart
import 'package:flutter/material.dart';
import 'package:order_link/core/theme/app_colors.dart';
import 'package:order_link/core/widgets/app_card.dart';

// Renamed from VoiceHintcard (small "c") -> VoiceHintCard. Classes use UpperCamelCase.
class VoiceHintCard extends StatelessWidget {
  const VoiceHintCard({super.key});

  // The steps are DATA. Want a 5th step? Add one line here.
  static const _steps = [
    'Tap the mic button below',
    'Say shop name → "Al-Noor Store"',
    'List items → "Milk 10 litre, Sugar 5 kg"',
    'Review the auto-generated order summary',
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10, // gap between children (no more SizedBox everywhere)
        children: [
          const _Header(),
          Column(
            spacing: 6,
            children: [
              for (var i = 0; i < _steps.length; i++)
                _HintStep(number: i + 1, text: _steps[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.mic_rounded, size: 16),
        ),
        const Expanded(
          child: Text(
            'Voice Order — How it works',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// A separate WIDGET class instead of a `_buildHintStep()` method.
// Flutter can skip rebuilding a const widget; it cannot skip a method.
class _HintStep extends StatelessWidget {
  final int number;
  final String text;
  const _HintStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textBody,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
