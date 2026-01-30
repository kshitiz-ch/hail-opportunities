import 'dart:io';
import 'dart:ui' as ui;

import 'package:api_sdk/log_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service class for creating birthday cards with watermarks
class BirthdayCardService {
  // Cache for branding image bytes to avoid repeated network calls
  static final Map<String, Uint8List> _imageCache = {};

  /// Creates a birthday card image with a watermark/logo positioned at bottom right
  /// [backgroundImagePath] - Path to the main birthday card background image
  /// [watermarkImagePath] - Path to the logo/watermark image to overlay
  /// [width] - Output image width (default: 400)
  /// [height] - Output image height (default: 600)
  /// [watermarkSize] - Size of the watermark (default: 80)
  /// [marginFromEdge] - Margin from bottom-right edge (default: 20)
  /// [qualityMultiplier] - Quality multiplier for better image quality (default: 3.0)
  /// Returns the image bytes that can be saved, shared, or displayed
  static Future<Uint8List?> createBirthdayCard({
    required String backgroundImagePath,
    required String watermarkImagePath,
    double width = 400,
    double height = 600,
    double marginFromEdge = 20,
    double qualityMultiplier = 4.0,
  }) async {
    try {
      // Load background image
      final backgroundBytes = await loadImageBytes(backgroundImagePath);
      if (backgroundBytes == null) {
        LogUtil.printLog(
            'Failed to load background image: $backgroundImagePath');
        return null;
      }

      // Load watermark image with caching
      final watermarkBytes = await _loadImageBytesWithCache(watermarkImagePath);
      if (watermarkBytes == null) {
        LogUtil.printLog('Failed to load watermark image: $watermarkImagePath');
        return null;
      }

      // Create birthday card using native image processing
      final result = await _createBirthdayCard(
        backgroundImageBytes: backgroundBytes,
        watermarkImageBytes: watermarkBytes,
        width: width,
        height: height,
        marginFromEdge: marginFromEdge,
        qualityMultiplier: qualityMultiplier,
      );

      return result;
    } catch (error) {
      LogUtil.printLog('Error creating birthday card: ${error.toString()}');
      return null;
    }
  }

  /// Creates birthday card using native image processing
  static Future<Uint8List?> _createBirthdayCard({
    required Uint8List backgroundImageBytes,
    required Uint8List watermarkImageBytes,
    required double width,
    required double height,
    required double marginFromEdge,
    required double qualityMultiplier,
  }) async {
    try {
      // Calculate high-resolution dimensions for better quality
      final highResWidth = (width * qualityMultiplier).toInt();
      final highResHeight = (height * qualityMultiplier).toInt();
      final highResMargin = marginFromEdge * qualityMultiplier;

      // Decode images at high resolution
      final backgroundCodec = await ui.instantiateImageCodec(
        backgroundImageBytes,
        targetWidth: highResWidth,
        targetHeight: highResHeight,
      );
      final backgroundFrame = await backgroundCodec.getNextFrame();
      final backgroundImage = backgroundFrame.image;

      final watermarkSize = Size(60 * qualityMultiplier,
          40 * qualityMultiplier); // Scaled watermark size

      // Decode watermark with scaled size
      final watermarkCodec = await ui.instantiateImageCodec(
        watermarkImageBytes,
        targetWidth: watermarkSize.width.toInt(),
        targetHeight: watermarkSize.height.toInt(),
      );
      final watermarkFrame = await watermarkCodec.getNextFrame();
      final watermarkImage = watermarkFrame.image;

      // Create a canvas to compose the images at high resolution
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background image with high quality paint
      final backgroundPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;
      canvas.drawImage(backgroundImage, Offset.zero, backgroundPaint);

      // Draw watermark at bottom right with specified margin
      final watermarkPaint = Paint()
        ..filterQuality = FilterQuality.high
        ..isAntiAlias = true;
      final watermarkOffset = Offset(
        highResWidth - watermarkSize.width - highResMargin,
        highResHeight - watermarkSize.height - highResMargin,
      );
      canvas.drawImage(watermarkImage, watermarkOffset, watermarkPaint);

      // Convert to high-resolution image first
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        highResWidth,
        highResHeight,
      );

      // Convert to bytes (keeping high resolution)
      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      // Clean up resources
      backgroundImage.dispose();
      watermarkImage.dispose();
      finalImage.dispose();
      picture.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to create birthday card: ${e.toString()}');
    }
  }

  /// Loads image bytes with caching for network images
  static Future<Uint8List?> _loadImageBytesWithCache(String imagePath) async {
    // Check cache first for network images
    if ((imagePath.startsWith('http://') || imagePath.startsWith('https://')) &&
        _imageCache.containsKey(imagePath)) {
      LogUtil.printLog('Using cached image bytes for: $imagePath');
      return _imageCache[imagePath];
    }

    // Load image bytes
    final bytes = await loadImageBytes(imagePath);

    // Cache network images
    if (bytes != null &&
        (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      _imageCache[imagePath] = bytes;
      LogUtil.printLog('Cached image bytes for: $imagePath');
    }

    return bytes;
  }

  /// Loads image bytes from file path, asset, or URL
  static Future<Uint8List?> loadImageBytes(String imagePath) async {
    try {
      if (imagePath.startsWith('assets/')) {
        // Load from assets
        final byteData = await rootBundle.load(imagePath);
        return byteData.buffer.asUint8List();
      } else if (imagePath.startsWith('http://') ||
          imagePath.startsWith('https://')) {
        // Load from URL
        LogUtil.printLog('Loading image from URL: $imagePath');

        try {
          final bytes = await NetworkAssetBundle(Uri.parse(imagePath))
              .load(imagePath)
              .then((byteData) => byteData.buffer.asUint8List());
          return bytes;
        } catch (e) {
          LogUtil.printLog('Error loading image from URL: ${e.toString()}');
          return null;
        }
      } else {
        // Load from file
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        } else {
          LogUtil.printLog('File does not exist: $imagePath');
          return null;
        }
      }
    } catch (e) {
      LogUtil.printLog('Error in _loadImageBytes: ${e.toString()}');
      return null;
    }
  }

  /// Clears the image cache
  static void clearCache() {
    _imageCache.clear();
    LogUtil.printLog('Cleared birthday card service image cache');
  }

  /// Clears a specific image from cache
  static void clearImageFromCache(String imagePath) {
    if (_imageCache.remove(imagePath) != null) {
      LogUtil.printLog('Removed image from cache: $imagePath');
    }
  }

  /// Gets the current cache size
  static int get cacheSize => _imageCache.length;

  /// Gets the cached image paths
  static List<String> get cachedImagePaths => _imageCache.keys.toList();
}
