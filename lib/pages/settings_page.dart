import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/components/settings_button.dart';
import 'package:noarman_professional_downloader/pages/other/about_page.dart';
import 'package:noarman_professional_downloader/pages/other/interface_page.dart';
import 'package:noarman_professional_downloader/utils/animated_page_route.dart';

class SettingsPage extends StatefulWidget {
  
  final Function() onCallback;
  const SettingsPage({super.key, required this.onCallback});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SettingsButton(
                title: 'نما',
                subTitle: 'قالب کاربری، رنگ‌ها', 
                icon: Icons.palette, 
                onCallback: () {
                  Navigator.of(context).push(
                    AnimatedPageRoute.fadeThrough(const InterfacePage()),
                  );
              }),
              SettingsButton(
                title: 'درباره',
                subTitle: 'ارتباط با ما، ارسال نظر، دیگر برنامه‌ها', 
                icon: Icons.person, 
                onCallback: () {
                  Navigator.of(context).push(
                    AnimatedPageRoute.fadeThrough(const AboutPage()),
                  );
              }),
            ],
          ),
        )
      )
    );
  }
}