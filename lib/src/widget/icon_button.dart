import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
class ProZIconButton<T> extends StatefulWidget {
  const ProZIconButton({
    Key? key,
    this.icon = Icons.more_vert,
    this.onPressed,
    this.badgePosition,
    this.badgeStyle,
    this.badgeContent = "",
    this.badgeAnimation,
    this.showBadge = false,
    this.items,
    this.onChanged,
  }) : super(key: key);

  /// Icon
  final IconData icon;
  final Function()? onPressed;

  /// Drop down list
  final List<PopupMenuEntry<T>>? items;
  final Function(T)? onChanged;

  /// Badge
  final String badgeContent;
  final badges.BadgePosition? badgePosition;
  final badges.BadgeStyle? badgeStyle;
  final bool showBadge;
  final badges.BadgeAnimation? badgeAnimation;

  @override
  State<ProZIconButton<T>> createState() => _ProZIconButtonState<T>();
}

class _ProZIconButtonState<T> extends State<ProZIconButton<T>> {
  Color iconColor = Colors.white;

  @override
  void initState() {
    if (widget.items != null) {
      iconColor = const Color(0xffd3af37);
    } else {
      iconColor = Colors.white;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: badges.Badge(
          showBadge: widget.showBadge,
          position: widget.badgePosition ?? badges.BadgePosition.topEnd(top: 4, end: 6),
          badgeStyle: widget.badgeStyle ?? const badges.BadgeStyle(),
          badgeAnimation:widget.badgeAnimation ?? const badges.BadgeAnimation.slide(
            animationDuration: Duration(seconds: 1),
            colorChangeAnimationDuration: Duration(seconds: 1),
            loopAnimation: false,
            curve: Curves.bounceInOut,
            colorChangeAnimationCurve: Curves.easeInCubic,
          ),
          onTap: widget.onPressed,
          badgeContent: SizedBox(
            height: 18,
            width: 18,
            child: Center(
              child: Text(
                widget.badgeContent,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          child: IconButton(
            icon:Icon(
              widget.icon,
              color: iconColor,
            ),
            onPressed:widget.onPressed, // Add an icon to the IconButton
          )),
    );
  }
}