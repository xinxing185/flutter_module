import 'package:flutter/material.dart';

class CustomImageSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeImage;
  final String inactiveImage;

  const CustomImageSwitch({
    required this.value,
    required this.onChanged,
    required this.activeImage,
    required this.inactiveImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? Colors.blue : Color(0xFFDCDFE4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipOval(
              child: Image.asset(
                value ? activeImage : inactiveImage,
                width: 26,
                height: 26,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
