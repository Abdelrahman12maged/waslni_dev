import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable image provider that caches network images and falls back safely.
ImageProvider appCachedImageProvider(String? imageUrl, {String? fallbackAsset}) {
  if (imageUrl != null &&
      imageUrl.trim().isNotEmpty &&
      imageUrl != 'null' &&
      (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
    return CachedNetworkImageProvider(imageUrl.trim());
  }
  if (fallbackAsset != null && fallbackAsset.isNotEmpty) {
    return AssetImage(fallbackAsset);
  }
  return const AssetImage('assets/images/passenger.png');
}

/// Unified, high-performance cached network image widget.
/// Features built-in shimmer loading placeholder, smooth fade transitions,
/// and customizable error fallbacks.
class AppCachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData? fallbackIcon;
  final Color? backgroundColor;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.placeholder,
    this.errorWidget,
    this.fallbackIcon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final validUrl = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl != 'null' &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    Widget content;
    if (!validUrl) {
      content = _buildErrorWidget();
    } else {
      content = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }

    if (isCircle) {
      return ClipOval(
        child: Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey.shade100,
          child: content,
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey.shade100,
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: content,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.person_rounded,
          size: (width != null && height != null)
              ? (width! < height! ? width! * 0.5 : height! * 0.5)
              : 24,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
