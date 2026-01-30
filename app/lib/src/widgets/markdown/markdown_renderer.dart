import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/config/constants/color_constants.dart';

/// A reusable markdown renderer component that uses flutter_markdown library
/// to render markdown content with customizable styling options.
class MarkdownRenderer extends StatelessWidget {
  /// The markdown content to be rendered
  final String data;

  /// Optional custom style sheet for the markdown
  final MarkdownStyleSheet? styleSheet;

  /// Whether to shrink wrap the content or not
  final bool shrinkWrap;

  /// Whether to enable selection of text
  final bool selectable;

  /// Whether to pad the markdown content
  final bool paddingEnabled;

  /// Padding values when paddingEnabled is true
  final EdgeInsets padding;

  /// Controller for scrolling the markdown content
  final ScrollController? controller;

  /// Background color of the markdown container
  final Color? backgroundColor;

  /// Callback when user taps on images
  final void Function(String)? onTapImage;

  /// Initial scroll offset
  final double initialScrollOffset;

  /// Physics for the scrolling behavior
  final ScrollPhysics? physics;

  /// Fixed height for the container (to avoid infinite height issues)
  final double? fixedHeight;

  const MarkdownRenderer({
    Key? key,
    required this.data,
    this.styleSheet,
    this.shrinkWrap = false,
    this.selectable = false,
    this.paddingEnabled = true,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.backgroundColor,
    this.onTapImage,
    this.initialScrollOffset = 0.0,
    this.physics,
    this.fixedHeight,
  }) : super(key: key);

  String _decodeText(String text) {
    try {
      // First try UTF-8 decoding
      return utf8.decode(text.codeUnits, allowMalformed: true);
    } catch (e) {
      try {
        // If UTF-8 fails, try Latin-1 decoding
        return latin1.decode(text.codeUnits);
      } catch (e) {
        // If all decoding fails, return the original text
        return text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decodedData = _decodeText(data);

    // Default style sheet based on app theme if not provided
    final defaultStyleSheet = MarkdownStyleSheet(
      // Text styles
      a: TextStyle(
        color: ColorConstants.primaryAppColor,
        decoration: TextDecoration.underline,
        fontFamily: 'Lato',
      ),
      p: theme.primaryTextTheme.bodyMedium?.copyWith(
        color: ColorConstants.black,
        height: 1.5,
        fontFamily: 'Noto Sans', // Add Noto Sans for better Hindi support
      ),
      h1: theme.primaryTextTheme.headlineLarge?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      h2: theme.primaryTextTheme.headlineMedium?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      h3: theme.primaryTextTheme.titleLarge?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      h4: theme.primaryTextTheme.titleMedium?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      h5: theme.primaryTextTheme.titleSmall?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      h6: theme.primaryTextTheme.bodyLarge?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        fontFamily: 'Noto Sans',
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans',
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        backgroundColor: ColorConstants.lavenderSecondaryColor.withOpacity(0.2),
      ),
      blockquote: theme.primaryTextTheme.bodyMedium?.copyWith(
        color: ColorConstants.tertiaryBlack,
        fontStyle: FontStyle.italic,
        fontFamily: 'Noto Sans',
      ),

      // Block spacing
      blockSpacing: 16.0,
      listIndent: 24.0,
      listBulletPadding: const EdgeInsets.only(right: 8.0),
      tableCellsPadding: const EdgeInsets.all(8.0),
      tableBorder: TableBorder.all(
        color: ColorConstants.borderColor,
        width: 1.0,
      ),
      blockquotePadding: const EdgeInsets.all(16.0),
      blockquoteDecoration: BoxDecoration(
        color: ColorConstants.aliceBlueColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: ColorConstants.lavenderSecondaryColor,
          width: 1.0,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16.0),
      codeblockDecoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(4.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: ColorConstants.borderColor,
          ),
        ),
      ),
    );

    // Determine which style sheet to use
    final effectiveStyleSheet = styleSheet ?? defaultStyleSheet;

    // Widget for rendering markdown
    Widget markdownWidget;

