import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/components/downloaded_card.dart';
import 'package:noarman_professional_downloader/utils/delete_file.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:open_file/open_file.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Downloadedpage extends StatefulWidget {

  final Function() onCallback;
  const Downloadedpage({super.key, required this.onCallback});

  @override
  _DownloadedpageState createState() => _DownloadedpageState();
}

class _DownloadedpageState extends State<Downloadedpage> {

  SharedPreferencesAsync data = SharedPreferencesAsync();
  Timer? _timer;

  List<List<String>> downloadList = [];
  Set<String> keys = {};
  Set<String> downloadListKeys = {};
  List<List<String>> items = [];

  var formatClass = TimeSizeFormat();

  var deleteClass = DeleteFile();


  @override
  void initState() {
    super.initState();
    _loadData();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _loadData() async {

    data = await getData();

    await processEachKey();
    
    setState(() {
      items = downloadList;
    });
  }


  //ذدریافت دیتا از شیردپرفرنس
  Future<SharedPreferencesAsync> getData() async {
    return SharedPreferencesAsync();
  }


  // در این بخش دینا دریافت شده و بخش های مورد نظر در دانلود لیست ذخیره می‌شوند
  Future<void> processEachKey() async {

    keys = await data.getKeys();

    downloadList.clear();
    
    if(keys.isNotEmpty) {
      for (String key in keys) {

        List<String>? list = await data.getStringList(key);

        if (list != null) {
          if (list[4] == 'completed' || list[4] == 'failed') {
            downloadList.add(list);
            downloadListKeys.add(key);
          }
        }
      }
    }
    
  }


  Future<void> updateData() async {
    await downloadListUpdate();

    if (mounted) {
      setState(() {
        items = downloadList;
      });
    }
  }


  Future<void> downloadListUpdate() async {

    downloadList.clear();

    for (String key in downloadListKeys) {
      List<String>? value = await data.getStringList(key);

      if (value != null && value.length > 4) {
        if (value[4] == 'completed' || value[4] == 'failed') {
          downloadList.add(value);
        }
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
              child: Text('حذف', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                deleteDownload(index, false);
                Navigator.of(context).pop();
              },
            ),),
            
            Align(alignment: Alignment.centerRight, child: TextButton(
              child: Text('حذف به همراه فایل', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
        body: items.length == 0
        
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: SvgPicture.asset(
                    'assets/svg/empty_downloaded.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primaryFixedDim, // تنظیم رنگ
                      BlendMode.modulate,
                    ),
                  ),
                ),
                
                const SizedBox(height: 5),

                const Text('فایلی دانلود نشده')
              ]
            )
        )

        : SafeArea(
          child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DownloadedCard(
                          title: items[index][1],
                          situation: items[index][4],
                          onClick: () {
                            openFile(index);
                          },
                          onMoreClick: () {
                            detailsDialog(context, index);
                          },
                          onDeleteClick: () {
                            deleteDialog(context, index);
                          },
                          onRedownloadClick: () {
                            setSituation(index, 'queue');
                          },
                        ),
                      );
                    },
                  )

                ),
              ],
            ),
        ),
      ),
    );
  }
}
