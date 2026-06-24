import 'package:flutter/material.dart';
import 'main.dart' show themeNotifier;

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        themeNotifier.value =
            isDark ? ThemeMode.light : ThemeMode.dark;
      },
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111C44) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.white : Colors.black87,
          size: 22,
        ),
      ),
    );
  }
}