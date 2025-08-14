import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

/// CLDescription
///
/// A small descriptive text widget used below inputs or at the bottom of
/// list sections.
class CLDescription extends StatelessWidget {
  const CLDescription(
    this.text, {
    super.key,
    this.title,
    this.rules,
    this.ranges,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.leading,
    this.leadingIcon,
    this.leadingColorToken,
    this.leadingSize,
    this.padding,
  }) : assert(leading == null || leadingIcon == null,
  'Provide either `leading` or `leadingIcon`, not both.');

  /// Plain text content
  final String text;

  /// Optional title displayed above the description.
  final String? title;

  /// Highlight rules for partial clickable/highlighted spans
  final List<CLHighlightRule>? rules;

  /// Explicit ranges for highlighting
  final List<CLHighlightRange>? ranges;

  /// Text alignment (default: start)
  final TextAlign textAlign;

  /// Max lines (default: null)
  final int? maxLines;

  /// Overflow behavior (default: null)
  final TextOverflow? overflow;

  /// Optional leading widget
  final Widget? leading;

  /// Optional leading icon (used when [leading] is null)
  final IconData? leadingIcon;

  /// Color for [leadingIcon] (defaults to onSurfaceVariant)
  final ColorToken? leadingColorToken;

  /// Size for [leadingIcon] (defaults to 16.px)
  final double? leadingSize;

  /// Optional outer padding. If null, no additional padding is applied.
  final EdgeInsetsGeometry? padding;

  /// Factory preset for input helper text below an input field.
  factory CLDescription.forInput(
    String text, {
    Key? key,
    List<CLHighlightRule>? rules,
    List<CLHighlightRange>? ranges,
    int? maxLines,
    TextOverflow? overflow,
    Widget? leading,
    IconData? leadingIcon,
    ColorToken? leadingColorToken,
    double? leadingSize,
    String? title,
  }) {
    return CLDescription(
      text,
      key: key,
      rules: rules,
      ranges: ranges,
      maxLines: maxLines,
      overflow: overflow,
      leading: leading,
      leadingIcon: leadingIcon,
      leadingColorToken: leadingColorToken,
      leadingSize: leadingSize,
      padding: EdgeInsets.only(top: 8.px),
      title: title,
    );
  }

  /// Factory preset for section footers in list sections.
  factory CLDescription.forSectionFooter(
    String text, {
    Key? key,
    List<CLHighlightRule>? rules,
    List<CLHighlightRange>? ranges,
    int? maxLines,
    TextOverflow? overflow,
    Widget? leading,
    IconData? leadingIcon,
    ColorToken? leadingColorToken,
    double? leadingSize,
    String? title,
  }) {
    final EdgeInsetsGeometry? padding = PlatformStyle.isUseMaterial
        ? EdgeInsetsDirectional.only(start: 20.px, bottom: 16.px)
        : null;

    return CLDescription(
      text,
      key: key,
      rules: rules,
      ranges: ranges,
      maxLines: maxLines,
      overflow: overflow,
      leading: leading,
      leadingIcon: leadingIcon,
      leadingColorToken: leadingColorToken,
      leadingSize: leadingSize,
      padding: padding,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final Widget? titleWidget = (PlatformStyle.isUseMaterial && title != null && title!.isNotEmpty)
        ? CLText.bodySmall(
            title!,
            colorToken: ColorToken.onSurface,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        : null;

    final Widget richText = CLText.bodySmall(
      text,
      colorToken: ColorToken.onSurfaceVariant,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    ).highlighted(
      rules: rules,
      ranges: ranges,
    );

    Widget content;
    final Widget? effectiveLeading = leading ??
        (leadingIcon != null
            ? CLIcon(
                icon: leadingIcon!,
                size: (leadingSize ?? 16.px),
                color: (leadingColorToken ?? ColorToken.onSurfaceVariant)
                    .of(context),
              )
            : null);

    if (effectiveLeading != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          effectiveLeading,
          SizedBox(width: 8.px),
          Expanded(child: richText),
        ],
      );
    } else {
      content = richText;
    }

    Widget result;
    if (titleWidget != null) {
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          SizedBox(height: 4.px),
          content,
        ],
      );
    } else {
      result = content;
    }

    if (padding != null) {
      return Padding(padding: padding!, child: result);
    }
    return result;
  }
}


