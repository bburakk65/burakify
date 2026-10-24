import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../errors/app_log.dart';

/// Android'de arka planda çalma + bildirim/kilit ekranı kontrollerini açar.
/// `AudioPlayer` oluşturulmadan ÖNCE bir kez çağrılmalıdır.
///
/// Windows ve testlerde hiçbir şey yapmaz (false döner). Başarısız olursa
/// uygulama yine açılır; yalnızca arka plan çalma devre dışı kalır.
Future<bool> initBackgroundAudio() async {
  if (kIsWeb || !Platform.isAndroid) {
    return false;
  }
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.burakify.app.channel.audio',
      androidNotificationChannelName: 'Burakify çalma kontrolleri',
      androidNotificationOngoing: true,
    );
    return true;
  } catch (error) {
    AppLog.error('background_audio_init_failed', error);
    return false;
  }
}
