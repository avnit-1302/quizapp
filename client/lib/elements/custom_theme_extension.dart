import 'package:flutter/material.dart';

/// The custom theme extension
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color primaryTextColor;

  CustomThemeExtension({required this.primaryTextColor});

  @override
  CustomThemeExtension copyWith({
    Color? primaryTextColor,
  }) {
    return CustomThemeExtension(
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
    );
  }
  
}