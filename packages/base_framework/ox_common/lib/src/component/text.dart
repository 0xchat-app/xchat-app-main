
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'color_token.dart';
import 'platform_style.dart';

typedef _StyleResolver = TextStyle? Function(BuildContext context);

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
    final style = _resolver?.call(context) ?? TextStyle();
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
      resolver: (context) => Theme.of(context).textTheme.titleLarge,
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
      resolver: (context) => PlatformStyle
          .isUseMaterial
          ? Theme.of(context).textTheme.titleMedium
          : CupertinoTheme.of(context).textTheme.actionSmallTextStyle,
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
      resolver: (context) => Theme.of(context).textTheme.titleSmall,
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
      resolver: (context) => Theme.of(context).textTheme.bodyLarge,
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
      resolver: (context) => Theme.of(context).textTheme.bodyMedium,
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
      resolver: (context) => Theme.of(context).textTheme.bodySmall,
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
      resolver: (context) => Theme.of(context).textTheme.labelLarge,
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
      resolver: (context) => Theme.of(context).textTheme.labelMedium,
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
      resolver: (context) => Theme.of(context).textTheme.labelSmall,
    );
  }

  factory CLText.headlineSmall(String text, {
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
      resolver: (context) => Theme.of(context).textTheme.headlineSmall,
    );
  }
}

typedef CLHighlightTap = void Function(String match);

class CLHighlightRule {
  const CLHighlightRule({
    required this.pattern,
    this.style,
    this.onTap,
    this.cursor,
  });

  final Pattern pattern;
  final TextStyle? style;
  final CLHighlightTap? onTap;
  final MouseCursor? cursor;
}

class CLHighlightRange {
  const CLHighlightRange({
    required this.range,
    this.style,
    this.onTap,
  });

  final TextRange range;
  final TextStyle? style;
  final CLHighlightTap? onTap;
}

class _ResolvedHit {
  _ResolvedHit({
    required this.start,
    required this.end,
    required this.style,
    this.onTap,
    this.cursor,
  });

  final int start;
  final int end;
  final TextStyle? style;
  final CLHighlightTap? onTap;
  final MouseCursor? cursor;
}

extension CLTextHighlightFactory on CLText {
   /// Convert this `CLText` into a rich `Text` widget that supports
   /// partial highlighting via rules or explicit ranges. All text
   /// presentation properties are inherited from this `CLText` instance.
   Widget highlighted({
     Key? key,
     List<CLHighlightRule>? rules,
     List<CLHighlightRange>? ranges,
   }) {
     return _CLTextRich(
       text: text,
       key: key,
       colorToken: colorToken,
       customColor: customColor,
       fontWeight: fontWeight,
       textAlign: textAlign,
       maxLines: maxLines,
       overflow: overflow,
       rules: rules,
       ranges: ranges,
       resolver: _resolver,
     );
   }
}

class _CLTextRich extends StatefulWidget {
  const _CLTextRich({
    super.key,
    required this.text,
    this.colorToken,
    this.customColor,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.rules,
    this.ranges,
    this.resolver,
  });

  final String text;
  final ColorToken? colorToken;
  final Color? customColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final List<CLHighlightRule>? rules;
  final List<CLHighlightRange>? ranges;
  final _StyleResolver? resolver;

  @override
  State<_CLTextRich> createState() => _CLTextRichState();
}

class _CLTextRichState extends State<_CLTextRich> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final base = (widget.resolver?.call(context) ?? const TextStyle()).copyWith(
      color: widget.colorToken?.of(context) ?? widget.customColor,
      fontWeight: widget.fontWeight,
    );

    final hits = _collectHits(widget.text, base, widget.rules, widget.ranges);
    // Default link style for clickable segments if no color is specified
    final defaultLinkStyle = TextStyle(
      color: ColorToken.primary.of(context),
    );
    final spans = _buildSpans(widget.text, base, hits, defaultLinkStyle);

    return Text.rich(
      TextSpan(children: spans, style: base),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  List<_ResolvedHit> _collectHits(
      String text,
      TextStyle base,
      List<CLHighlightRule>? rules,
      List<CLHighlightRange>? ranges,
      ) {
    final List<_ResolvedHit> out = [];

    if (rules != null) {
      for (final rule in rules) {
        if (rule.pattern is RegExp) {
          final reg = rule.pattern as RegExp;
          for (final m in reg.allMatches(text)) {
            out.add(_ResolvedHit(
              start: m.start,
              end: m.end,
              style: rule.style,
              onTap: rule.onTap,
              cursor: rule.cursor,
            ));
          }
        } else if (rule.pattern is String) {
          final s = rule.pattern as String;
          int idx = 0;
          while (true) {
            idx = text.indexOf(s, idx);
            if (idx < 0) break;
            out.add(_ResolvedHit(
              start: idx,
              end: idx + s.length,
              style: rule.style,
              onTap: rule.onTap,
              cursor: rule.cursor,
            ));
            idx += s.length;
          }
        }
      }
    }

    if (ranges != null) {
      for (final r in ranges) {
        if (!r.range.isValid) continue;
        out.add(_ResolvedHit(
          start: r.range.start,
          end: r.range.end,
          style: r.style,
          onTap: r.onTap,
        ));
      }
    }

    out.sort((a, b) {
      final c = a.start.compareTo(b.start);
      if (c != 0) return c;
      return (b.end - b.start).compareTo(a.end - a.start);
    });

    final List<_ResolvedHit> merged = [];
    int lastEnd = -1;
    for (final h in out) {
      if (h.start >= lastEnd) {
        merged.add(h);
        lastEnd = h.end;
      }
    }

    return merged;
  }

  List<InlineSpan> _buildSpans(
      String text,
      TextStyle base,
      List<_ResolvedHit> hits,
      TextStyle defaultLinkStyle,
      ) {
    final List<InlineSpan> spans = [];
    int cursor = 0;

    for (final h in hits) {
      if (cursor < h.start) {
        spans.add(TextSpan(text: text.substring(cursor, h.start)));
      }

      final piece = text.substring(h.start, h.end);
      if (h.onTap != null) {
        final recognizer = TapGestureRecognizer()..onTap = () => h.onTap!(piece);
        _recognizers.add(recognizer);
        final TextStyle? resolvedStyle = (h.style?.color == null)
            ? defaultLinkStyle.merge(h.style)
            : h.style;
        spans.add(
          TextSpan(
            text: piece,
            style: resolvedStyle,
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: piece, style: h.style));
      }

      cursor = h.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }
}
