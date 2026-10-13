import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:senda/core/design/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums & value types
// ─────────────────────────────────────────────────────────────────────────────

/// Semantic type that controls the default colour palette of a notification.
enum AppNotificationType { info, success, warning, error, loading }

/// Where on the screen the notification appears.
enum AppNotificationPosition { top, bottom }

// ─────────────────────────────────────────────────────────────────────────────
// Internal colour helpers
// ─────────────────────────────────────────────────────────────────────────────

extension _NotificationTypeTheme on AppNotificationType {
  Color get backgroundColor {
    switch (this) {
      case AppNotificationType.info:
        return AppColors.info;
      case AppNotificationType.success:
        return AppColors.success;
      case AppNotificationType.warning:
        return AppColors.warning;
      case AppNotificationType.error:
        return AppColors.error;
      case AppNotificationType.loading:
        return AppColors.loading;
    }
  }

  Color get indicatorColor {
    switch (this) {
      case AppNotificationType.info:
        return AppColors.infoIndicator;
      case AppNotificationType.success:
        return AppColors.successIndicator;
      case AppNotificationType.warning:
        return AppColors.warningIndicator;
      case AppNotificationType.error:
        return AppColors.errorIndicator;
      case AppNotificationType.loading:
        return AppColors.loadingIndicator;
    }
  }

  IconData get icon {
    switch (this) {
      case AppNotificationType.info:
        return Icons.info_outline_rounded;
      case AppNotificationType.success:
        return Icons.check_circle_outline_rounded;
      case AppNotificationType.warning:
        return Icons.warning_amber_rounded;
      case AppNotificationType.error:
        return Icons.error_outline_rounded;
      case AppNotificationType.loading:
        return Icons.hourglass_top_rounded;
    }
  }
}

