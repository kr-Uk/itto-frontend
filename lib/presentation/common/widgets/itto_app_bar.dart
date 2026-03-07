import 'package:flutter/material.dart';
import 'package:itto/core/theme/app_colors.dart';

class IttoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const IttoAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(title),
      centerTitle: true,
      actions: actions,
    );
  }
}
