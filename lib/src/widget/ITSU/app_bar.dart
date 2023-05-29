// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum ProZAppBarType {
  large,
  medium,
  small,
  normal,
}

PreferredSizeWidget ProZAppBar<T>({
  ProZAppBarType type = ProZAppBarType.normal,
  String title = '',
  subtitle = '',
  Widget? child,
  bool showBackButton = false,
  List<Widget>? trailingIcon,
  bool titleCenter = true,
  T? result,
}) {
  final TextStyle appbarTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: type == ProZAppBarType.normal ? FontWeight.w400 : FontWeight.bold,
    fontSize: type == ProZAppBarType.normal ? 20.sp : 30.sp,
  );
  // final TextStyle subtitleTextStyle = TextStyle(
  //   color: Colors.white,
  //   fontWeight: type == ProZAppBarType.Normal ? FontWeight.w400 : FontWeight.normal,
  //   fontSize: type == ProZAppBarType.Normal ? 20.sp : 15.sp,
  // );
  // large app bar
  PreferredSizeWidget large() => PreferredSize(
        preferredSize: Size.fromHeight(0.26.sh),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              trailingIcon != null
                  ? Row(
                      children: [
                        const Spacer(),
                        ...trailingIcon,
                        SizedBox(width: 20.w),
                      ],
                    )
                  : Container(),
              title.isNotEmpty
                  ? Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 38.sp,
                      ),
                    )
                  : Container(),
              title.isNotEmpty
                  ? Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 13.sp,
                      ),
                    )
                  : Container(),
              child ?? Container(),
            ],
          ),
        ),
      );
  // medium app bar
  PreferredSizeWidget medium() => AppBar(
        toolbarHeight: 0.16.sh,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: SafeArea(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  title.isNotEmpty
                      ? Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 38.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(),
                  child ?? Container(),
                ],
              ),
              if (trailingIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [...trailingIcon],
                ),
            ],
          ),
        ),
      );
  PreferredSizeWidget small() => PreferredSize(
        preferredSize: Size.fromHeight(0.08.sh),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: showBackButton
              ? IconButton(
                  onPressed: () => Get.back<T>(result: result),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                )
              : null,
          backgroundColor: Colors.transparent,
          title: title.isNotEmpty
              ? Text(
                  title,
                  style: appbarTextStyle,
                )
              : child,
          centerTitle: titleCenter,
          actions: trailingIcon,
        ),
      );
  // normal app bar
  PreferredSizeWidget normal() => AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                onPressed: () => Get.back<T>(result: result),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 25.sp,
                ),
              )
            : null,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: appbarTextStyle,
        ),
        actions: trailingIcon,
      );
  // differentiate type
  switch (type) {
    case ProZAppBarType.large:
      return large();
    case ProZAppBarType.medium:
      return medium();
    case ProZAppBarType.small:
      return small();
    case ProZAppBarType.normal:
      return normal();
  }
}
