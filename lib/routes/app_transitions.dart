import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Buttery, high-fidelity custom page transitions for GoRouter.
class AppTransitions {
  AppTransitions._();

  /// Fade Through Transition:
  /// Used for bottom navigation shell tab switches (Home, Activity, Pay, Profile).
  /// Smoothly fades out the outgoing view and fades/scales in the incoming view.
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 320),
    Duration reverseDuration = const Duration(milliseconds: 280),
    Color fillColor = Colors.black,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: fillColor,
          child: child,
        );
      },
    );
  }

  /// Shared Axis Scaled Transition:
  /// Used for major screen transitions like Welcome -> Auth / Connect Wallet -> Home.
  /// Delivers a silky smooth depth and scale sensation with easeOutCubic curve.
  static CustomTransitionPage<T> sharedAxisScaled<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 380),
    Duration reverseDuration = const Duration(milliseconds: 320),
    Color fillColor = Colors.black,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedForward = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final curvedSecondary = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SharedAxisTransition(
          animation: curvedForward,
          secondaryAnimation: curvedSecondary,
          transitionType: SharedAxisTransitionType.scaled,
          fillColor: fillColor,
          child: child,
        );
      },
    );
  }

  /// Shared Axis Horizontal Transition:
  /// Buttery smooth horizontal slide with subtle elevation and depth.
  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 360),
    Duration reverseDuration = const Duration(milliseconds: 300),
    Color fillColor = Colors.black,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedForward = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final curvedSecondary = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SharedAxisTransition(
          animation: curvedForward,
          secondaryAnimation: curvedSecondary,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: fillColor,
          child: child,
        );
      },
    );
  }

  /// Buttery Slide-Up Modal Transition:
  /// Used for full-screen flows (Bank Transfer, Airtime, Electricity, Fund Account, etc.).
  /// Rises with an ultra-smooth cubic deceleration curve and subtle fade.
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 380),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // High-end cubic curve for buttery smooth deceleration
        const cubicCurve = Cubic(0.16, 1.0, 0.3, 1.0);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: cubicCurve,
          reverseCurve: Curves.easeInOutCubic,
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade Scale Transition:
  /// Mimics premium OpenContainer transitions with fluid scaling.
  static CustomTransitionPage<T> fadeScale<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 340),
    Duration reverseDuration = const Duration(milliseconds: 280),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
