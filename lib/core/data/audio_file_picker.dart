import 'package:file_picker/file_picker.dart';

import '../audio/track.dart';

/// Sistem dosya seçicisiyle ses dosyası yolları seçtirir. Depolama izni
/// istenmez; kullanıcı iptal ederse boş liste döner.
Future<List<String>> pickAudioPaths() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: kSupportedAudioExtensions,
  );
  if (result == null) {
    return <String>[];
  }
  return result.files
      .map((PlatformFile f) => f.path)
      .whereType<String>()
      .toList();
}
