
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles/size_config.dart';

class KeyboardKey extends StatefulWidget {
  final dynamic label;
  final dynamic value;
  final ValueSetter<dynamic> onTap;
  final bool isHorizontal;

  const KeyboardKey({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isHorizontal,
  }) : super(key: key);

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey> {
  renderLabel() {
    if (widget.label is Widget) {
      return widget.label;
    }

    return Text(
      widget.label,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.textMultiplier * 5,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHorizontal) {
      return InkWell(
        onTap: () {
          widget.onTap(widget.value);
        },
        child: AspectRatio(
          aspectRatio: widget.isHorizontal ? 1.7 : 2.5,
          child: Center(
            child: renderLabel(),
          ),
        ),
      );
    }
    return InkWell(
      onTap: () {
        widget.onTap(widget.value);
      },
      child: SizedBox(
        height: SizeConfig.heightMultiplier * 8,
        child: Center(
          child: renderLabel(),
        ),
      ),
    );
  }
}
