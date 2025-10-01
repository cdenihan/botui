import 'package:flutter/material.dart';

class OverlayTextWidget extends StatelessWidget {
  final String msg;
  const OverlayTextWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
