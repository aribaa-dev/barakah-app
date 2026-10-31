// lib/features/dashboard/presentation/widgets/dashboard_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:order_link/core/theme/app_colors.dart';

enum DashboardTab { dashboard, voiceIntake, orderHistory }

class DashboardBottomBar extends StatelessWidget {
  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onTabSelected;

  const DashboardBottomBar({
    super.key,
    this.selectedTab = DashboardTab.dashboard,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              isSelected: selectedTab == DashboardTab.dashboard,
              onTap: () => onTabSelected(DashboardTab.dashboard),
            ),
          ),
          _MicNavItem(
            isSelected: selectedTab == DashboardTab.voiceIntake,
            onTap: () => onTabSelected(DashboardTab.voiceIntake),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.history_rounded,
              label: 'History',
              isSelected: selectedTab == DashboardTab.orderHistory,
              onTap: () => onTabSelected(DashboardTab.orderHistory),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.grey.shade500;

    return Material(
      type: MaterialType
          .transparency, // InkWell needs a Material to draw its splash on
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Icon(icon, color: color, size: 22),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _MicNavItem({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // The mic now sits INSIDE the bar (54px circle in a 68px bar).
      // Bonus: the whole circle is tappable, because nothing sticks out
      // of the bar's bounds anymore.
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.accent : Colors.white,
        ),
        child: Icon(
          Icons.mic_rounded,
          color: isSelected ? Colors.white : Colors.black,
          size: 26,
        ),
      ),
    );
  }
}
