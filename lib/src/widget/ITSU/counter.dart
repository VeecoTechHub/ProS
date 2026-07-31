import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProZCounter extends StatefulWidget {
  const ProZCounter({
    Key? key,
    required this.onChanged,
    this.vertical = false,
    this.margin,
    this.initialValue,
    this.borderColor = const Color(0xff7f7f7f),
    this.buttonColor = const Color(0xffd3af37),
  }) : super(key: key);
  final Function(int) onChanged;
  final int? initialValue;
  final EdgeInsetsGeometry? margin;
  final bool vertical;
  final Color borderColor, buttonColor;

  @override
  State<ProZCounter> createState() => _ProZCounterState();
}

class _ProZCounterState extends State<ProZCounter> {
  int counter = 1;

  @override
  void initState() {
    if (widget.initialValue != null) {
      counter = widget.initialValue ?? 1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vertical) {
      return Container(
        margin: widget.margin,
        height: 150.h,
        width: 45.w,
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  color: widget.buttonColor.withValues(alpha: 0.5),
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        if (counter != 1) {
                          counter--;
                          widget.onChanged(counter);
                        }
                      });
                    },
                    icon: Icon(Icons.remove, size: 15.sp),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: widget.borderColor),
                    ),
                  ),
                  child: Text(counter.toString()),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  color: widget.buttonColor.withValues(alpha: 0.5),
                  alignment: Alignment.center,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        counter++;
                        widget.onChanged(counter);
                      });
                    },
                    icon: Icon(Icons.add, size: 15.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 45.h,
      width: 150.w,
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              color: widget.borderColor.withValues(alpha: 0.2),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    if (counter != 1) {
                      counter--;
                      widget.onChanged(counter);
                    }
                  });
                },
                icon: Icon(Icons.remove, size: 15.sp),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: widget.borderColor),
                ),
              ),
              child: Text(counter.toString()),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              color: widget.borderColor.withValues(alpha: 0.2),
              alignment: Alignment.center,
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    counter++;
                    widget.onChanged(counter);
                  });
                },
                icon: Icon(Icons.add, size: 15.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
