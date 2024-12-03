import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:noarman_professional_downloader/utils/delete_file.dart';
import 'package:noarman_professional_downloader/utils/multiple_link_maker.dart';
import 'package:noarman_professional_downloader/utils/time_size_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';


class AddDownloadPage extends StatefulWidget {

  final Function() onCallback;
  const AddDownloadPage({super.key, required this.onCallback});

  @override
  State<AddDownloadPage> createState() => _AddDownloadPageState();
}

class _AddDownloadPageState extends State<AddDownloadPage> {

  final SharedPreferencesAsync downloadList = SharedPreferencesAsync();

  final TextEditingController _linkController0 = TextEditingController();
  final TextEditingController _linkController1 = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _directoryController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  String _fileSizeController = 'در حال دریافت...';

  var formatClass = TimeSizeFormat();

  var deleteClass = DeleteFile();

  bool isMultipleLink = false;

  var multipleLinkMaker = MultipleLinkMaker();


  @override
  void initState() {
    super.initState();

    fillDefaultDirectory();

    pasteLink(0);

  }


  //چسباندن لینک فایل
  Future<void> pasteLink(int linkNum) async {
    ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;

    if (clipboardText != null) {
      if (linkNum == 0) {
        _linkController0.text = clipboardText;
        getFileNameFromUrl(clipboardText);
        getFileSizeFromUrl(clipboardText);
      } else if (linkNum == 1) {
        _linkController1.text = clipboardText;
      } 

    }
  }


  //انتخاب محل ذخیره فایل
  Future<String> prepareSaveDir() async {

    Directory? rootDirectory = await getExternalStorageDirectory();

    final savedDir = Directory('${rootDirectory!.parent.parent.parent.parent.path}/NPDownloader');

    if (!await savedDir.exists()) {
      await savedDir.create(recursive: true);
    }

    return savedDir.path;

  }


  //دریافت محل ذخیره پیش‌فرض
  void fillDefaultDirectory() async {
    String defaultDirectory = await prepareSaveDir();
    _directoryController.text = defaultDirectory;
  }


