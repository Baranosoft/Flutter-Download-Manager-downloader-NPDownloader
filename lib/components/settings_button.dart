import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {

  final String title;
  final String subTitle;
  final IconData icon;
  final VoidCallback onCallback; 

  const SettingsButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onCallback,
    required this.subTitle
   });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onCallback,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4
        )),
        backgroundColor: WidgetStatePropertyAll(WidgetStateColor.transparent),
        elevation: WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          ContinuousRectangleBorder()
        )
      ),
      child: Row(
        children: [
          Icon(icon),
          
          const SizedBox(width: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 7),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                )
              ),
              

              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.secondary
                ),
              ),

              const SizedBox(height: 2),

            ],
          )
      
          
        ],
      ),
    );
  }
}