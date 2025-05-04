import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final Color bgColor;
  final Color iconColor;
  final Color titleColor; // Ensure this is included
  final IconData icon;
  final bool value;
  final Function(bool) onTap;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.bgColor,
    required this.iconColor,
    required this.titleColor, // Add titleColor
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: GoogleFonts.notoSansLao(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor, // Apply titleColor here
              ),
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onTap,
          ),
        ],
      ),
    );
  }
}
