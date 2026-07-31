import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProZDropDownButtonField<T> extends StatefulWidget {
  const ProZDropDownButtonField({
    Key? key,
    required this.label,
    this.hintText = 'Choose an option',
    this.onChanged,
    required this.items,
    this.value,
    this.labelTextColor = const Color(0xff7f7f7f),
  }) : super(key: key);
  final String label;
  final String hintText;
  final void Function(T?)? onChanged;
  final List<DropdownMenuItem<T>>? items;
  final Color labelTextColor;
  final T? value;

  @override
  State<ProZDropDownButtonField<T>> createState() => _ProZDropDownButtonFieldState<T>();
}

class _ProZDropDownButtonFieldState<T> extends State<ProZDropDownButtonField<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.5.sp,
              color: widget.labelTextColor,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        DropdownButtonFormField<T>(
          initialValue: widget.value,
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          items: widget.items,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.black),
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
