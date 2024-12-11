import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  
  final Function() onCallback;
  const SettingsPage({super.key, required this.onCallback});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  static const platform = MethodChannel('app.channel/intent');


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {

                  try {
                    await platform.invokeMethod('openMarket');
                  } on PlatformException catch (e) {
                    print("Failed to open Market: ${e.message}");
                  }

                },
                style: const ButtonStyle(elevation: WidgetStatePropertyAll(0)),
                child: const Column(
                  children: [

                    SizedBox(height: 10),

                    Row(
                      children: [
                    
                        Icon(Icons.star),
                    
                        SizedBox(width: 5),
                    
                        Text('ارسال نظر', style: TextStyle(fontSize: 15))
                      ],
                    ),

                    SizedBox(height: 10)
                  ],
                )
              ),
      
            ],
          ),
        )
      )
    );
  }
}