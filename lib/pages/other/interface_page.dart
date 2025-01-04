import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noarman_professional_downloader/components/themes_button.dart';
import 'package:noarman_professional_downloader/theme/theme_data.dart';
import 'package:noarman_professional_downloader/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class InterfacePage extends StatefulWidget {
  const InterfacePage({super.key});

  @override
  State<InterfacePage> createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  @override
  Widget build(BuildContext context) {


    final themeProvider = Provider.of<ThemeProvider>(context);


    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.surface,
          statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark) ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).colorScheme.surfaceContainer
        ),
        title: const Text('نما')
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('حالت تاریک'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleDarkMode(value);
            },
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(appThemes.length, (index) {
              return ThemesButton(index: index);
            }),
          ),
        ],
      ),
    ));

    
  }
}