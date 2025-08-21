import 'package:flutter/material.dart';
import 'package:salesman_mobile/core/theme/app_colors.dart';
import 'package:salesman_mobile/core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool autofocus;
  final int? maxLength;
  final String? counterText;
  final bool showCounter;
  final TextAlign textAlign;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final String? errorText;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final bool? showCursor;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? error;
  final TextStyle? errorStyle;
  final Color? cursorColor;
  final double cursorHeight;
  final double cursorWidth;
  final Radius cursorRadius;
  final bool enableInteractiveSelection;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool enableIMEPersonalizedLearning;
  final TextDirection? textDirection;
  final TextAlignVertical? textAlignVerticalOverride;

  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.contentPadding,
    this.fillColor,
    this.autofocus = false,
    this.maxLength,
    this.counterText,
    this.showCounter = false,
    this.textAlign = TextAlign.start,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.errorText,
    this.expands = false,
    this.textAlignVertical,
    this.showCursor,
    this.helperText,
    this.helperStyle,
    this.error,
    this.errorStyle,
    this.cursorColor,
    this.cursorHeight = 24.0,
    this.cursorWidth = 2.0,
    this.cursorRadius = const Radius.circular(2.0),
    this.enableInteractiveSelection = true,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.enableIMEPersonalizedLearning = true,
    this.textDirection,
    this.textAlignVerticalOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: AppColors.grey300, width: 1.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 4),
        ],
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            filled: true,
            fillColor: fillColor ?? (enabled ? Colors.white : AppColors.grey100),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: border ?? defaultBorder,
            enabledBorder: enabledBorder ?? defaultBorder,
            focusedBorder: focusedBorder ??
                defaultBorder.copyWith(
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
            errorBorder: errorBorder ??
                defaultBorder.copyWith(
                  borderSide: const BorderSide(color: AppColors.error, width: 1.0),
                ),
            focusedErrorBorder: focusedErrorBorder ??
                defaultBorder.copyWith(
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
            errorText: error,
            errorStyle: errorStyle ?? AppTextStyles.errorText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.inputText,
            counterText: showCounter ? null : (counterText ?? ''),
            helperText: helperText,
            helperStyle: helperStyle ?? AppTextStyles.helperText,
            isDense: true,
          ),
          style: AppTextStyles.inputText,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          readOnly: readOnly,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          initialValue: initialValue,
          autofocus: autofocus,
          maxLength: maxLength,
          textAlign: textAlign,
          expands: expands,
          textAlignVertical: textAlignVertical ?? const TextAlignVertical(y: 0.5),
          showCursor: showCursor,
          cursorColor: cursorColor ?? AppColors.primary,
          cursorHeight: cursorHeight,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          enableInteractiveSelection: enableInteractiveSelection,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
          textDirection: textDirection,
        ),
      ],
    );
  }
}
