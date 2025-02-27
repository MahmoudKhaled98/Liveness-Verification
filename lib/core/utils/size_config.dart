import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;
  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;
  static double? fontSize;

  static bool get isInitialized => _mediaQueryData != null;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;

    _safeAreaHorizontal = _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical = _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
    fontSize = blockSizeHorizontal! * 4; // Base font size
  }

  static double getResponsiveHeight(double height) {
    if (!isInitialized) return height;
    return blockSizeVertical! * height;
  }

  static double getResponsiveWidth(double width) {
    if (!isInitialized) return width;
    return blockSizeHorizontal! * width;
  }

  static double getResponsiveFontSize(double size) {
    if (!isInitialized) return size;
    return fontSize! * size / 16;
  }
} 