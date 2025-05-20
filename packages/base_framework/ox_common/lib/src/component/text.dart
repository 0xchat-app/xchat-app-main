
import 'package:flutter/material.dart';

import 'color_token.dart';

typedef _StyleResolver = TextStyle? Function(TextTheme theme);

class CLText extends StatelessWidget {
  const CLText(this.text, {
    super.key,
    this.colorToken,
    this.customColor,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    _StyleResolver? resolver,
  }): _resolver = resolver;

  final String text;
  final ColorToken? colorToken;
  final Color? customColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  final _StyleResolver? _resolver;

  @override
  Widget build(BuildContext context) {
    final style = _resolver?.call(Theme.of(context).textTheme) ?? TextStyle();
    return Text(
      text,
      style: style.copyWith(
        color: colorToken?.of(context) ?? customColor,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory CLText.titleLarge(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.titleLarge,
    );
  }

  factory CLText.titleMedium(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.titleMedium,
    );
  }

  factory CLText.titleSmall(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.titleSmall,
    );
  }

  factory CLText.bodyLarge(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.bodyLarge,
    );
  }

  factory CLText.bodyMedium(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.bodyMedium,
    );
  }

  factory CLText.bodySmall(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.bodySmall,
    );
  }

  factory CLText.labelLarge(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.labelLarge,
    );
  }

  factory CLText.labelMedium(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.labelMedium,
    );
  }

  factory CLText.labelSmall(String text, {
    Key? key,
    ColorToken? colorToken,
    Color? customColor,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CLText(
      text,
      colorToken: colorToken,
      customColor: customColor,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      resolver: (theme) => theme.labelSmall,
    );
  }
}