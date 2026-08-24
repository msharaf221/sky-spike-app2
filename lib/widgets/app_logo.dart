import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';

/// Path of the official Sky Spike logo bundled with the app.
const String kSkySpikeLogoAsset = 'assets/images/sky_spike_logo.png';

/// Renders the academy mark: either the official logo asset or the Material
/// icon chosen in Settings, inside a rounded brand-colored badge.
///
/// Falls back to the icon automatically if the asset fails to decode, so a
/// missing/corrupt image can never crash a screen.
class AppLogo extends StatelessWidget {
  /// Overall badge size (the artwork is inset by [padding]).
  final double size;

  /// Inner padding around the artwork.
  final double padding;

  /// Draw the rounded brand-colored badge behind the mark.
  final bool showBadge;

  /// Corner radius of the badge; defaults to ~34% of [size].
  final double? borderRadius;

  /// Override the settings-driven choice of asset vs. icon.
  final bool? useAssetOverride;

  /// Tint applied to the fallback icon.
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 40,
    this.padding = 8,
    this.showBadge = true,
    this.borderRadius,
    this.useAssetOverride,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    return AppLogoMark(
      settings: settings,
      size: size,
      padding: padding,
      showBadge: showBadge,
      borderRadius: borderRadius,
      useAssetOverride: useAssetOverride,
      iconColor: iconColor,
    );
  }
}

/// Stateless variant driven by an explicit [SettingsModel] — useful for live
/// previews of *unsaved* settings.
class AppLogoMark extends StatelessWidget {
  final SettingsModel settings;
  final double size;
  final double padding;
  final bool showBadge;
  final double? borderRadius;
  final bool? useAssetOverride;
  final Color? iconColor;

  /// Badge color override (defaults to the secondary brand color).
  final Color? badgeColor;

  const AppLogoMark({
    super.key,
    required this.settings,
    this.size = 40,
    this.padding = 8,
    this.showBadge = true,
    this.borderRadius,
    this.useAssetOverride,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final useAsset = useAssetOverride ?? settings.useLogoAsset;
    final artSize = (size - padding * 2).clamp(8.0, size);
    final radius = borderRadius ?? size * 0.34;
    final badge = badgeColor ?? settings.secondary;

    final Widget art = useAsset
        ? Image.asset(
            kSkySpikeLogoAsset,
            width: artSize,
            height: artSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stack) => Icon(
              settings.icon,
              size: artSize,
              color: iconColor ?? Colors.white,
            ),
          )
        : Icon(
            settings.icon,
            size: artSize,
            color: iconColor ?? Colors.white,
          );

    if (!showBadge) {
      return SizedBox(width: size, height: size, child: Center(child: art));
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        // The official logo already carries its own navy disc, so keep the
        // badge subtle behind it instead of a solid orange block.
        color: useAsset ? Colors.white.withOpacity(0.12) : badge,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: (useAsset ? AppColors.primaryDark : badge).withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(child: art),
    );
  }
}
