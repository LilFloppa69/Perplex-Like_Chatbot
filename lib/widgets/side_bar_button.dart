import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';

class SideBarButton extends StatelessWidget {
  final bool isCollapsed;
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const SideBarButton({
    super.key,
    required this.isCollapsed,
    required this.icon,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isSelected ? Colors.white : AppColors.iconGrey;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      splashColor: Colors.white24,
      hoverColor: Colors.white10,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isCollapsed ? 0 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: baseColor,
              size: 22,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: baseColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
