
import 'dart:ui';

class TimeSizeFormat {

  TimeSizeFormat();


  String timeFormat(int time) {
    if (time <= 60) {
      return '$time ثانیه';  // اگر کمتر از 1024 بایت باشد
    } else if (time > 60 && time < 3600) {
      return '${(time / 60).toStringAsFixed(0)}دقیقه';  // در مقیاس کیلوبایت
    } else {
      return '${(time / 3600).toStringAsFixed(0)}ساعت';  // در مقیاس ترابایت
    }
  }


  String sizeFormat(int size, [int decimalNums = 0]) {
    if (size < 1024) {
      return '$size ب';  // اگر کمتر از 1024 بایت باشد
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(decimalNums)}ک';  // در مقیاس کیلوبایت
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(decimalNums)}م';  // در مقیاس مگابایت
    } else if (size < 1024 * 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(decimalNums)}گ';  // در مقیاس گیگابایت
    } else {
      return '${(size / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(decimalNums)}ت';  // در مقیاس ترابایت
    }
  }


   // تابعی برای تشخیص زبان فارسی یا انگلیسی
  TextAlign textAlign(String text) {
    final RegExp persianChars = RegExp(r'[آ-ی]');
    return persianChars.hasMatch(text) ? TextAlign.right : TextAlign.left;
  }


  String fileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String decodedFileName = Uri.decodeComponent(uri.pathSegments.last);
    return decodedFileName;
  }
  
}