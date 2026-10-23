# 10 — Zorunlu Müzik Oynatma ve Android Gereksinimleri

Bu doküman, Prompt 1 ekindeki gereksinimlerin mimariye işlenmiş halidir. **Durum: yalnızca tasarım.** Hiçbiri bu ortamda uygulanmadı veya test edilmedi (Flutter SDK yok). Uygulama Prompt 2–4'te yapılacak; "çalışıyor" ifadesi ancak gerçek test sonucuyla yazılacak.

## 1. Temel kural: oynatma altyapısı arayüzden ayrı

```
UI (features/player, mini oynatıcı)  ──dinler──▶  PlayerController (Riverpod)
                                                     │ komut gönderir / durum akışı okur
                                              PlayerService (soyut arayüz)  core/audio
                                                     │
                                  AudioHandler (audio_service) + just_audio  platform/android
                                                     │
                       Android: Foreground Service (mediaPlayback) + MediaSession + MediaStyle bildirim
```

- Oynatma, uygulama arayüzü kapansa bile yaşayan `AudioHandler` içinde çalışır. Bildirim/kilit ekranı kontrolleri arayüze değil bu servise bağlıdır.
- Arayüz yalnızca durum akışına (`PlaybackState`, `MediaItem`) abone olur. Şarkı değişince arayüz güncellenir; servis yeniden oluşturulmaz (tek `AudioHandler` örneği, `AudioService.init` bir kez).
- Animasyonlar arayüz katmanındadır; ses komutu animasyon beklemez.

## 2. Gereksinim → tasarım eşlemesi

| Gereksinim | Yaklaşım |
|---|---|
| Arka plan / ekran kapalı / kilit | `audio_service` foreground servis (`foregroundServiceType="mediaPlayback"`), `just_audio` kısmi wake lock (`androidEnableWakeLock`/ses çalarken) |
| Bildirim kontrolleri | `audio_service` MediaStyle bildirimi: kapak, başlık, sanatçı, oynat/duraklat, önceki/sonraki, konum; bildirime tıklayınca `MainActivity` |
| Kilit ekranı | MediaSession (audio_service sağlar); Android 10'da kilit ekranı kontrolü medya bildirimi üzerinden gelir |
| Bluetooth / kulaklık tuşları | `audio_service` medya düğmesi alıcısı (MediaSession üzerinden) |
| Ses odağı, çağrı | `audio_session` (müzik profili): kesintide duraklat/kıs, çağrı bitince politika uygula; `becomingNoisy` olayında duraklat (kullanıcı ayarıyla açılıp kapanır) |
| Durum koruma | Servis durumu kaynak olur; arayüz yeniden açılınca servisten okur. Yön değişimi `AndroidManifest`'te `configChanges` ve state hoisting ile |
| Boot'ta otomatik başlama | **Yapılmaz.** `RECEIVE_BOOT_COMPLETED` eklenmez. Not: audio_service'in medya düğmesi alıcısı uygulamayı kullanıcı tuşuyla uyandırabilir; bu istenen davranıştır, kendiliğinden müzik başlatma değildir |
| Kaynak serbest bırakma | Kullanıcı durdurunca `stop()` → `just_audio` dispose, wake lock bırak, servis `stopForeground`, bildirim kalkar |
| Arka planda gereksiz işlem | Arka planda ilerleme zamanlayıcıları/animasyon yok; yalnızca ses ve bildirim konumu |

## 3. Android 10 izinleri ve kısıtları

