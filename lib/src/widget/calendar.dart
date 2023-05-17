import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pro_z/src/extension/extension_index.dart';

import 'widget_index.dart';

class ProZCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime? firstDay;
  final Function(DateTime) onDateSelected;
  final bool enable;
  final Color labelTextColor, deselectTextColor, selectedColor;

  const ProZCalendar({
    Key? key,
    required this.selectedDate,
    this.firstDay,
    required this.onDateSelected,
    this.enable = true,
    this.labelTextColor = const Color(0xffd3af37),
    this.deselectTextColor = const Color(0xff7f7f7f),
    this.selectedColor = const Color(0xffd3af37),
  }) : super(key: key);

  @override
  State<ProZCalendar> createState() => _ProZCalendarState();
}

class _ProZCalendarState extends State<ProZCalendar> {
  late DateTime selectedDate;
  late DateTime? firstDay;
  int? month;
  int? year;
  final PageController pageController = PageController();
  DateTime displayDate = DateTime.now();

  @override
  void initState() {
    selectedDate = widget.selectedDate;
    displayDate = widget.selectedDate;
    firstDay = widget.firstDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.firstDay != null && widget.enable) {
        setState(() {
          selectedDate = selectedDate.add(Duration(days: widget.firstDay!.difference(selectedDate).inDays));
          displayDate = DateTime.now().add(Duration(days: widget.firstDay!.difference(DateTime.now()).inDays));
          widget.onDateSelected(selectedDate);
        });
      } else {
        widget.onDateSelected(widget.selectedDate);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 70.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  displayDate = DateTime(displayDate.year, displayDate.month - 1, displayDate.day);
                  pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                }),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 15.sp,
                ),
              ),
              Expanded(
                child: Text(
                  "${DateFormat.MMMM().format(DateTime(displayDate.year, displayDate.month, 1))} ${displayDate.year}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  displayDate = DateTime(displayDate.year, displayDate.month + 1, displayDate.day);
                  pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                }),
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 15.sp,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.all(Radius.circular(10.r))),
          child: ProZExpandablePageView(
            pageController: pageController,
            initialPage: displayDate.month,
            onPageChanged: (page) => setState(() {
              displayDate = DateTime(displayDate.year, page, displayDate.day);
            }),
            children: List.generate(
              12,
              (month) => GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 17.h),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _calendarCells(widget.selectedDate.year, month).length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.7),
                  itemBuilder: (BuildContext context, int index) {
                    final item = _calendarCells(widget.selectedDate.year, month)[index];
                    switch (item.type) {
                      case CalendarCellType.label:
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            item.label,
                            style: TextStyle(color: (widget.labelTextColor).darken(0.15), fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        );
                      case CalendarCellType.previous:
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            item.label,
                            style: TextStyle(color: (widget.deselectTextColor), fontSize: 13.sp),
                          ),
                        );
                      case CalendarCellType.current:
                        final isToday = (selectedDate).day.isEqual(item.date!.day) && (selectedDate).month.isEqual(item.date!.month);
                        return GestureDetector(
                          onTap: () {
                            if (item.enable && widget.enable) {
                              setState(() {
                                selectedDate = item.date!;
                                widget.onDateSelected(selectedDate);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('The date was not allow to edit!'),
                              ));
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isToday ? (widget.selectedColor) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: isToday
                                    ? Colors.white
                                    : item.enable || !(widget.enable)
                                        ? null
                                        : (widget.deselectTextColor),
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        );
                      case CalendarCellType.next:
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: (widget.deselectTextColor),
                              fontSize: 13.sp,
                            ),
                          ),
                        );
                    }
                  }),
            ),
          ),
        ),
      ],
    );
  }

  List<CalendarCellData> _calendarCells(int year, int month) {
    List<CalendarCellData> calendarCell = [];

    /// week day label
    List<CalendarCellData> weekDaysLabel = List.generate(7, (index) => CalendarCellData(label: index.toWeekDayFirstChar(), type: CalendarCellType.label));
    calendarCell.addAll(weekDaysLabel);

    /// date cell
    /// previous
    int numberOfPreviousMonth = DateTime(year, month - 1, DateTime(year, month, 0).day).weekday == 7 ? 1 : DateTime(year, month - 1, DateTime(year, month, 0).day).weekday + 1;
    int previousMonthDays = DateTime(year, month, 0).day;
    final List<CalendarCellData> temp = [];
    if (numberOfPreviousMonth != 7) {
      for (int i = 1; i <= numberOfPreviousMonth; i++) {
        final date = DateTime(year, month - 1, previousMonthDays);
        temp.add(CalendarCellData(date: date, label: date.day.toString(), type: CalendarCellType.previous));
        previousMonthDays--;
      }
      calendarCell.addAll(temp.reversed);
    }

    /// current
    int currentMonthDays = DateTime(year, month + 1, 0).day;
    for (int i = 1; i <= currentMonthDays; i++) {
      final date = DateTime(year, month, i);
      calendarCell.add(CalendarCellData(
        date: date,
        label: date.day.toString(),
        type: CalendarCellType.current,
        enable: firstDay == null ? true : date.isAfter(firstDay?.subtract(const Duration(days:1)) ?? DateTime.now()),
      ));
    }

    /// next
    int numberOfDaysNextMonth = (7 - DateTime(year, month + 1, 1).weekday) + (calendarCell.length < 42 ? 7 : 0);
    if (numberOfDaysNextMonth != 7) {
      for (int i = 1; i <= numberOfDaysNextMonth; i++) {
        final date = DateTime(year, month - 1, i);
        calendarCell.add(CalendarCellData(date: date, label: date.day.toString(), type: CalendarCellType.next));
      }
    }
    return calendarCell;
  }
}

enum CalendarCellType {
  label,
  previous,
  current,
  next,
}

class CalendarCellData {
  final DateTime? date;
  final String label;
  final CalendarCellType type;
  final bool enable;

  CalendarCellData({
    this.date,
    required this.label,
    required this.type,
    this.enable = true,
  });

  Map<String, dynamic> toJson() => {
        "date": date.toString(),
        "label": label,
        "type": type.toString(),
        "enable": enable.toString(),
      };
}
