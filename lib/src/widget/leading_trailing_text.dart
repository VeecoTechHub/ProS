import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../pro_z.dart';

class ProZRow extends StatefulWidget {
  final String? leadingText;
  final String? trailingText;
  final Widget? leading;
  final Widget? trailing;
  final Color? leadingTextColor;
  final FontWeight? leadingFontWeight;
  final double? leadingFontSize;
  final Color? trailingTextColor;
  final FontWeight? trailingFontWeight;
  final double? trailingFontSize;
  final Color? allColor;
  final FontWeight? allFontWeight;
  final double? allFontSize;
  final dynamic leadingMediaSource;
  final dynamic trailingMediaSource;
  final BoxFit? leadingFit;
  final BoxFit? trailingFit;
  final EdgeInsetsGeometry? leadingMediaPadding, trailingMediaPadding, leadingMediaMargin, trailingMediaMargin;
  final double? leadingMediaHeight, trailingMediaHeight, leadingMediaWidth, trailingMediaWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool defaultVisualDensity;
  final double? leadingWidth, trailingWidth;
  final EdgeInsets? contentPadding;
  final double? minimalVerticalPadding;
  final VisualDensity? visualDensity;

  const ProZRow(
      {Key? key,
      this.leadingText,
      this.trailingText,
      this.leading,
      this.trailing,
      this.leadingTextColor,
      this.trailingTextColor,
      this.leadingFontWeight,
      this.trailingFontWeight,
      this.leadingFontSize,
      this.trailingFontSize,
      this.allFontWeight = FontWeight.w400,
      this.allColor = Colors.black,
      this.allFontSize = 12,
      this.leadingMediaSource,
      this.trailingMediaSource,
      this.leadingFit = BoxFit.fill,
      this.trailingFit = BoxFit.fill,
      this.leadingMediaPadding,
      this.trailingMediaPadding,
      this.leadingMediaMargin,
      this.trailingMediaMargin,
      this.leadingMediaHeight,
      this.trailingMediaHeight,
      this.leadingMediaWidth,
      this.trailingMediaWidth,
      this.leadingIcon,
      this.trailingIcon,
      this.defaultVisualDensity = false,
      this.leadingWidth,
      this.trailingWidth,
      this.contentPadding,
      this.minimalVerticalPadding,
      this.visualDensity})
      : super(key: key);

  @override
  ProZRowState createState() => ProZRowState();
}

class ProZRowState extends State<ProZRow> {
  Widget buildLeading() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: widget.leading ??
          SizedBox(
            width: widget.leadingWidth ?? 0.5.sw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                if (widget.leadingMediaSource != null) ...[
                  ProZMultiMedia(
                    source: widget.leadingMediaSource,
                    width: widget.leadingMediaWidth ?? 20,
                    height: widget.leadingMediaHeight ?? 20,
                    margin: widget.leadingMediaMargin,
                    padding: widget.leadingMediaPadding,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                Expanded(
                  child: Text(
                    widget.leadingText ?? "",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.leadingTextColor ?? widget.allColor,
                      fontWeight: widget.leadingFontWeight ?? widget.allFontWeight,
                      fontSize: widget.leadingFontSize ?? widget.allFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget buildTrailing() {
    return widget.trailing ??
        SizedBox(
          width: widget.trailingWidth ?? 0.5.sw,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.trailingIcon != null) ...[
                Icon(widget.trailingIcon),
                const SizedBox(
                  width: 10,
                ),
              ],
              if (widget.trailingMediaSource != null) ...[
                ProZMultiMedia(
                  source: widget.trailingMediaSource,
                  width: widget.trailingMediaWidth ?? 20,
                  height: widget.trailingMediaHeight ?? 20,
                  margin: widget.trailingMediaMargin,
                  padding: widget.trailingMediaPadding,
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
              Expanded(
                child: Text(
                  widget.trailingText ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.trailingTextColor ?? widget.allColor,
                    fontWeight: widget.trailingFontWeight ?? widget.allFontWeight,
                    fontSize: widget.trailingFontSize ?? widget.allFontSize,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: widget.defaultVisualDensity ? false : true,
      minVerticalPadding: widget.minimalVerticalPadding ?? -4,
      contentPadding: widget.contentPadding ?? EdgeInsets.zero,
      visualDensity: widget.visualDensity ?? (widget.defaultVisualDensity ? VisualDensity.adaptivePlatformDensity : const VisualDensity(horizontal: -4, vertical: -4)),
      leading: buildLeading(),
      trailing: buildTrailing(),
      key: widget.key,
    );
  }
}
