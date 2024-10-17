import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String imagePath;
  final bool revealed;
  final VoidCallback onTap;

  CardWidget({
    required this.imagePath,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: revealed
            ? Image.asset('assets/$imagePath')
            : Container(
                color: Colors.grey,
                child: Icon(Icons.help_outline, color: Colors.white),
              ),
      ),
    );
  }
}
