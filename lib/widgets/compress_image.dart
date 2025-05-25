import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<XFile> compressImage(XFile file) async {
  try {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
    );

    if (result != null) {
      return XFile(result.path);
    } else {
      throw Exception('Image compression failed.');
    }
  } catch (e) {
    print('Error during image compression: $e');
    return file;
  }
}
