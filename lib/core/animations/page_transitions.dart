import 'package:flutter/material.dart';

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideUpPageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadeSlidePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.3, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;

            var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}

// Custom page route for auth screens
class AuthPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  AuthPageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;

            // Slide from right
            var slideTween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
              CurveTween(curve: curve),
            );

            // Fade in
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
        );
}

// Extension for easy navigation with animations
extension NavigatorExtension on NavigatorState {
  Future<T?> pushWithSlideUp<T>(Widget page) {
    return push<T>(SlideUpPageRoute(child: page));
  }

  Future<T?> pushWithFadeSlide<T>(Widget page) {
    return push<T>(FadeSlidePageRoute(child: page));
  }

  Future<T?> pushWithScale<T>(Widget page) {
    return push<T>(ScalePageRoute(child: page));
  }

  Future<T?> pushAuth<T>(Widget page) {
    return push<T>(AuthPageRoute(child: page));
  }
}