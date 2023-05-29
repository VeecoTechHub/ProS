import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final Function(int) onChanged;
  final Color selectedColor;

  const RatingWidget({
    super.key,
    required this.onChanged,
    this.selectedColor = Colors.blue,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _currentRating = 1;

  Widget _buildStar(int index) {
    IconData iconData;
    Color iconColor;
    if (_currentRating >= index) {
      iconData = Icons.star;
      iconColor = widget.selectedColor;
    } else {
      iconData = Icons.star_border;
      iconColor = Colors.grey;
    }
    return IconButton(
      icon: Icon(iconData),
      color: iconColor,
      onPressed: () {
        setState(() {
          _currentRating = index;
          widget.onChanged(_currentRating);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) => _buildStar(index + 1)),
      );
}
