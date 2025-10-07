import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads an image-like asset that may be an SVG wrapping an embedded PNG.
///
/// Behavior:
/// - Loads asset as string with rootBundle.loadString(path).
/// - If the asset contains a data:image/...;base64, extracts and decodes it and
///   renders with Image.memory.
/// - Otherwise attempts to render the SVG via SvgPicture.string.
class FlagImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FlagImage.asset(
    this.assetPath, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<FlagImage> createState() => _FlagImageState();
}

class _FlagImageState extends State<FlagImage> {
  Uint8List? _bytes; // decoded embedded image
  String? _svgString;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    try {
      final content = await rootBundle.loadString(widget.assetPath);

      // Search for data URI like data:image/png;base64,....
      final reg = RegExp(r'data:image\/[a-zA-Z0-9.+-]+;base64,([A-Za-z0-9+/=]+)');
      final match = reg.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        final b64 = match.group(1)!;
        final decoded = base64Decode(b64);
        setState(() {
          _bytes = decoded;
          _loading = false;
        });
        return;
      }

      // No embedded raster found — use the SVG string
      setState(() {
        _svgString = content;
        _loading = false;
      });
    } catch (e) {
      // On error, keep _loading false and no data; UI will show an empty box
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    if (_svgString != null) {
      try {
        return SvgPicture.string(
          _svgString!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      } catch (_) {
        return SizedBox(width: widget.width, height: widget.height);
      }
    }

    return SizedBox(width: widget.width, height: widget.height);
  }
}
