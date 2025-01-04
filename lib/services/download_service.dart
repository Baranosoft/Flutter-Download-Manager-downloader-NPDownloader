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
    
  }


  // این فانکشن به صورت دوره‌ای هر ۵۵ثانیه یک بار اجرا می‌شود

  // زمان حال را می‌گیرد و با زمان دانلودهای زمان‌بندی شده مقایسه می‌کند
  @override
  void onRepeatEvent(DateTime timestamp) async {

    if (downloadList.isNotEmpty) {
      await getNowTime();
      await sheduledDownloadsCheck();
      await queueDownloadsCheck();
    }

  }


  //دانلودهای زمان‌بندی شده بررسی می‌شوند تا در صورت رسیدن به زمان معین
  //به دانلودهای در صف اضافه شوند
  Future<void> sheduledDownloadsCheck() async {

    if (downloadList != []) {
      for (int i = 0; i < downloadList.length; i++) {
        if (downloadList[i][3] == now && downloadList[i][4] == 'scheduled') {
          await setSituation(i, 'queue');
        }
      }
    }
    

  }


  // لیست دانلودها چک می‌شوند تا در صورت وجود دانلود در صف
  // این دانلود شروع شود و وضعیت آن به در حال دانلود تغییر کند

  // البته ابتدا بررسی می‌شود که دانلودی در حال انجام نباشد
  Future<void> queueDownloadsCheck() async {

    if (await checkDownloading() == false) {

      if (downloadList != []) {
        bool isQueueDownload = false;
        for (int i = 0; i < downloadList.length; i++) {
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
    }

  }


  // این تایمر برای این است تا هر یک ثانیه یکبار حجم دانلود شده جدید ارسال شود
  Future<void> storageProgressTimer() async {
    storageProgress = false;
    await Future.delayed(const Duration(seconds: 1));
    storageProgress = true;
  }


  // ذخیره داده در متغیر داده و بررسی وضعیت دانلود در حال بارگیری
  Future<void> initData() async {

    data = null;

    data = await getData();

    if (data != null) {
      await processEachKey();  
    }
    

    queueDownloadsCheck();
    
  }


  // دریافت زمان فعلی
  Future<void> getNowTime() async {
    DateTime nowTime = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(nowTime);
    now = formattedTime;
  }


  // دریافت داده‌ها از شیردپرفرنس
  Future<SharedPreferencesAsync> getData() async {
    SharedPreferencesAsync newData = SharedPreferencesAsync();
    return newData;
  }


  // تبدیل داده‌های نامنظم به لیست
  Future<void> processEachKey() async {

    keys = await data!.getKeys();

    downloadList.clear();

    if (keys.isNotEmpty) {
      for (String key in keys) {
        List<String>? value = await data!.getStringList(key);

        if (value != null && value.length > 4) {
          if (value[4] == 'queue' || value[4] == 'downloading' || value[4] == 'stopped' || value[4] == 'scheduled') {
            downloadList.add(value);
            downloadListKeys.add(key);
          }
        }
      }
    }
  }


  // بررسی اینکه آیا دانلودی در حال انجام است
  Future<bool> checkDownloading() async {

    bool downloading = false;

    for (int i = 0; i < downloadList.length; i++) {
      if (downloadList[i][4] == 'downloading') {
        downloading = true;
      }
    }
    return downloading;
  }


  // لغو دانلود
  Future<void> cancelDownload(int index) async {
    if (cancelToken != null) {
      cancelToken!.cancel('Download canceled by user.');
    }

    fileCreation(index);

  }


  // ساخت فایل جدید بر مبنای بخش دانلود شده جدید به علاوه بخشی که قبلا دانلود شده در صورت وجود
  Future<void> fileCreation(int index) async {

    List<String> fileCreate = downloadList[index];
    file = File('${fileCreate[2]}/temp${fileCreate[1]}');

    if (file.existsSync()) {
      await appendFile('${fileCreate[2]}/temp${fileCreate[1]}', '${fileCreate[2]}/${fileCreate[1]}');
      await File('${fileCreate[2]}/temp${fileCreate[1]}').delete();
    }
    
  }


  // فانکشن دانلود فایل
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
          setSituation(index, 'failed');
        }
        
      }

    }

  }


  // این فانکشن بخشی که در گذشته دانلود شده را به دانلود فعلی پیوند میزند
  Future<void> appendFile(String tempFilePath, String filePath) async {
    File file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.append);

    // خواندن داده‌های فایل موقت و افزودن به فایل اصلی
    List<int> tempData = await File(tempFilePath).readAsBytes();
    raf.writeFromSync(tempData);

    await raf.close();
  }
  

  // تغییر وضعیت دانلود
  Future<void> setSituation(int index, String situation) async {

    List<String>? value = downloadList[index];
    String theKey = value[2] + value[1];
    await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], situation, value[5], value[6], value[7]]);
    downloadList[index] = [value[0], value[1], value[2], value[3], situation, value[5], value[6], value[7]];

    initData();

  }


  // تعین اندازه فایل دانلودی
  Future<void> setFileSize(int index, String size) async {

    List<String>? value = downloadList[index];
    String theKey = value[2] + value[1];
    await data!.setStringList(theKey, [value[0], value[1], value[2], value[3], value[4], value[5], size, value[7]]);

    initData();

  }


  // تعیین پیشرفت دانلود
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

  }

  @override
  void onNotificationDismissed() {

  }

  @override
  void onDestroy(DateTime timestamp) {

  }

}