import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class BikeImage extends StatelessWidget {
  final String image;
  final BoxFit fit;

  const BikeImage({super.key, required this.image, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (image.startsWith("data:image")) {
      final commaIndex = image.indexOf(",");
      if (commaIndex != -1) {
        final bytes = base64Decode(image.substring(commaIndex + 1));
        return Image.memory(bytes, fit: fit);
      }
    }

    if (image.isEmpty) return const _ImageFallback();

    return Image.network(
      image,
      fit: fit,
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.imageFallback,
      alignment: Alignment.center,
      child: const Icon(Icons.two_wheeler, color: Colors.black38),
    );
  }
}
