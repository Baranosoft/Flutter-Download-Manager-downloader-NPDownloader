import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {


  static const platform = MethodChannel('app.channel/intent');


  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(
        title: const Text('درباره'),
      ),
      body: Column(
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
    ));
  }
}