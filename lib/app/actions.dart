import 'package:flutter/material.dart';

import '../core/data/library_controller.dart';
import '../core/errors/app_log.dart';
import 'app_scope.dart';

/// Dosya seçiciyi açar ve seçilenleri kitaplığa ekler.
Future<void> pickAndImport(BuildContext context, AppServices services) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final List<String> paths;
  try {
    paths = await services.pickFiles();
  } catch (error) {
    AppLog.error('file_picker_failed', error);
    messenger.showSnackBar(
      const SnackBar(content: Text('Dosya seçici açılamadı.')),
    );
    return;
  }
  if (paths.isEmpty) {
    return;
  }
  importPaths(messenger, services, paths);
}

/// Yolları kitaplığa ekler ve sonucu kısa bir bildirimle gösterir.
void importPaths(
  ScaffoldMessengerState messenger,
  AppServices services,
  List<String> paths,
) {
  final AddResult r = services.library.addPaths(paths);
  final List<String> parts = <String>[
    if (r.added > 0) '${r.added} şarkı eklendi',
    if (r.duplicates > 0) '${r.duplicates} dosya zaten ekliydi',
    if (r.unsupported > 0) '${r.unsupported} desteklenmeyen dosya atlandı',
  ];
  if (parts.isEmpty) {
    return;
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(parts.join(' · '))));
}
