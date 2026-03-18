import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import 'glass_container.dart';
import 'pressable_scale.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final EdgeInsetsGeometry padding;

  const GlassButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: loading ? null : onTap,
      child: GlassContainer(
        radius: 18,
        padding: EdgeInsets.zero,
        gradientColors: [
          AppColors.accent.withOpacity(0.4),
          AppColors.accent2.withOpacity(0.25),
        ],
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: loading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Please wait',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
