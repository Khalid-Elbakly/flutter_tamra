import 'package:flutter/material.dart';

class CustomGradientDivider extends StatelessWidget {
  const CustomGradientDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: 1.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Color(0XFF707070).withOpacity(0.5),
              Colors.white.withOpacity(0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
