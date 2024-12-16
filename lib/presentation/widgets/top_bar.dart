import 'package:flutter/material.dart';

AppBar createTopBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.grey[900],
    automaticallyImplyLeading: false,
    title: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    toolbarHeight: 80,
  );
}
