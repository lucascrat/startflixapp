import 'package:flutter/material.dart';

/// Responsive helper class for adapting UI to different screen sizes
class ResponsiveHelper {
  static late double screenWidth;
  static late double screenHeight;
  static late bool isSmallScreen;
  static late bool isMediumScreen;
  static late bool isLargeScreen;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // Small: < 360dp (older/budget phones)
    // Medium: 360-400dp (most modern phones including 5.9")
    // Large: > 400dp (large phones, tablets)
    isSmallScreen = screenWidth < 360;
    isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    isLargeScreen = screenWidth >= 400;
  }

  /// Get responsive font size
  static double fontSize(double baseSize) {
    if (isSmallScreen) return baseSize * 0.85;
    if (isMediumScreen) return baseSize * 0.95;
    return baseSize;
  }

  /// Get responsive padding
  static double padding(double basePadding) {
    if (isSmallScreen) return basePadding * 0.7;
    if (isMediumScreen) return basePadding * 0.85;
    return basePadding;
  }

  /// Get responsive icon size
  static double iconSize(double baseSize) {
    if (isSmallScreen) return baseSize * 0.8;
    if (isMediumScreen) return baseSize * 0.9;
    return baseSize;
  }

  /// Get responsive card width for grids
  static double cardWidth(BuildContext context, {int columns = 3}) {
    final width = MediaQuery.of(context).size.width;
    final adjustedColumns = isSmallScreen ? columns - 1 : columns;
    final totalPadding = padding(16) * 2 + (padding(8) * (adjustedColumns - 1));
    return (width - totalPadding) / adjustedColumns;
  }

  /// Get grid cross axis count based on screen width
  static int gridColumns(BuildContext context, {int baseColumns = 3}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 320) return 2;
    if (width < 400) return baseColumns;
    if (width < 600) return baseColumns + 1;
    return baseColumns + 2; // For tablets
  }

  /// Get responsive spacing
  static double spacing(double baseSpacing) {
    if (isSmallScreen) return baseSpacing * 0.7;
    if (isMediumScreen) return baseSpacing * 0.85;
    return baseSpacing;
  }

  /// Get responsive button height
  static double buttonHeight(double baseHeight) {
    if (isSmallScreen) return baseHeight * 0.85;
    if (isMediumScreen) return baseHeight * 0.9;
    return baseHeight;
  }

  /// Get responsive image height for cards
  static double posterHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 140;
    if (width < 400) return 160;
    return 180;
  }

  /// Get responsive aspect ratio for movie cards
  static double posterAspectRatio() {
    if (isSmallScreen) return 0.6;
    if (isMediumScreen) return 0.65;
    return 0.67;
  }
}

/// Extension for easy responsive values
extension ResponsiveContext on BuildContext {
  double rFontSize(double size) => ResponsiveHelper.fontSize(size);
  double rPadding(double size) => ResponsiveHelper.padding(size);
  double rSpacing(double size) => ResponsiveHelper.spacing(size);
  double rIconSize(double size) => ResponsiveHelper.iconSize(size);
  bool get isSmallScreen => ResponsiveHelper.isSmallScreen;
  bool get isMediumScreen => ResponsiveHelper.isMediumScreen;
  bool get isLargeScreen => ResponsiveHelper.isLargeScreen;
}
