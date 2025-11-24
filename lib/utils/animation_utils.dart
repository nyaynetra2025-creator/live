import 'package:flutter/material.dart';

/// Animation duration constants for consistent timing across the app
class AnimationDurations {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration ultraSlow = Duration(milliseconds: 1200);
}

/// Animation curve constants for consistent motion
class AnimationCurves {
  static const Curve smooth = Curves.easeInOut;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve quick = Curves.easeOut;
  static const Curve snappy = Curves.easeInOutCubic;
  static const Curve gentle = Curves.easeInOutQuad;
}

/// Stagger delay calculator for sequential animations
class StaggerDelay {
  static Duration forIndex(int index, {Duration baseDelay = const Duration(milliseconds: 100)}) {
    return Duration(milliseconds: baseDelay.inMilliseconds * index);
  }
}

/// Hero tag generator for consistent hero animations
class HeroTags {
  static const String logo = 'app_logo';
  static const String profileImage = 'profile_image';
  static String featureCard(String id) => 'feature_card_$id';
  static String newsCard(String id) => 'news_card_$id';
}
