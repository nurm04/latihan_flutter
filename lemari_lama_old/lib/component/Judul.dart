import 'package:flutter/material.dart';

class Judul extends StatelessWidget {
  final String title;
  const Judul({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Color(0xFF544C2A)
          ),
        ),
      ],
    );
  }
}