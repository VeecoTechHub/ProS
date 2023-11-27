import 'package:flutter/material.dart';

class ProZTabBarView extends StatefulWidget {
  const ProZTabBarView({
    Key? key,
    required this.labels,
    required this.pages,
    this.onTap,
    this.onPageChanged,
    this.textStyle,
    this.isScrollable = false,
    this.labelPadding,
  }) : super(key: key);
  final List<String> labels;
  final TextStyle? textStyle;
  final List<Widget> pages;
  final Function(int)? onTap, onPageChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? labelPadding;

  @override
  State<ProZTabBarView> createState() => ProZTabBarViewState();
}

class ProZTabBarViewState extends State<ProZTabBarView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: widget.labels.length);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      if (widget.onPageChanged != null) widget.onPageChanged!(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void changeTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> myTabs = List.generate(
        widget.labels.length,
        (index) => Tab(
                child: Text(
              widget.labels[index],
              style: widget.textStyle ?? const TextStyle(),
            )));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          isScrollable: widget.isScrollable,
          controller: _tabController,
          tabs: myTabs,
          onTap: widget.onTap,
          labelPadding: widget.labelPadding,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.pages,
          ),
        ),
      ],
    );
  }
}
