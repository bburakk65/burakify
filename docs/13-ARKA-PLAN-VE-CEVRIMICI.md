# 13 — Arka plan çalma, çevrimiçi müzik ve arayüz cilası

**Durum: kod yazıldı; bu ortamda DERLENMEDİ ve ÇALIŞTIRILMADI (Flutter SDK ve ağ yok).**
Doğrulama sırası: GitHub Actions (analiz + 90+ test + APK/Windows derlemesi), sonra gerçek telefonda deneme.

## Arka plan çalma (Android)
- `just_audio_background` + `audio_service`. `main()` içinde `initBackgroundAudio()` yalnızca Android'de çalışır.
- Her parçaya `MediaItem` etiketi verilir (başlık, sanatçı) → bildirim ve kilit ekranı kartı.
- `tool/configure_platforms.py` manifeste şunları ekler: INTERNET, WAKE_LOCK, FOREGROUND_SERVICE,
  FOREGROUND_SERVICE_MEDIA_PLAYBACK, `AudioService` servisi (mediaPlayback), `MediaButtonReceiver`;
  `MainActivity` → `AudioServiceActivity`. Betik beklenen kalıp yoksa hata verir.
- **Bilinen sınır:** bildirimde oynat/duraklat ve ilerleme çubuğu olur; "sonraki/önceki" düğmeleri yoktur
  (kuyruk, motorun değil uygulamanın içinde). Özel `AudioHandler` sonraki aşamada.
- Windows'ta arka plan servisi yok: yalnızca uygulama açıkken çalar (pencere küçültülse de çalar).
- Açılışta boot izni yok; kendiliğinden müzik başlamaz.

## Çevrimiçi müzik
- Kaynak: Internet Archive (`archive.org`), anahtar gerektirmez, ücretsiz.
- Yalnızca üst verisinde Creative Commons veya kamu malı lisans adresi olan kayıtlar listelenir.
- Müzik kopyalanmaz/kaydedilmez; doğrudan akıtılır. Spotify vb. kataloğu DEĞİLDİR; arayüzde de bu yazar.
- `CatalogSource` arayüzü: başka yasal kaynak (ör. Jamendo, kendi API anahtarıyla) eklenebilir.
- Testler sahte HTTP ile; gerçek archive.org yanıtı bu ortamda denenemedi, bu yüzden ilk gerçek deneme telefonda.

## Arayüz
- Sekme geçişinde solarak/kayarak giriş, liste öğelerinde dalga girişi (`FadeSlideIn`), çalarken büyüyen kapak,
  dokunuşta titreşim geri bildirimi, mevcut mini oynatıcı/tam ekran geçişleri.
- "Animasyonları azalt" sistem ayarı açıksa animasyonlar kapanır veya kısalır.
