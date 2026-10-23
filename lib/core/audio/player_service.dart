/// Ses motoru arayüzü. Arayüz ve kuyruk mantığı yalnızca bunu bilir;
/// gerçek uygulama [JustAudioPlayerService], testlerde sahte uygulama kullanılır.
abstract class PlayerService {
  Stream<bool> get playingStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  /// Parça sonuna gelindiğinde olay üretir.
  Stream<void> get completedStream;

  /// Dosyayı yükler. Bulunamazsa/desteklenmiyorsa istisna fırlatır.
  Future<void> load(String path);

  /// Çalmayı başlatır; çalma bitene kadar beklemez.
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);

  /// 0.0 - 1.0 arası uygulama içi ses seviyesi (sistem sesinden ayrı).
  Future<void> setVolume(double volume);
  Future<void> dispose();
}
