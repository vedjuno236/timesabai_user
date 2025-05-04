import 'package:flutter/material.dart';

class TextInputCustomDesignNormal extends StatelessWidget {
  final Widget child;
  const TextInputCustomDesignNormal({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).hoverColor,
      ),
      child: Center(child: child),
    );
  }
}
