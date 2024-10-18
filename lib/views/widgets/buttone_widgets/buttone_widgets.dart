import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewTypeButton extends StatelessWidget {
  const ViewTypeButton({Key? key, required this.title, required this.isActive})
      : super(key: key);
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.grey,
        ),
        child: Text(title),
      ),
    );
  }
}