  //ساخت نام فایل براساس لینک دانلود
  void getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String decodedFileName = Uri.decodeComponent(uri.pathSegments.last);
    _fileNameController.text = decodedFileName;
  }


  //دریافت اندازه فایل پیش از دانلود
  void getFileSizeFromUrl(String url) async {
    
    try {
      Dio dio = Dio();

      Response response = await dio.head(url);

      String? contentLength = response.headers.value('content-length');

      if (contentLength != null) {
        if (mounted) {
          setState(() {
            _fileSizeController = contentLength;
          });
        }
        
      } else {
        if (mounted) {
          setState(() {
            _fileSizeController = 'حجم فایل در دسترس نیست';
          });
        }        
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fileSizeController = 'خطا در دریافت حجم فایل';
        });
      }
      
    }
  }


  //بررسی عددبودن مقدار
  bool checkInt(String value) {
    if (int.tryParse(value) != null) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> deleteDownload(String fileName, String directory, bool fileDelete) async {

    deleteClass.deleteDownload(fileName, directory, fileDelete);
    

    String theKey = directory + fileName;
    downloadList.remove(theKey);
    
  }


  void addMultipleDownloadLinks (String link1, String link2, String filename, String directory, String starttime) {

    List<String> multipleLinksList = []; 
    multipleLinksList = multipleLinkMaker.generateStringsBetween(link1, link2);

    for (int i = 0; i < multipleLinksList.length; i++) {

      addScheduledDownload(
        multipleLinksList[i],
        formatClass.fileNameFromUrl(multipleLinksList[i]),
        directory, 
        starttime,
        i == multipleLinksList.length-1 ? true : false
      );
    }
  }


  //اضافه کردن دانلود جدید
  Future<void> addScheduledDownload(String url, String filename, String directory, String starttime, bool isFinalLink) async {
    
    print('url');
    print('filename');
    print(starttime);
    print(directory);

    SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

    //بررسی وجود فایل با اسم مشابه
    String? newDownload = await asyncPrefs.getString('$directory$filename');

    File file = File('$directory/$filename');
    bool fileExist = false;

    if (file.existsSync()) {
      fileExist = true;
    }

    try {
      //در صورتی که دانلود بدون زمان‌بندی باشد
      if (starttime == '') {
        if (!fileExist) {
          await downloadList.setStringList('$directory$filename', 
            <String>[url, filename, directory, starttime, 'queue', '0', checkInt(_fileSizeController) ? _fileSizeController : '1', '0'
          ]);
          print(starttime);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('این فایل در این محل ذخیره موجود است'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(label: 'حذف', onPressed: () {
                deleteDownload(filename, directory, true);
              }),
            ),
          );
        }

      //در صورتی که دانلود دارای زمان‌بندی باشد
      } else {
        if (newDownload == null) {
          await downloadList.setStringList('$directory$filename',
           <String>[url, filename, directory, starttime, 'scheduled', '0', checkInt(_fileSizeController) ? _fileSizeController : '1', '0'
          ]);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('این فایل در این محل ذخیره موجود است'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      if (isFinalLink && !fileExist) {
        widget.onCallback();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('به لیست دانلودها افزوده شد'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch(e) {
      print('fail');
      print(e.toString());
    }
    
  }


  @override
  void dispose() {
    _linkController0.dispose();
    _linkController1.dispose();
    _fileNameController.dispose();
    _directoryController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        if (isMultipleLink) {
          addMultipleDownloadLinks(_linkController0.text,_linkController1.text,_fileNameController.text,_directoryController.text, _startTimeController.text);
        } else {
          addScheduledDownload(_linkController0.text,_fileNameController.text,_directoryController.text, _startTimeController.text, true);
        }
        
      },
      child: const Icon(Icons.add),
      ),
      body:  Padding(
        padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10, top: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () {
                    pasteLink(0);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _linkController0,
                    onChanged: (newLink) {
                      getFileNameFromUrl(newLink);
                      getFileSizeFromUrl(newLink);
                    },
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(labelText: 'لینک دانلود', border: OutlineInputBorder()),
                  ),
                ),
                
              ],
            ),
        
            const SizedBox(height: 10,),

            Row(children: [
              const Text(
                'حجم: ',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                checkInt(_fileSizeController) ? formatClass.sizeFormat(int.parse(_fileSizeController)) : _fileSizeController,
                style: TextStyle(color: checkInt(_fileSizeController) ? Colors.green : Colors.red[900], fontSize: 16),
                
              ),
            ],),

            const SizedBox(height: 5),

            Align(alignment: Alignment.centerRight, child: Row(children: [
              Checkbox(value: isMultipleLink, onChanged: (change) {
                setState(() {
                  isMultipleLink = (change != null) ? isMultipleLink = change : isMultipleLink = false;
                });
              }),
              const SizedBox(width: 2),
              const Text('دانلود چندتایی')
              
            ]),),

            const SizedBox(height: 10
            ),

            if (isMultipleLink)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () {
                      pasteLink(1);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _linkController1,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(labelText: 'لینک نهایی', border: OutlineInputBorder()),
                    ),
                  ),
                ]
              ),
            
            if (!isMultipleLink)
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'نام فایل'),
                textAlign: (_fileNameController.text.isNotEmpty) ? formatClass.textAlign(_fileNameController.text) : TextAlign.right,
                style: const TextStyle(overflow: TextOverflow.clip),
                maxLines: 2,
              ),
        
            const SizedBox(height: 10,),
        
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      _directoryController.text = selectedDirectory;
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _directoryController,
                    decoration: const InputDecoration(labelText: 'محل ذخیره‌سازی', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
        
            const SizedBox(height: 10,),
            
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      _startTimeController.text = selectedTime.format(context);
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(labelText: 'زمان شروع', border: OutlineInputBorder()),
                    readOnly: true,
                  ),
                ),
              ],
            ),

          ],
        ),
      )
    );
  }
}