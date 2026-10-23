# 05 — Müzik Oynatma ve Yasal Kullanım

## Oynatma yaklaşımı

- `PlayerService` soyut arayüzü (`core/audio`): `play`, `pause`, `seek`, `next`, `previous`, kuyruk, tekrar/karıştır, durum akışı (`idle/loading/ready/playing/paused/error`).
- Uygulama: `just_audio` (ses) + `audio_service` (Android foreground servis, kilit ekranı/bildirim kontrolleri, Bluetooth/kulaklık tuşları).
- Android 10: medya bildirimi ve foreground servis manifest bildirimleri Prompt 2/3'te eklenir.
- Windows: medya tuşları ve sistem medya denetimi için `platform/windows` uygulaması (Prompt 7'de doğrulanır).

## İlk sürümde kullanılacak kaynaklar (yasal)

1. **Kullanıcının kendi seçtiği yerel ses dosyaları** (cihazdaki mp3/flac/m4a); dosya seçici ile.
2. **Lisansı açık örnek parçalar** (CC0 / kamu malı / kendi üretimimiz). Her parça için lisans ve kaynak `assets/audio_samples/LICENSES.md` içinde yazılır. Lisansı doğrulanmamış hiçbir dosya projeye eklenmez.

## Çevrimiçi katalog (ileride, ayrı karar)

Gerçek katalog yayın hakkı ister. Seçenekler ve gereksinimler:

| Seçenek | Not |
|---|---|
| Lisanslı akış sağlayıcı API'leri | Genellikle geliştirici sözleşmesi, platforma özel oynatıcı SDK'sı ve kullanım koşulları gerekir; bazıları yalnızca önizleme sunar |
| Serbest lisanslı kataloglar (ör. CC lisanslı müzik arşivleri) | Ücretsiz olabilir; her parçanın lisans koşulu (atıf, ticari kullanım) izlenmeli |
| Kendi içeriğini yükleyen sanatçılar | Hak sahibi onayı ve içerik politikası gerekir |

Maliyet ve koşullar sağlayıcıya göre değişir; seçilmeden önce güncel koşullar kontrol edilmelidir. Sağlayıcı seçimi **Prompt 1 kapsamında yapılmadı**.

## Yapılmayacaklar

Yetkisiz katalog kopyalama, DRM/telif korumasını aşma, kaynağı belirsiz dosya dağıtma.
