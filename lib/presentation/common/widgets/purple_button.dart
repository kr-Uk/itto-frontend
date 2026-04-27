import 'package:flutter/material.dart';
import 'package:itto/core/theme/app_colors.dart';

class PurpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;

  const PurpleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.pillGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x40A78BFA),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.pillText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
