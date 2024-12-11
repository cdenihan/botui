import 'package:flutter/material.dart';

AppBar createTopBar(String title) {
  return AppBar(
    backgroundColor: Colors.grey[900],
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    toolbarHeight: 80,
  );
}