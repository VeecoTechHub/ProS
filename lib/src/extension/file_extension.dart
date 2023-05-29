import 'dart:io';

import '../global_enum/enum_index.dart';

extension FileExtension on File {
  MediaType mediaType() {
    final extension = path.toLowerCase();
    if (extension.endsWith('jpg') || extension.endsWith('png') || extension.endsWith('jpeg')) {
      return MediaType.image;
    } else if (extension.endsWith('mp4') || extension.endsWith('mov')) {
      return MediaType.video;
    } else {
      return MediaType.image;
    }
  }
}
