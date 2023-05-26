import 'package:flutter/material.dart';

class ProZTabBarView extends StatefulWidget {
  const ProZTabBarView({
    Key? key,
    required this.labels,
    required this.pages,
    this.onTap,
    this.onPageChanged,
  }) : super(key: key);
  final List<String> labels;
  final List<Widget> pages;
  final Function(int)? onTap, onPageChanged;

  @override
  State<ProZTabBarView> createState() => _ProZTabBarViewState();
}

class _ProZTabBarViewState extends State<ProZTabBarView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> myTabs = List.generate(widget.labels.length, (index) => Tab(text: widget.labels[index]));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          tabs: myTabs,
          onTap: widget.onTap,
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