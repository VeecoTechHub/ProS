import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProZIconButton<T> extends StatefulWidget {
  const ProZIconButton({
    Key? key,
    this.icon = Icons.more_vert,
    this.iconColor, // = const Color(0xffd3af37),
    this.iconSize = 24,
    this.padding = EdgeInsets.zero,
    this.onPressed,
    this.items,
    this.showExclamation = false,
    this.onChanged,
    this.badgeValue = 0,
    this.showBadge = false,
    this.badgeColor = const Color(0xffd3af37),
    this.badgeTextColor = Colors.white,
  }) : super(key: key);

  /// Icon
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsets padding;
  final Function()? onPressed;

  /// Drop down list
  final List<PopupMenuEntry<T>>? items;
  final Function(T)? onChanged;

  /// Badge
  final int badgeValue;
  final bool showBadge;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool showExclamation;

  @override
  State<ProZIconButton<T>> createState() => _ProZIconButtonState<T>();
}

class _ProZIconButtonState<T> extends State<ProZIconButton<T>> {
  Color iconColor = Colors.white;

  @override
  void initState() {
    if (widget.iconColor != null) {
      iconColor = widget.iconColor!;
    } else {
      if (widget.showBadge) {
        iconColor = Colors.white;
      } else {
        iconColor = const Color(0xffd3af37);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (detail) async {
            if (widget.items != null && widget.onChanged != null) {
              await showMenu<T>(
                context: context,
                position: RelativeRect.fromLTRB(
                  detail.globalPosition.dx,
                  detail.globalPosition.dy,
                  0.0,
                  0.0,
                ),
                items: widget.items!,
              ).then((value) {
                if (value != null) {
                  setState(() {
                    widget.onChanged!(value);
                  });
                }
              });
            }
          },
          child: Padding(
            padding: (widget.padding == EdgeInsets.zero && widget.showBadge) ? EdgeInsets.all(13.h) : widget.padding,
            child: Icon(
              widget.icon,
              color: iconColor,
            ),
          ),
        ),
        if ((widget.badgeValue != 0 || widget.showExclamation != false) && widget.showBadge)
          Positioned(
            top: 5.h,
            right: 5.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              alignment: Alignment.center,
              height: 20.h,
              width: 20.h,
              decoration: BoxDecoration(
                color: widget.badgeColor,
                shape: BoxShape.circle, // Make it circular
              ),
              child: Text(
                widget.showExclamation ? "!":widget.showBadge ? widget.badgeValue.toString() : "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.badgeTextColor,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}