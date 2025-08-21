import 'package:flutter/material.dart';
import 'package:salesman_mobile/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isFullWidth;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final double elevation;
  final Color? borderColor;
  final double borderWidth;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.padding,
    this.isFullWidth = false,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primary : Colors.white,
              ),
            ),
          )
        : child;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined
          ? Colors.transparent
          : (isDisabled ? AppColors.grey300 : backgroundColor ?? AppColors.primary),
      foregroundColor: textColor ?? (isOutlined ? AppColors.primary : Colors.white),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: isOutlined
            ? BorderSide(
                color: isDisabled ? AppColors.grey400 : borderColor ?? AppColors.primary,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
      elevation: elevation,
      minimumSize: Size(
        isFullWidth ? double.infinity : (width ?? 0),
        height ?? 48.0,
      ),
    );

    return ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}