extension _PositionConvert on AppNotificationPosition {
  FlushbarPosition get flushbarPosition {
    switch (this) {
      case AppNotificationPosition.top:
        return FlushbarPosition.TOP;
      case AppNotificationPosition.bottom:
        return FlushbarPosition.BOTTOM;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading overlay management
// ─────────────────────────────────────────────────────────────────────────────

Flushbar<void>? _activeLoadingBar;

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extensions
// ─────────────────────────────────────────────────────────────────────────────

extension ContextUI on BuildContext {
  // ── Guards ─────────────────────────────────────────────────────────────────

  /// Returns `true` when this context is still mounted and safe to use.
  bool get _isMounted {
    try {
      // ignore: unnecessary_null_comparison
      return mounted;
    } catch (_) {
      return false;
    }
  }

  // ── showToast ──────────────────────────────────────────────────────────────

  /// Shows a brief, auto-dismissing notification bar (toast-style).
  ///
  /// Parameters:
  /// - [message]  — The text to display (required).
  /// - [title]    — Optional bold title above the message.
  /// - [type]     — Colour palette. Defaults to [AppNotificationType.info].
  /// - [position] — Screen edge. Defaults to [AppNotificationPosition.bottom].
  /// - [duration] — How long before auto-dismiss. Defaults to 3 seconds.
  /// - [action]   — Optional tap label + callback shown as a trailing button.
  /// - [onTap]    — Optional callback when the bar body is tapped.
  Future<void> showToast(
    String message, {
    String? title,
    AppNotificationType type = AppNotificationType.info,
    AppNotificationPosition position = AppNotificationPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    ({String label, VoidCallback onPressed})? action,
    void Function(Flushbar)? onTap,
  }) async {
    if (!_isMounted) return;

    final bar = Flushbar<void>(
      title: title,
      message: message,
      flushbarPosition: position.flushbarPosition,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: type.backgroundColor,
      leftBarIndicatorColor: type.indicatorColor,
      icon: Icon(type.icon, color: Colors.white, size: 26),
      shouldIconPulse: type == AppNotificationType.loading,
      duration: duration,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      boxShadows: [
        BoxShadow(
          color: type.backgroundColor.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      mainButton: action != null
          ? TextButton(
              onPressed: action.onPressed,
              child: Text(
                action.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );

    await bar.show(this);
  }

  // ── showMessage ────────────────────────────────────────────────────────────

  /// Shows a rich, highly customisable message bar.
  ///
  /// Parameters:
  /// - [message]         — The text body (required).
  /// - [title]           — Optional title.
  /// - [type]            — Semantic type controlling default colours/icon.
  /// - [position]        — Screen edge.
  /// - [style]           — FLOATING (default) or GROUNDED (full-width).
  /// - [duration]        — Auto-dismiss duration; null = stays until swiped.
  /// - [isDismissible]   — Whether the user can swipe to dismiss.
  /// - [icon]            — Override the default type icon with any widget.
  /// - [backgroundColor] — Override the default type background colour.
  /// - [gradient]        — Gradient overrides [backgroundColor] when set.
  /// - [borderRadius]    — Corner radius (only meaningful with FLOATING style).
  /// - [margin]          — Outer spacing (only meaningful with FLOATING style).
  /// - [showProgress]    — Attach a linear progress indicator.
  /// - [progressController] — Drive the progress indicator externally.
  /// - [action]          — Trailing text button label + callback.
  /// - [onTap]           — Tap callback on the bar body.
  /// - [onStatusChanged] — Called whenever the bar transitions states.
  /// - [routeBlur]       — Blur the route behind the bar when > 0.
  /// - [blockBackground] — Block touches behind the bar.
  Future<T?> showMessage<T>(
    String message, {
    String? title,
    AppNotificationType type = AppNotificationType.info,
    AppNotificationPosition position = AppNotificationPosition.bottom,
    FlushbarStyle style = FlushbarStyle.FLOATING,
    Duration? duration = const Duration(seconds: 4),
    bool isDismissible = true,
    Widget? icon,
    Color? backgroundColor,
    Gradient? gradient,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    bool showProgress = false,
    AnimationController? progressController,
    ({String label, VoidCallback onPressed})? action,
    void Function(Flushbar)? onTap,
    void Function(FlushbarStatus?)? onStatusChanged,
    double routeBlur = 0,
    bool blockBackground = false,
  }) async {
    if (!_isMounted) return null;

    final resolvedBg = backgroundColor ?? type.backgroundColor;

    final bar = Flushbar<T>(
      title: title,
      message: message,
      flushbarPosition: position.flushbarPosition,
      flushbarStyle: style,
      backgroundColor: resolvedBg,
      backgroundGradient: gradient,
      leftBarIndicatorColor: type.indicatorColor,
      icon: icon ?? Icon(type.icon, color: Colors.white, size: 28),
      shouldIconPulse: false,
      duration: duration,
      isDismissible: isDismissible,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      margin:
          margin ??
          (style == FlushbarStyle.FLOATING
              ? const EdgeInsets.all(10)
              : EdgeInsets.zero),
      borderRadius:
          borderRadius ??
          (style == FlushbarStyle.FLOATING
              ? BorderRadius.circular(10)
              : BorderRadius.zero),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      showProgressIndicator: showProgress,
      progressIndicatorController: progressController,
      progressIndicatorBackgroundColor: Colors.white24,
      progressIndicatorValueColor: AlwaysStoppedAnimation(Colors.white),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.fastOutSlowIn,
      routeBlur: routeBlur,
      routeColor: routeBlur > 0 ? Colors.black26 : null,
      blockBackgroundInteraction: blockBackground,
      mainButton: action != null
          ? TextButton(
              onPressed: action.onPressed,
              child: Text(
                action.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : null,
      onTap: onTap,
      onStatusChanged: onStatusChanged,
      boxShadows: gradient == null
          ? [
              BoxShadow(
                color: resolvedBg.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    return bar.show(this);
  }

  // ── showLoading ────────────────────────────────────────────────────────────

  /// Shows a persistent loading bar and returns a callback to dismiss it.
  ///
  /// **Usage:**
  /// ```dart
  /// final dismiss = await context.showLoading('Uploading…');
  /// // ... await your work ...
  /// dismiss(); // hide the loading bar
  /// ```
  ///
  /// Parameters:
  /// - [message]  — Text shown alongside the spinner.
  /// - [position] — Screen edge. Defaults to [AppNotificationPosition.bottom].
  /// - [blockBackground] — Block user interaction behind the bar.
  Future<VoidCallback> showLoading(
    String message, {
    AppNotificationPosition position = AppNotificationPosition.bottom,
    bool blockBackground = false,
  }) async {
    // Dismiss any previously active loading bar first.
    await _activeLoadingBar?.dismiss();
    _activeLoadingBar = null;

    if (!_isMounted) return () {};

    final bar =
        FlushbarHelper.createLoading(
          message: message,
          linearProgressIndicator: const LinearProgressIndicator(
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(Colors.white70),
          ),
        ).copyWith(
          flushbarPosition: position.flushbarPosition,
          isDismissible: false,
          duration: null, // persists until explicitly dismissed
          blockBackgroundInteraction: blockBackground,
          margin: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        );

    _activeLoadingBar = bar;

    // Show without awaiting so the caller can dismiss it later.
    unawaited(bar.show(this));

    return () async {
      await bar.dismiss();
      if (identical(_activeLoadingBar, bar)) {
        _activeLoadingBar = null;
      }
    };
  }

  // ── Convenience wrappers ───────────────────────────────────────────────────

  /// Shorthand for [showToast] with [AppNotificationType.success].
  Future<void> showSuccess(
    String message, {
    String? title,
    AppNotificationPosition position = AppNotificationPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) => showToast(
    message,
    title: title,
    type: AppNotificationType.success,
    position: position,
    duration: duration,
  );

  /// Shorthand for [showToast] with [AppNotificationType.error].
  Future<void> showError(
    String message, {
    String? title,
    AppNotificationPosition position = AppNotificationPosition.bottom,
    Duration duration = const Duration(seconds: 4),
  }) => showToast(
    message,
    title: title,
    type: AppNotificationType.error,
    position: position,
    duration: duration,
  );

  /// Shorthand for [showToast] with [AppNotificationType.warning].
  Future<void> showWarning(
    String message, {
    String? title,
    AppNotificationPosition position = AppNotificationPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) => showToast(
    message,
    title: title,
    type: AppNotificationType.warning,
    position: position,
    duration: duration,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Flushbar copyWith helper (not on the public API – avoids depending on
// package internals while still letting us override a few fields).
// ─────────────────────────────────────────────────────────────────────────────

extension _FlushbarCopyWith<T> on Flushbar<T> {
  Flushbar<T> copyWith({
    FlushbarPosition? flushbarPosition,
    bool? isDismissible,
    Duration? duration,
    bool? blockBackgroundInteraction,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) {
    return Flushbar<T>(
      title: title,
      message: message,
      flushbarPosition: flushbarPosition ?? this.flushbarPosition,
      flushbarStyle: flushbarStyle,
      backgroundColor: backgroundColor,
      backgroundGradient: backgroundGradient,
      leftBarIndicatorColor: leftBarIndicatorColor,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      duration: duration ?? this.duration,
      isDismissible: isDismissible ?? this.isDismissible,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      blockBackgroundInteraction:
          blockBackgroundInteraction ?? this.blockBackgroundInteraction,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      mainButton: mainButton,
      onTap: onTap,
      onStatusChanged: onStatusChanged,
    );
  }
}
