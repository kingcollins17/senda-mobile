import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:senda/core/app_strings.dart';
import 'package:senda/core/design/app_colors.dart';

/// A premium, customizable bottom sheet modal for confirmations
/// such as logging out, disconnecting wallets, or destructive actions.
class ConfirmationSheet extends StatelessWidget {
  /// The main heading displayed on the sheet.
  final String title;

  /// Optional explanatory subtitle/message.
  final String? message;

  /// Optional custom body widget rendered below the message.
  final Widget? customBody;

  /// Text for the confirm action button. Defaults to [AppStrings.confirm].
  final String confirmText;

  /// Text for the cancel action button. Defaults to [AppStrings.cancel].
  final String cancelText;

  /// Callback executed when the confirm button is pressed.
  final VoidCallback? onConfirm;

  /// Callback executed when the cancel button is pressed.
  final VoidCallback? onCancel;

  /// Whether this confirmation represents a destructive action.
  /// When true, defaults the confirm button and icon styling to alert / red accents.
  final bool isDestructive;

  /// Optional icon data displayed in a badge at the top of the sheet.
  final IconData? icon;

  /// Optional custom icon or illustration widget displayed at the top.
  final Widget? iconWidget;

  /// Color of the badge icon.
  final Color? iconColor;

  /// Background color for the icon badge container.
  final Color? iconBackgroundColor;

  /// Background color of the confirm button.
  final Color? confirmButtonColor;

  /// Text/foreground color of the confirm button.
  final Color? confirmTextColor;

  /// Border side or background color for the cancel button.
  final Color? cancelButtonColor;

  /// Text color for the cancel button.
  final Color? cancelTextColor;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the message.
  final TextStyle? messageStyle;

  /// Background color of the bottom sheet surface. Defaults to [AppColors.dialogSurface].
  final Color? backgroundColor;

  /// Custom border radius for the sheet. Defaults to top corners 24px.
  final BorderRadiusGeometry? borderRadius;

  /// Custom padding inside the sheet container.
  final EdgeInsetsGeometry? padding;

  /// Whether to render the drag handle indicator at the top.
  final bool showDragHandle;

  /// Whether to render the cancel button.
  final bool showCancelButton;

  /// Optional custom actions row/list to replace the default cancel/confirm buttons.
  final List<Widget>? customActions;

  const ConfirmationSheet({
    super.key,
    required this.title,
    this.message,
    this.customBody,
    this.confirmText = AppStrings.confirm,
    this.cancelText = AppStrings.cancel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconBackgroundColor,
    this.confirmButtonColor,
    this.confirmTextColor,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.titleStyle,
    this.messageStyle,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.showDragHandle = true,
    this.showCancelButton = true,
    this.customActions,
  });

  /// Displays the [ConfirmationSheet] as a modal bottom sheet.
  ///
  /// Returns `true` if the user confirmed, `false` if cancelled,
  /// or `null` if dismissed by tapping outside or dragging down.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? customBody,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? confirmButtonColor,
    Color? confirmTextColor,
    Color? cancelButtonColor,
    Color? cancelTextColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    bool showDragHandle = true,
    bool showCancelButton = true,
    List<Widget>? customActions,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      builder: (sheetContext) => ConfirmationSheet(
        title: title,
        message: message,
        customBody: customBody,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        icon: icon,
        iconWidget: iconWidget,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        confirmButtonColor: confirmButtonColor,
        confirmTextColor: confirmTextColor,
        cancelButtonColor: cancelButtonColor,
        cancelTextColor: cancelTextColor,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        showDragHandle: showDragHandle,
        showCancelButton: showCancelButton,
        customActions: customActions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconData =
        icon ?? (isDestructive ? Icons.warning_amber_rounded : null);
    final hasIcon = iconWidget != null || effectiveIconData != null;

    final resolvedConfirmBg =
        confirmButtonColor ?? (isDestructive ? Colors.redAccent : Colors.white);
    final resolvedConfirmFg =
        confirmTextColor ?? (isDestructive ? Colors.white : Colors.black);

    final resolvedIconBg =
        iconBackgroundColor ??
        (isDestructive
            ? Colors.redAccent.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08));
    final resolvedIconBorder = isDestructive
        ? Colors.redAccent.withValues(alpha: 0.28)
        : Colors.white12;
    final resolvedIconColor =
        iconColor ?? (isDestructive ? Colors.redAccent : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.dialogSurface,
        borderRadius:
            borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDragHandle) ...[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (hasIcon) ...[
                Center(
                  child:
                      iconWidget ??
                      Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: resolvedIconBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: resolvedIconBorder),
                            ),
                            child: Icon(
                              effectiveIconData,
                              size: 28,
                              color: resolvedIconColor,
                            ),
                          )
                          .animate()
                          .scale(duration: 350.ms, curve: Curves.easeOutBack)
                          .fade(duration: 300.ms),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    titleStyle ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style:
                      messageStyle ??
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                ),
              ],
              if (customBody != null) ...[
                const SizedBox(height: 16),
                customBody!,
              ],
              const SizedBox(height: 28),
              if (customActions != null)
                Row(
                  children: customActions!
                      .map((action) => Expanded(child: action))
                      .toList(),
                )
              else
                Row(
                  children: [
                    if (showCancelButton) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            onCancel?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cancelTextColor ?? Colors.white,
                            side: BorderSide(
                              color: cancelButtonColor ?? Colors.white24,
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: resolvedConfirmBg,
                          foregroundColor: resolvedConfirmFg,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
