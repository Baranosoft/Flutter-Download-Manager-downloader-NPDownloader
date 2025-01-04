import 'package:flutter/material.dart';
import 'package:noarman_professional_downloader/components/downloading_card.dart';
import 'package:noarman_professional_downloader/utils/delete_file.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';
import 'package:open_file/open_file.dart';
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
      });
    }
  }


  Future<SharedPreferencesAsync> getData() async {
    return SharedPreferencesAsync();
  }


  Future<void> processEachKey() async {

    keys = await data.getKeys();

    downloadList.clear();

    if (keys.isNotEmpty) {
      for (String key in keys) {
        List<String>? value = await data.getStringList(key);

        if (value != null && value.length > 5) {
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


  void openFile(int index) async {
    try {
      await OpenFile.open('${downloadList[index][2]}/${downloadList[index][1]}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('مشکل در باز کردن فایل: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
  void dispose() {
    _timer?.cancel();
    items = [];
    downloadList = [];
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.isEmpty

        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: SvgPicture.asset(
                    'assets/svg/empty_downloading.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primaryFixedDim, // تنظیم رنگ
                      BlendMode.modulate,
                    ),
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
        
            return DownloadingCard(
              downloadDetails: items[index],
              queueCall: () {
                setSituation(index, 'queue');
              },
              stopCall: () {
                setSituation(index, 'stopped');
              },
              deleteDialogCall: () {
                deleteDialog(context, index);
              },
              openFileCall: () {
                openFile(index);
              },
            );
        
          },
        )
      )
    );
  }
}