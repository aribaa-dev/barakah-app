import 'package:flutter/material.dart';

class BigRecordButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const BigRecordButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 30),
      ),
    );
  }
}

class SmallRecordButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const SmallRecordButton({
    super.key,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
