import 'dart:core';

class MultipleLinkMaker {
  List<String> generateStringsBetween(String str1, String str2) {
    // لاستخراج تمام اعداد از هر رشته و ذخیره طول آنها
    final matches1 = RegExp(r'\d+').allMatches(str1).toList();
    final matches2 = RegExp(r'\d+').allMatches(str2).toList();

    final numbers1 = matches1.map((m) => int.parse(m.group(0)!)).toList();
    final numbers2 = matches2.map((m) => int.parse(m.group(0)!)).toList();
    final lengths = matches1.map((m) => m.group(0)!.length).toList();

    // پیدا کردن قسمت‌های ثابت رشته که بین اعداد قرار دارند
    final fixedParts = str1.split(RegExp(r'\d+'));

    // چک کردن طول لیست‌ها برای مطابقت
    if (numbers1.length != numbers2.length) {
      throw Exception("The two strings have different numbers of numeric parts.");
    }

    // تولید رشته‌ها با تغییر تمام اعداد متفاوت در بازه‌های خودشان
    List<String> result = [''];

    for (int i = 0; i < numbers1.length; i++) {
      int start = numbers1[i];
      int end = numbers2[i];
      int length = lengths[i];

      // اضافه کردن بخش ثابت به رشته‌ها
      for (int j = 0; j < result.length; j++) {
        result[j] += fixedParts[i];
      }

      // تولید ترکیبات برای بازه عددی فعلی
      List<String> newResult = [];
      for (int k = start; k <= end; k++) {
        String paddedNumber = k.toString().padLeft(length, '0');
        for (String res in result) {
      newResult.add(res + paddedNumber);
        }
      }
      result = newResult;
    }

    // اضافه کردن آخرین بخش ثابت رشته‌ها
    for (int j = 0; j < result.length; j++) {
      result[j] += fixedParts.last;
    }

    return result;
  }
}
