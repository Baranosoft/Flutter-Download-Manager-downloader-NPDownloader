import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noarman_professional_downloader/pages/add_download_page.dart';
import 'dart:async';
import 'package:noarman_professional_downloader/pages/downloaded_page.dart';
import 'package:noarman_professional_downloader/pages/downloading_page.dart';
import 'package:noarman_professional_downloader/pages/settings_page.dart';
import 'package:noarman_professional_downloader/theme/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:noarman_professional_downloader/services/download_service.dart' as download_service;
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(
    MyApp(themeProvider: themeProvider)
  );

}


class MyApp extends StatelessWidget {

  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.themeData,
            home: const HomePage(),
          );
        }
      )
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


  // تعریف سرویس
  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'NPDownloader Notification',
        channelDescription: 'This is NPDownloader Notification',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(55000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }


  // راه‌اندازی سرویس
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


  // در صورت ایجاد تغییرات در دانلودها سرویس دانلود از طریق این فانکشن رفرش می‌شود
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


    // لیست تب‌ها
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


  int selectedPage = 0;
  List<Widget>? pages;


  @override
  void dispose() {
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: ui.TextDirection.rtl, child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // ارتفاع AppBar صفر
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.surface,
            statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark) ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          elevation: 0, // حذف سایه
          backgroundColor: Colors.transparent, // شفاف کردن AppBar
        ),
      ),
      body: PageTransitionSwitcher(
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
          NavigationDestination(icon: Icon(Icons.downloading_rounded), selectedIcon: Icon(Icons.download_for_offline_rounded), label: 'درحال بارگیری'),
          NavigationDestination(icon: Icon(Icons.download_done_rounded), label: 'بارگیری شده'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'تنظیمات')
        ],
        selectedIndex: selectedPage,
      )
    ));
  }
}