| Konu | Karar |
|---|---|
| `FOREGROUND_SERVICE` | Gerekli (manifest). Android 10'da `foregroundServiceType` bildirilir |
| `WAKE_LOCK` | Gerekli (manifest) |
| `INTERNET` | Yalnızca ağ üzerinden çalma/güncelleme için; yerel çalma internetten bağımsız |
| Bildirim izni | Android 10'da çalışma zamanı izni yok. Android 13+ için `POST_NOTIFICATIONS` istenecek (reddedilirse ses yine çalar, kontrol bildirimi görünmeyebilir; kullanıcıya açıklanır) |
| Yerel dosya erişimi | **Depolama izni istenmez.** Sistem dosya seçici (Storage Access Framework) ile kullanıcı dosya seçer; kalıcı URI izni saklanır. Android 10 kapsamlı depolama ile uyumlu |
| Android 14+ | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` izni de eklenir (geleceğe uyum) |
| Pil optimizasyonu | Özel muafiyet istenmez; foreground servis yeterlidir. Üreticiye özgü agresif kapatmalar (bazı markalar) için ayarlarda bilgi notu |

Bunlar tasarım kararıdır; doğrulama gerçek Android 10 cihazda yapılacaktır.

## 4. Müzik kaynağı ve çevrimdışı

- **Yerel müzik (birincil):** dosya seçici ile mp3/m4a/flac/ogg/wav; internet gerektirmez; hesap gerektirmez. Meta veri (başlık/sanatçı/kapak) dosya etiketlerinden okunur; yoksa dosya adı kullanılır.
- **Örnek sesler:** yalnızca lisansı doğrulanmış (CC0/kamu malı/kendi üretimimiz); `assets/audio_samples/LICENSES.md`.
- **Çevrimiçi katalog:** bu aşamada **yok**. Çalışmayan "katalog" düğmesi eklenmeyecek. İleride açık lisanslı bir kaynak seçilirse lisans koşulları (atıf, ticari kullanım) ayrıca incelenir.
- **Önbellek/indirme mimarisi (planlı):** `DownloadManager` arayüzü: kullanıcı onayı olmadan indirme yok, mobil veride varsayılan kapalı ("yalnızca Wi-Fi"), gerçek bayt ilerlemesi, iptal, yetersiz depolama kontrolü, hata durumları. Yalnızca indirme izni olan (lisansı izin veren) içerik için. Yerel müzik zaten cihazda olduğundan indirme gerekmez.
- Çevrimdışıyken yalnızca gerçekten cihazda bulunan içerik "kullanılabilir" gösterilir; diğerleri "çevrimdışı kullanılamaz" olarak işaretlenir.

## 5. Hata durumları (oynatıcı)

`loading`, `error(dosyaBulunamadı | desteklenmiyor | bozuk | ağKesildi)`; hata durumunda kuyruk korunur, otomatik sonraki parçaya geçme ayarlanabilir, sonsuz yükleme yok (zaman aşımı).

## 6. Ücretsizlik denetimi (bu proje için)

| Bileşen | Maliyet | Sınır / not |
|---|---|---|
| Flutter, Dart | Ücretsiz, açık kaynak | — |
| `just_audio`, `audio_service`, `audio_session`, `file_picker`, `connectivity_plus` vb. | Ücretsiz, açık kaynak | Paket lisansları Prompt 2'de `pub` üzerinden doğrulanıp belgelenecek |
| GitHub deposu | Ücretsiz | — |
| GitHub Actions | Ücretsiz kota | Herkese açık depolarda genelde ücretsiz; özel depolarda aylık dakika kotası vardır ve Windows runner dakikaları daha pahalı sayılır. Koşullar değişebilir, sürekli ücretsiz kalacağı **garanti edilemez** |
| Android dağıtımı (APK, GitHub Releases) | Ücretsiz | Google Play ücretlidir (tek seferlik geliştirici hesabı); APK yan yükleme için gerekmez |
| Windows kod imzalama | **Ücretli** | Ücretsiz seçenek: imzasız dağıtım (SmartScreen uyarısı çıkar). İmza kararı sonraya bırakıldı |
| Çevrimiçi katalog | Henüz yok | Eklenirse ücret/lisans gereksinimi geliştirmeden önce belirtilecek |
| Hesap | Gerekmez | Yerel müzik için hesap yok |

Bu aşamada **ücretli hiçbir zorunlu bileşen yok.**

## 7. Test matrisi (hiçbiri henüz çalıştırılmadı)

| # | Senaryo | Nasıl test edilecek | Durum |
|---|---|---|---|
| 1 | Çalarken ana ekrana dönme | Gerçek Android 10 cihaz | Test edilmedi |
| 2 | Ekranı kapatma | Gerçek cihaz | Test edilmedi |
| 3 | Kilitleme | Gerçek cihaz | Test edilmedi |
| 4 | Bildirimden duraklat/oynat | Gerçek cihaz | Test edilmedi |
| 5 | Bildirimden sonraki şarkı | Gerçek cihaz | Test edilmedi |
| 6 | Bluetooth kulaklık | Gerçek cihaz + kulaklık | Test edilmedi |
| 7 | Başka uygulamanın ses başlatması | Gerçek cihaz | Test edilmedi |
| 8 | İnternet kesilmesi | Uçak modu; yerel çalma sürer, ağ kaynağı hata verir | Test edilmedi |
| 9 | Bozuk/desteklenmeyen dosya | Birim test (sahte oynatıcı) + gerçek cihaz | Test edilmedi |
| 10 | Uygulamayı yeniden açma | Gerçek cihaz + widget testi | Test edilmedi |
| 11 | Android 10 izin/arka plan | Gerçek cihaz (Android 10) | Test edilmedi |
| 12 | Düşük bellek | Geliştirici seçenekleri "arka plan işlem sınırı" / emülatör | Test edilmedi |

Otomatik yapılabilecekler (birim/widget): kuyruk, karıştır/tekrar, durum makinesi, hata eşleme. Cihaz gerektirenler (1–7, 11, 12): GitHub Actions bunları yapamaz; APK telefona kurulup elle denenecek ve sonuç buraya yazılacak.
