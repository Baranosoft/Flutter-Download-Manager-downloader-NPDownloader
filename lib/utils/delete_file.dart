
import 'dart:io';

class DeleteFile {


  Future<void> deleteDownload(String fileName, String directory, bool fileDelete) async {

    File tempFile = File('$directory/temp$fileName');

    if (fileDelete) {

      if (tempFile.existsSync()) {
        await File('$directory/temp$fileName').delete();
      }

      File file = File('$directory/$fileName');
      if (file.existsSync()) {
        await File('$directory/$fileName').delete();
      }

    }
    
  }


}