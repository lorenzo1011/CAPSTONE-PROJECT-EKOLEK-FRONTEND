import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RewardImage extends StatelessWidget {
  const RewardImage({super.key, required this.name, this.url, this.heroTag});
  final String name;
  final String? url;
  final Object? heroTag;
  @override
  Widget build(BuildContext context) {
    Widget child = url == null
        ? const _Fallback()
        : CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, _, _) => const _Fallback(),
          );
    child = Semantics(
      image: true,
      label: 'Artwork for $name',
      child: AspectRatio(aspectRatio: 4 / 3, child: child),
    );
    return heroTag == null ? child : Hero(tag: heroTag!, child: child);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(child: Icon(Icons.redeem_rounded, size: 56)),
  );
}
