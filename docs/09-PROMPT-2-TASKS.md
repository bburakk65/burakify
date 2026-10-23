# 09 — Prompt 2 Görev Listesi

> Güncel durum ve sonuçlar: docs/12-PROMPT-2-RAPOR.md. Bu liste Prompt 1 sonundaki plandır.

1. Flutter SDK'nın kurulabildiği bir ortam bul (bu ortamda ağ erişimi kısıtlı olabilir) veya GitHub Actions üzerinde doğrulama akışını kur.
2. GitHub deposunu kullanıcıyla birlikte oluştur ve kodları yükle (kullanıcı onayıyla).
3. `flutter create . --platforms=android,windows --org com.burakify` ile platform klasörlerini üret; `applicationId`'yi sabitle.
4. `pubspec.yaml` paketlerini `flutter pub get` ile çözümle, uyumsuzlukları düzelt, sürümleri belgele.
5. `core/design`: renk/tipografi token'ları, koyu/açık tema, kontrast testi.
6. `core/animation`: `BurakifyMotion` + `MotionPolicy` + birim testleri.
7. `app/`: uygulama kabuğu, `go_router` rotaları, adaptif gezinme (alt çubuk / rail / yan menü).
8. Açılış (splash) animasyonu: ilk açılış / sonraki açılış davranışı.
9. Boş durum, hata durumu, iskelet yükleme bileşenleri + widget testleri.
10. `ci.yml`'yi gerçekten çalıştır; kırmızıysa düzelt.
11. Kullanıcıya "telefondan APK indirme" adımlarını yaz.

## Oynatma görevleri (docs/10'a göre; Prompt 2–4'e dağıtılacak)

12. `PlayerService` arayüzü ve sahte (fake) uygulaması + kuyruk/karıştır/tekrar birim testleri.
13. `AudioHandler` (audio_service + just_audio) ve `AudioService.init` tek örnek; manifest: servis, `mediaPlayback` türü, izinler, `RECEIVE_BOOT_COMPLETED` **eklenmeyecek**.
14. `audio_session`: ses odağı, `becomingNoisy` duraklatma ayarı.
15. Dosya seçici (SAF) ile yerel müzik, kalıcı URI, etiket okuma; internetsiz çalışma.
16. Mini oynatıcı + tam ekran oynatıcı, servis durumuna abone arayüz.
17. Hata durumları (bulunamadı, bozuk, desteklenmeyen, ağ) + zaman aşımı.
18. Gerçek Android 10 cihazda 12 senaryoluk test turu; sonuçları docs/10 tablosuna yaz.
