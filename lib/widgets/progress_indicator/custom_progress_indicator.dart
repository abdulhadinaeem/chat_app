import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.white),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.purple,
          backgroundColor: Colors.purpleAccent.shade200,
        ),
      ),
    );
  }
}
