import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/core/theme/app_colors.dart';
import 'package:salesman_mobile/core/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.elevation = 0,
    this.backgroundColor,
    this.titleColor,
    this.bottom,
    this.titleSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Get.back(),
            )
          : null,
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Colors.white,
      centerTitle: true,
      bottom: bottom,
      titleSpacing: titleSpacing,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        bottom != null
            ? kToolbarHeight + bottom!.preferredSize.height
            : kToolbarHeight,
      );
}
