# 01 — Teknoloji Seçimi

## Adaylar

| Ölçüt | Flutter | Kotlin Multiplatform + Compose | React Native | Native ayrı (Kotlin + WinUI/C#) |
|---|---|---|---|---|
| Android 10 | Evet (minSdk 21+) | Evet | Evet | Evet |
| Windows masaüstü | Resmi destek | Compose Desktop (JVM), olgunluk daha düşük | Topluluk/Microsoft projesi, ek bakım yükü | Evet, ama ayrı kod tabanı |
| Animasyon | Kendi render motoru, 60/120 fps, güçlü animasyon API'si | İyi | Yerel köprü maliyeti | En iyi ama iki kez yazılır |
| Gerçek ses + arka plan | `just_audio` + `audio_service` (Android'de foreground service/MediaSession) | ExoPlayer doğrudan | Eklentilere bağlı | Doğrudan |
| Tablet/PC uyum | Tek kod, adaptif düzen | İyi | Orta | İki ayrı UI |
| GitHub Actions | Android APK ve Windows build runner'ları hazır | Mümkün, daha karmaşık | Mümkün | İki ayrı iş hattı |
| Maliyet | Ücretsiz; GitHub Actions ücretsiz kotası | Ücretsiz | Ücretsiz | Ücretsiz |
| Başlangıç seviyesi için bakım | Tek dil, tek proje | Çoklu modül | JS + yerel bilgisi | En zor |

## Karar: **Flutter (Dart)**

Nedenler:

1. Tek kod tabanı: telefon, tablet, Windows. Başlangıç seviyesi biri için bakım yükü en düşük seçenek.
2. Animasyon yoğun bir ürün için render motoru ve animasyon API'si olgun; ekran geçişleri, paylaşılan öğe (Hero) geçişleri, iskelet yükleme kolay.
3. Gerçek ses: `just_audio` (çalma) + `audio_service` (kilit ekranı, bildirim kontrolleri, arka plan).
4. GitHub Actions üzerinde Android (Linux runner) ve Windows (Windows runner) derlemesi mümkün; bilgisayar gerekmez.

## Platforma özel modüller

`lib/platform/android/` ve `lib/platform/windows/` altında soyut arayüzlerin (ör. `UpdateInstaller`, `MediaIntegration`) platform uygulamaları tutulur. Ortak kod bu arayüzlere bağımlıdır, platforma değil.

## Önemli ayrım

- **Android:** `.apk` (ve gelecekte Play için `.aab`).
- **Windows:** ayrı paket (ZIP taşınabilir + MSIX veya Inno Setup kurulumu). Windows uygulaması Android APK'sı olarak sunulmaz.

## Riskler

| Risk | Etki | Önlem |
|---|---|---|
| Telefonda Flutter derlenemez | Yüksek | Derleme yalnızca GitHub Actions'ta |
| Windows'ta arka plan ses/medya tuşları farklı davranır | Orta | `MediaIntegration` arayüzü + Windows'a özel uygulama, Prompt 7'de test |
| Android 10'da APK kurulum izni akışı | Orta | `REQUEST_INSTALL_PACKAGES` akışı Prompt 9'da gerçek cihazda test |
| Paket sürümleri uyumsuz çıkabilir | Orta | Prompt 2'de `flutter pub get` ile doğrula, sabitle |
