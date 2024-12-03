import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';


@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}


class MyTaskHandler extends TaskHandler {

  SharedPreferencesAsync? data = SharedPreferencesAsync();

  Set<String> keys = {};

  Set<String> downloadListKeys = {};

  List<List<String>> downloadList = [];

  File file = File('');

  int downloadedBytes = 0;

  String? now;

  bool storageProgress = true;

  CancelToken? cancelToken;


  @override
  void onStart(DateTime timestamp) async {

    await initData();
  
    print('Service started');
    
  }


  @override
  void onRepeatEvent(DateTime timestamp) async {

    if (downloadList.isNotEmpty) {
      await getNowTime();
      await sheduledDownloadsCheck();
      await queueDownloadsCheck();
    } else {
      print('download list is empty');
    }

  }


  Future<void> sheduledDownloadsCheck() async {

    if (downloadList != []) {
      for (int i = 0; i < downloadList.length; i++) {
        print(downloadList[i][3].toString() + '=' + now!);
        if (downloadList[i][3] == now && downloadList[i][4] == 'scheduled') {
          await setSituation(i, 'queue');
        }
      }
    }
    

  }


  Future<void> queueDownloadsCheck() async {

    if (await checkDownloading() == false) {

      if (downloadList != []) {
        bool isQueueDownload = false;
        for (int i = 0; i < downloadList.length; i++) {
          print('this is downloadlist situation');
          print(downloadList[i][4]);
          if (downloadList[i][4] == 'queue') {
            await downloadTask(i);
            isQueueDownload = true;
            break;
          }
        }
        if (!isQueueDownload) {
          if (cancelToken != null) {
            cancelToken!.cancel('Download canceled by user.');
          }
        }
      }
      
    } else {
      print('dio is downloading');
    }

  }


  Future<void> storageProgressTimer() async {
    storageProgress = false;
    await Future.delayed(const Duration(seconds: 1));
    storageProgress = true;
  }


  Future<void> initData() async {

    data = null;

    data = await getData();

    if (data != null) {
      await processEachKey();  
    }
    

    queueDownloadsCheck();
    
  }


  Future<void> getNowTime() async {
    DateTime nowTime = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(nowTime);
    now = formattedTime;
  }


  Future<SharedPreferencesAsync> getData() async {
    SharedPreferencesAsync newData = SharedPreferencesAsync();
    return newData;
  }


  Future<void> processEachKey() async {

    print(data);

    keys = await data!.getKeys();

    downloadList.clear();

    if (keys.isNotEmpty) {
      for (String key in keys) {
        List<String>? value = await data!.getStringList(key);

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


  Future<bool> checkDownloading() async {

    bool downloading = false;

    for (int i = 0; i < downloadList.length; i++) {
      if (downloadList[i][4] == 'downloading') {
        downloading = true;
      }
    }
    return downloading;
  }


  Future<void> cancelDownload(int index) async {
    if (cancelToken != null) {
      cancelToken!.cancel('Download canceled by user.');
    }

    fileCreation(index);

  }


  Future<void> fileCreation(int index) async {

    print('the key is: ');
    List<String> fileCreate = downloadList[index];
    file = File('${fileCreate[2]}/temp${fileCreate[1]}');

    if (file.existsSync()) {
      await appendFile('${fileCreate[2]}/temp${fileCreate[1]}', '${fileCreate[2]}/${fileCreate[1]}');
      await File('${fileCreate[2]}/temp${fileCreate[1]}').delete();
    }
    
  }


  Future<void> downloadTask(index) async {

    cancelToken?.cancel('canceled download');

    cancelToken = CancelToken();

    Dio dio = Dio();

    int downloadDuration = 0;

    file = File('${downloadList[index][2]}/${downloadList[index][1]}');
    bool fileExist = false;
    downloadedBytes = 0;

    if (file.existsSync()) {
      fileExist = true;
      downloadedBytes = file.lengthSync();
    }


    setSituation(index, 'downloading');


    if (fileExist) {
      try {
        // ignore: unused_local_variable
        Response response;
        response = await dio.download(
          deleteOnError: false,
          cancelToken: cancelToken,
          options: Options(
            headers: {"Range": "bytes=$downloadedBytes-"}, // ادامه دانلود از جایی که متوقف شده است
          ),
          downloadList[index][0],
          '${downloadList[index][2]}/temp${downloadList[index][1]}',
          onReceiveProgress: (int count, int total) {
            print('$count $total');
            if(count != -1 && storageProgress) {
              downloadDuration ++;
              setProgress(index, (count + downloadedBytes).toString(), downloadDuration);
              storageProgressTimer();
            }
          },
        );

        fileCreation(index);

        setProgress(index, 'full', downloadDuration);
        setSituation(index, 'completed');
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          fileCreation(index);
        } else {
          fileCreation(index);
          setSituation(index, 'failed');
        }
        
      }

    }

    if (fileExist == false) {

      bool makeNewFileSize = true;
      try {
        // ignore: unused_local_variable
        Response response;
        response = await dio.download(
          deleteOnError: false,
          cancelToken: cancelToken,
          options: Options(),
          downloadList[index][0],
          '${downloadList[index][2]}/${downloadList[index][1]}',
          onReceiveProgress: (int count, int total) {
            print('$count $total');
            if(count != -1 && storageProgress) {
              downloadDuration ++;
              setProgress(index, (count).toString(), downloadDuration);
              storageProgressTimer();
            }
            if (makeNewFileSize) {
              setFileSize(index, total.toString());
              makeNewFileSize = false;
            }
          },
        );

        setProgress(index, 'full', downloadDuration);
        setSituation(index, 'completed');
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          
        } else {
          print('Download failed: $e');
          setSituation(index, 'failed');
        }
        
      }

    }

  }


  Future<void> appendFile(String tempFilePath, String filePath) async {
    File file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.append);

    // خواندن داده‌های فایل موقت و افزودن به فایل اصلی
    List<int> tempData = await File(tempFilePath).readAsBytes();
    raf.writeFromSync(tempData);

    await raf.close();
  }
  


  Future<void> setSituation(int index, String situation) async {

    print('set Situation is Tuninggggggg');
    List<String>? value = downloadList[index];
    String theKey = value[2] + value[1];
    await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], situation, value[5], value[6], value[7]]);
    downloadList[index] = [value[0], value[1], value[2], value[3], situation, value[5], value[6], value[7]];

    initData();

  }


  Future<void> setFileSize(int index, String size) async {

    print('set Situation is Tuninggggggg');
    List<String>? value = downloadList[index];
    String theKey = value[2] + value[1];
    await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], value[4], value[5], size, value[7]]);

    initData();

  }


  Future<void> setProgress(int index, String progress, int newDuration) async {

    List<String>? value = downloadList[index];
    String theKey = value[2] + value[1];
    String newduration = (int.parse(value[7]) + newDuration).toString();
    if (progress == 'full') {
      await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], value[4], value[6], value[6], newduration]);
    } else {
      await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], value[4], progress, value[6], newduration]);
    }

  }


  @override
  void onReceiveData(Object data) {

    initData();

  }
  
  @override
  void onNotificationButtonPressed(String id) {

    FlutterForegroundTask.stopService();

  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    print('onNotificationPressed');
  }

  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }

  @override
  void onDestroy(DateTime timestamp) {
    print('onDestroy');
  }

}