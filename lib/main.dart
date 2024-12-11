import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noarman_professional_downloader/pages/add_download_page.dart';
import 'dart:async';
import 'package:noarman_professional_downloader/pages/downloaded_page.dart';
import 'package:noarman_professional_downloader/pages/downloading_page.dart';
import 'package:noarman_professional_downloader/pages/settings_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:noarman_professional_downloader/services/download_service.dart' as download_service;
import 'package:animations/animations.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  runApp(const MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: ui.Color.fromARGB(255, 236, 239, 236), // رنگ نوار ناوبری
      systemNavigationBarIconBrightness: Brightness.light, // رنگ آیکون‌ها
    ));

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }


  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'NPDownloader Notification',
        channelDescription: 'This is NPDownloader Notification',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(3000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }


  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'مدیریت دانلودها در پیش‌زمینه در حال انجام است.',
        notificationText: 'باز کردن برنامه',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'exit', text: 'پایان', textColor: Colors.red)
        ],
        callback: download_service.startCallback,
      );
    }
    
  }


  Future<void> refreshService() async {

    bool isRining = await FlutterForegroundTask.isRunningService;

    if (isRining) {
      FlutterForegroundTask.sendDataToTask('');
    } else {
      _startService();
      FlutterForegroundTask.sendDataToTask('');
    }
    
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _initService();
    });

    pages = <Widget>[
      AddDownloadPage(onCallback: () {
        refreshService();
      }),
      DownloadingPage(onCallback: () {
        refreshService();
      }),
      Downloadedpage(onCallback: () {
        refreshService();
      }),
      SettingsPage(onCallback: () {
        refreshService();
      })
    ];
  }


  int selectedPage = 1;
  List<Widget>? pages;


  @override
  void dispose() {
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: ui.TextDirection.rtl, child: Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages![selectedPage],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedPage = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.add_rounded), label: 'افزودن'),
          NavigationDestination(icon: Icon(Icons.downloading_rounded), label: 'درحال بارگیری'),
          NavigationDestination(icon: Icon(Icons.download_done_rounded), label: 'بارگیری شده'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'تنظیمات')
        ],
        selectedIndex: selectedPage,
      )
    ));
  }
}
