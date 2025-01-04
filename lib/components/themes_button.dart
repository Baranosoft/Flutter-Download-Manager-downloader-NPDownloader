import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/theme/theme_data.dart';
import 'package:noarman_professional_downloader/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemesButton extends StatelessWidget {
  final int index;

  const ThemesButton({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = appThemes[index];

    return GestureDetector(
      onTap: () {
        themeProvider.setTheme(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? theme.darkPrimary : theme.lightPrimary,
          shape: BoxShape.circle,
          border: Border.all(
            color: themeProvider.currentTheme == appThemes[index]
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
