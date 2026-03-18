import 'package:flutter/material.dart';

import 'glass_container.dart';
import 'pressable_scale.dart';

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;
  final double? maxWidth;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: maxWidth == null
            ? const BoxConstraints()
            : BoxConstraints(maxWidth: maxWidth!),
        child: GlassContainer(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
