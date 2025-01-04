import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';

class DownloadingCard extends StatefulWidget {

  final List<String> downloadDetails;
  final VoidCallback queueCall;
  final VoidCallback stopCall;
  final VoidCallback deleteDialogCall;
  final VoidCallback openFileCall;

  const DownloadingCard({
    super.key,
    required this.downloadDetails,
    required this.queueCall,
    required this.stopCall,
    required this.deleteDialogCall,
    required this.openFileCall
  });

  @override
  State<DownloadingCard> createState() => _DownloadingCardState();
}

class _DownloadingCardState extends State<DownloadingCard> {

  var formatClass = TimeSizeFormat();

  bool checkInt(String value) {
    if (int.tryParse(value) != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(child: 
      Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  widget.downloadDetails[1],
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: formatClass.textAlign(widget.downloadDetails[1]),
                )
              ),
            ],),
            
            const SizedBox(height: 5,),

            Row(children: [
              IconButton(
                onPressed: () {

                  if (widget.downloadDetails[4] == 'stopped' || widget.downloadDetails[4] == 'scheduled') {
                    widget.queueCall();
                  } else if (widget.downloadDetails[4] == 'downloading' || widget.downloadDetails[4] == 'queue') {
                    widget.stopCall();
                  }
                  
                }, 
                icon: 
                  Icon(
                    widget.downloadDetails[4] == 'stopped' || widget.downloadDetails[4] == 'scheduled' ? Icons.play_arrow : Icons.pause),
                    color: Theme.of(context).colorScheme.primary,
              ),
                  
              IconButton(onPressed: () {
                widget.deleteDialogCall();
              }, icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error)),

              IconButton(onPressed: () {
                widget.openFileCall();
              }, icon: Icon(Icons.remove_red_eye_rounded, color: Theme.of(context).colorScheme.primary))
            ],),

            const SizedBox(height: 5),

            Row(children: [
              Text(checkInt(widget.downloadDetails[6]) 
                    ?'${formatClass.sizeFormat(int.parse(widget.downloadDetails[6]))}/${TimeSizeFormat().sizeFormat(int.parse(widget.downloadDetails[5]))}'
                    :'0'),

              const Spacer(),

              Text((widget.downloadDetails[7] != '0') 
                    ?formatClass.sizeFormat((int.parse(widget.downloadDetails[5]))~/int.parse(widget.downloadDetails[7]), 1) + '/ثانیه'
                    :'0'),

              const Spacer(),

              Text((widget.downloadDetails[7] != '0') 
                    ?formatClass.timeFormat(((int.parse(widget.downloadDetails[6])-int.parse(widget.downloadDetails[5]))/(int.parse(widget.downloadDetails[5])/int.parse(widget.downloadDetails[7]))).toInt())
                    :'0'),
              
            ],),

            const SizedBox(height: 5,),

            Expanded(
              child: LinearProgressIndicator(
                value: checkInt(widget.downloadDetails[6])
                  ?(int.parse(widget.downloadDetails[5])/int.parse(widget.downloadDetails[6]))
                  :0,
                minHeight: 5,
              ),
            ),
          
            const SizedBox(height: 5)
            
          ],
        ),
      )
    );
  }
}