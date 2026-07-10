import 'package:flutter/material.dart';

/// Design tokens for the "Kinetic Horizon" design system.
abstract class AppColors {
  // Brand
  static const aluNavy = Color(0xFF002147);
  static const vibrantTeal = Color(0xFF00D1C1);
  static const softGold = Color(0xFFFFD700);
  static const background = Color(0xFFF8FAFC);

  // Material 3 color roles
  static const primary = Color(0xFF000A1E);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF002147);
  static const onPrimaryContainer = Color(0xFF708AB5);

  static const secondary = Color(0xFF006A62);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF57FAE9);
  static const onSecondaryContainer = Color(0xFF007168);

  static const tertiary = Color(0xFF705D00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFC9A900);
  static const onTertiaryContainer = Color(0xFF4C3F00);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const surface = Color(0xFFF8F9FF);
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF44474E);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);

  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);
  static const inverseSurface = Color(0xFF213145);
  static const onInverseSurface = Color(0xFFEAF1FF);
  static const inversePrimary = Color(0xFFAEC7F6);
  static const surfaceTint = Color(0xFF465F88);

  static const primaryFixed = Color(0xFFD6E3FF);
  static const primaryFixedDim = Color(0xFFAEC7F6);
  static const onPrimaryFixed = Color(0xFF001B3D);
  static const onPrimaryFixedVariant = Color(0xFF2D476F);
  static const secondaryFixed = Color(0xFF57FAE9);
  static const secondaryFixedDim = Color(0xFF2ADDCD);
  static const onSecondaryFixed = Color(0xFF00201D);
  static const onSecondaryFixedVariant = Color(0xFF005049);
  static const tertiaryFixed = Color(0xFFFFE16D);
  static const tertiaryFixedDim = Color(0xFFE9C400);
  static const onTertiaryFixed = Color(0xFF221B00);
  static const onTertiaryFixedVariant = Color(0xFF544600);

  // Opportunity category tags
  static const internshipBg = Color(0xFFD3E4FE);
  static const internshipText = Color(0xFF3F51B5);
  static const volunteeringBg = Color(0xFFDCFCE7);
  static const volunteeringText = Color(0xFF166534);
  static const fullTimeBg = Color(0xFFFFEDD5);
  static const fullTimeText = Color(0xFF9A3412);

  // Elevation: ambient shadows tinted with ALU Navy at low opacity
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: aluNavy.withValues(alpha: 0.06),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];
}
