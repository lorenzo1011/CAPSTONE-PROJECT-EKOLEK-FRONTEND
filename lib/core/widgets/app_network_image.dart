import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  final String? url;
  final String semanticLabel;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;

  Widget _fallback() => ColoredBox(
    color: AppColors.surfaceVariant,
    child: Center(
      child: Icon(fallbackIcon, semanticLabel: '$semanticLabel unavailable'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final source = url?.trim();
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        width: width,
        height: height,
        child: source == null || source.isEmpty
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: source,
                fit: fit,
                memCacheWidth: width?.isFinite == true ? width!.round() : null,
                placeholder: (_, _) => const ColoredBox(
                  color: AppColors.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => _fallback(),
              ),
      ),
    );
  }
}
