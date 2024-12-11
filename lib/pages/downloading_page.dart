import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/utils/delete_file.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';


class DownloadingPage extends StatefulWidget {

  final Function() onCallback;
  const DownloadingPage({super.key, required this.onCallback});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> {

  SharedPreferencesAsync data = SharedPreferencesAsync();
  List<List<String>> downloadList = [];
  List<List<String>> items = [];
  Timer? _timer;
  Set<String> keys = {};
  Set<String> downloadListKeys = {};

  bool isButtonActive = true;

  var formatClass = TimeSizeFormat();

  var deleteClass = DeleteFile();

  final Widget emptySVG = SvgPicture.asset(
    'assets/empty_downloading',
    semanticsLabel: 'Empty Downloading',
  );

  @override
  void initState() {
    super.initState();
    loadData();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateData());

  }


  Future<void> loadData() async {

    data = await getData();

    await processEachKey();

    setState(() {
      items = downloadList;
    });

  }



  Future<void> updateData() async {
    await downloadListUpdate();

    if (mounted) {
      setState(() {
        items = downloadList;
        print(items);
      });
    }
  }


  Future<SharedPreferencesAsync> getData() async {
    return SharedPreferencesAsync();
  }


  Future<void> processEachKey() async {

    print(data.toString());

    keys = await data.getKeys();

    downloadList.clear();

    if (keys.isNotEmpty) {
      for (String key in keys) {
        List<String>? value = await data.getStringList(key);

        if (value != null && value.length > 4) {
          print(value);
          if (value[4] == 'queue' || value[4] == 'downloading' || value[4] == 'stopped' || value[4] == 'scheduled') {
            downloadList.add(value);
            downloadListKeys.add(key);
          }
        }
      }
    }
  }


  Future<void> downloadListUpdate() async {

    downloadList.clear();

    for (String key in downloadListKeys) {
      List<String>? value = await data.getStringList(key);

      if (value != null && value.length > 4) {
        if (value[4] == 'queue' || value[4] == 'downloading' || value[4] == 'stopped' || value[4] == 'scheduled') {
          downloadList.add(value);
        }
      }
    }

  }


  Future<void> setSituation(int index, String situation) async {

    List<String> down = downloadList[index];
    String theKey = down[2] + down[1];
    await data.setStringList(theKey, [down[0], down[1], down[2], down[3], situation, down[5], down[6], down[7]]);
    
    widget.onCallback();
  }



  Future<void> deleteDownload(int index, bool fileDelete) async {

    deleteClass.deleteDownload(downloadList[index][1], downloadList[index][2], fileDelete);

    List<String> down = downloadList[index];
    String theKey = down[2] + down[1];
    data.remove(theKey);
    
    widget.onCallback();
  }


  bool checkInt(String value) {
    if (int.tryParse(value) != null) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> deleteDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
          title: const Text('حذف فایل'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
              const Text('فایل مورد نظر حذف شود؟'),
              const SizedBox(height: 8),
              Text(downloadList[index][1])
              ]
            ),
          ),
          actions: <Widget>[
            Align(alignment: Alignment.centerRight, child: TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red[800])),
              onPressed: () {
                deleteDownload(index, false);
                Navigator.of(context).pop();
              },
            ),),
            
            Align(alignment: Alignment.centerRight, child: TextButton(
              child: Text('حذف به همراه فایل', style: TextStyle(color: Colors.red[800])),
              onPressed: () {
                deleteDownload(index, true);
                Navigator.of(context).pop();
              },
            ),),

            Align(alignment: Alignment.centerRight, child: TextButton(
              child: const Text('بستن'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ))
          ],
        ));
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    items = [];
    downloadList = [];
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.length == 0

        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: SvgPicture.asset(
                    'assets/svg/empty_downloading.svg',
                  ),
                ),
                
                const SizedBox(height: 5),

                const Text('فایلی در حال دانلود نیست')
              ]
            )
        )
        
        : SafeArea(child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
        
            return Card(child: 
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(items[index][1], style: const TextStyle(fontSize: 18), textAlign: formatClass.textAlign(items[index][1]),)) ,
                    ],),
                    
                    const SizedBox(height: 5,),

                    Row(children: [
                      IconButton(onPressed: () {

                        if (isButtonActive) {
                          if (items[index][4] == 'stopped' || items[index][4] == 'scheduled') {
                            setSituation(index, 'queue');
                          } else if (items[index][4] == 'downloading' || items[index][4] == 'queue') {
                            setSituation(index, 'stopped');
                          }

                          setState(() {
                            isButtonActive = false;
                          });

                          Timer(const Duration(seconds: 1), () {
                            setState(() {
                              isButtonActive = true;
                            });
                          });
                        }
                        
                      }, icon: Icon(items[index][4] == 'stopped' || items[index][4] == 'scheduled' ? Icons.play_arrow : Icons.pause),),
                      
                      IconButton(onPressed: () {
                        deleteDialog(context, index);
                      }, icon: Icon(Icons.delete, color: Colors.red[900],)),
                    ],),

                    const SizedBox(height: 5),

                    Row(children: [
                      Text(checkInt(items[index][6]) 
                            ?'${formatClass.sizeFormat(int.parse(items[index][6]))}/${TimeSizeFormat().sizeFormat(int.parse(items[index][5]))}'
                            :'0'),

                      const Spacer(),

                      Text((items[index][7] != '0') 
                            ?formatClass.sizeFormat((int.parse(items[index][5]))~/int.parse(items[index][7]), 1) + '/ثانیه'
                            :'0'),

                      const Spacer(),

                      Text((items[index][7] != '0') 
                            ?formatClass.timeFormat(((int.parse(items[index][6])-int.parse(items[index][5]))/(int.parse(items[index][5])/int.parse(items[index][7]))).toInt())
                            :'0'),
                      
                    ],),

                    const SizedBox(height: 5,),

                    Expanded(
                      child: LinearProgressIndicator(
                        value: checkInt(items[index][6])
                          ?(int.parse(items[index][5])/int.parse(items[index][6]))
                          :0,
                        minHeight: 5,
                      ),
                    ),
                  
                    const SizedBox(height: 5)
                    
                  ],
                ),
              )
            );
        
          },
        ))
    );
  }
}