    if (selectable) {
      markdownWidget = MarkdownBody(
        data: decodedData,
        styleSheet: effectiveStyleSheet,
        selectable: true,
        onTapLink: _handleLinkTap,
        imageBuilder: _buildImage,
      );
    } else {
      // For non-selectable text, we'll handle scrolling ourselves if no fixed height
      if (fixedHeight != null) {
        markdownWidget = SizedBox(
          height: fixedHeight,
          child: Markdown(
            data: decodedData,
            styleSheet: effectiveStyleSheet,
            shrinkWrap: true,
            selectable: false,
            onTapLink: _handleLinkTap,
            controller: controller ??
                ScrollController(initialScrollOffset: initialScrollOffset),
            physics: physics,
            imageBuilder: _buildImage,
          ),
        );
      } else if (shrinkWrap) {
        // When shrinkWrap is true, use MarkdownBody to avoid scrolling issues
        markdownWidget = MarkdownBody(
          data: decodedData,
          styleSheet: effectiveStyleSheet,
          selectable: false,
          onTapLink: _handleLinkTap,
          imageBuilder: _buildImage,
        );
      } else {
        // If not shrinkwrap and no fixed height, provide a default height
        markdownWidget = SizedBox(
          height: 300, // Default height - can be adjusted as needed
          child: Markdown(
            data: decodedData,
            styleSheet: effectiveStyleSheet,
            shrinkWrap: false,
            selectable: false,
            onTapLink: _handleLinkTap,
            controller: controller ??
                ScrollController(initialScrollOffset: initialScrollOffset),
            physics: physics,
            imageBuilder: _buildImage,
          ),
        );
      }
    }

    // Apply padding if enabled
    return Container(
      color: backgroundColor,
      padding: paddingEnabled ? padding : EdgeInsets.zero,
      child: markdownWidget,
    );
  }

  /// Custom image builder
  Widget _buildImage(Uri uri, String? title, String? alt) {
    return GestureDetector(
      onTap: onTapImage != null ? () => onTapImage!(uri.toString()) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: ColorConstants.aliceBlueColor,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: ColorConstants.darkGrey,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 100,
              color: ColorConstants.secondaryWhite,
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.primaryAppColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Handle link taps by launching URLs
  Future<void> _handleLinkTap(String text, String? href, String title) async {
    if (href == null) return;

    final url = Uri.parse(href);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// A simplified version of MarkdownRenderer with default settings for quick usage
class SimpleMarkdownRenderer extends StatelessWidget {
  final String data;
  final bool selectable;
  final double? height;

  const SimpleMarkdownRenderer({
    Key? key,
    required this.data,
    this.selectable = false,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownRenderer(
      data: data,
      selectable: selectable,
      shrinkWrap: true,
      paddingEnabled: true,
      padding: const EdgeInsets.all(12.0),
      backgroundColor: ColorConstants.white,
      fixedHeight: height,
    );
  }
}

/// Helper class to provide predefined markdown style variants
class MarkdownStyles {
  /// Default style for regular content
  static MarkdownStyleSheet regular(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet(
      p: theme.primaryTextTheme.bodyMedium?.copyWith(
        color: ColorConstants.black,
        height: 1.5,
      ),
      a: TextStyle(
        color: ColorConstants.primaryAppColor,
        decoration: TextDecoration.underline,
      ),
      blockquoteDecoration: BoxDecoration(
        color: ColorConstants.aliceBlueColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: ColorConstants.lavenderSecondaryColor,
          width: 1.0,
        ),
      ),
    );
  }

  /// Compact style for limited space
  static MarkdownStyleSheet compact(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet(
      p: theme.primaryTextTheme.bodySmall?.copyWith(
        color: ColorConstants.black,
        height: 1.3,
      ),
      a: TextStyle(
        color: ColorConstants.primaryAppColor,
        decoration: TextDecoration.underline,
        fontSize: 12,
      ),
      h1: theme.primaryTextTheme.titleLarge?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
      ),
      h2: theme.primaryTextTheme.titleMedium?.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.bold,
      ),
      blockSpacing: 8.0,
      listIndent: 16.0,
    );
  }
}
