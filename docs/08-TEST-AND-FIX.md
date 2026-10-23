# 08 — Test ve Hata Düzeltme

## Planlanan testler

| Katman | Test |
|---|---|
| Birim | Sürüm karşılaştırma, SHA-256 doğrulama, `MotionPolicy`, `AppError` eşleme, kuyruk mantığı |
| Widget | Tema (koyu/açık), boş/hata/yükleme durumları, kırılma noktası düzenleri |
| Entegrasyon | Oynatıcı durum akışı (sahte oynatıcıyla), güncelleme durum makinesi (sahte HTTP ile) |
| Cihaz (elle) | Android 10 telefon: arka plan ses, bildirim kontrolü, APK güncelleme; Windows: medya tuşları |

## Hata düzeltme protokolü

Prompt 1'deki 12 maddelik protokol her aşamada uygulanır: incele → listele → bağımlılık uyumu → küçük değişiklik → format/analiz → test → derleme → günlük inceleme → yeniden test; çalıştırılamayan test başarılı sayılmaz.

Müzik oynatma için 12 senaryoluk cihaz test matrisi `10-PLAYBACK-ANDROID-REQUIREMENTS.md` bölüm 7'dedir.

## Bilinen eksikler (Prompt 1 sonu)

- Flutter SDK bu ortamda çalıştırılamadı (indirme sunucuları ve paket kayıtları erişilemez) → `flutter analyze/test/build` çalıştırılamadı. Güncel durum: docs/12-PROMPT-2-RAPOR.md.
- GitHub erişimi yok.
- Paket sürümleri (`pubspec.yaml`) henüz çözümlenmedi.
