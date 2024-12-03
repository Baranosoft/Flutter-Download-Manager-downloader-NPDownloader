import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/utils/delete_file.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:open_file/open_file.dart';

class Downloadedpage extends StatefulWidget {

  final Function() onCallback;
  const Downloadedpage({super.key, required this.onCallback});

  @override
  _DownloadedpageState createState() => _DownloadedpageState();
}

class _DownloadedpageState extends State<Downloadedpage> {

  SharedPreferencesAsync data = SharedPreferencesAsync();
  List<List<String>> downloadList = [];

  List<List<String>> items = [];

  var formatClass = TimeSizeFormat();

  var deleteClass = DeleteFile();



  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _loadData() async {

    data = await getData();

    await processEachKey();
    
    setState(() {
      items = downloadList;
      print(items);
    });
  }


  //ذدریافت دیتا از شیردپرفرنس
  Future<SharedPreferencesAsync> getData() async {
    return SharedPreferencesAsync();
  }


  // در این بخش دینا دریافت شده و بخش های مورد نظر در دانلود لیست ذخیره می‌شوند
  Future<void> processEachKey() async {

    Set<String> keys = await data.getKeys();

    downloadList.clear();
    
    for (String key in keys) {

      List<String>? list = await data.getStringList(key);

      if (list != null) {
        if (list[4] == 'completed' || list[4] == 'failed') {
          downloadList.add(list);
        }
      } else {
        print('No data found for key: $key');
      }
    }
  }


  //کد مربوط به باز کردن فایل‌های دانلود شده
  void openFile(int index) async {
    try {
      await OpenFile.open('${downloadList[index][2]}/${downloadList[index][1]}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('مشکل در باز کردن فایل: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
  }

  Future<void> setSituation(int index, String situation) async {

    print('set Situation is Tuninggggggg');
    List<String> down = downloadList[index];
    String theKey = down[2] + down[1];
    data.remove(theKey);
    await data.setStringList(theKey, [down[0], down[1], down[2], down[3], situation, down[5], down[6], down[7]]);

    _loadData();

    widget.onCallback();
  }


  Future<void> deleteDownload(int index, bool fileDelete) async {

    deleteClass.deleteDownload(downloadList[index][1], downloadList[index][2], fileDelete);

    List<String> down = downloadList[index];
    String theKey = down[2] + down[1];
    data.remove(theKey);

    _loadData();
    
  }


  String translateSituation(String situation) {
    if (situation == 'failed') {
      return 'شکست';
    } else if (situation == 'completed') {
      return 'موفق';
    } else {
      return 'نامعلوم';
    }
  }
  

  Future<void> detailsDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
          title: const Text('جزئیات'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                
              const Text('نام فایل:', style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 6),
              Text(downloadList[index][1], textAlign: formatClass.textAlign(downloadList[index][1]),),

              const SizedBox(height: 10),
              
              const Text('محل ذخیره:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(downloadList[index][2], textAlign: TextAlign.left,),
              
              const SizedBox(height: 10),

              const Text('پیوند:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(downloadList[index][0], textAlign: TextAlign.left,),
              
              const SizedBox(height: 10),

              const Text('وضعیت:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(translateSituation(downloadList[index][4])),
              
              const SizedBox(height: 10),

              const Text('اندازه:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(formatClass.sizeFormat(int.parse(downloadList[index][6]))),
              
              const SizedBox(height: 10),

              const Text('اندازه بارگیری شده:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(formatClass.sizeFormat(int.parse(downloadList[index][5]))),
              
              const SizedBox(height: 10),
              ]
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('بستن'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
      },
    );
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
              Text(downloadList[index][6])
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0, left: 5, right: 5, top: 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            openFile(index);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(  // ستون را پر می‌کند تا محتوای داخل آن به راست بچسبد
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        items[index][1],
                                        textAlign: formatClass.textAlign(items[index][1][0]),
                                        style: const TextStyle(fontSize: 15, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        maxLines: 2,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,  // آیکون‌ها را به راست تراز می‌کند
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                detailsDialog(context, index);
                                              },
                                              icon: const Icon(Icons.more_vert),
                                            ),
                                            
                                            IconButton(
                                              onPressed: () {
                                                deleteDialog(context, index);
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                            if (items[index][4] == 'failed')
                                              IconButton(
                                                onPressed: () {
                                                  setSituation(index, 'queue');
                                                },
                                                icon: const Icon(Icons.refresh),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
