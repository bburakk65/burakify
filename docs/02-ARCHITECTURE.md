# 02 — Uygulama Mimarisi

## Katmanlar (bağımlılık yönü: yukarıdan aşağıya)

```
features/*      Ekranlar ve ekrana özel durum (home, library, player, search, settings)
   │
core/design     Tasarım sistemi (token + bileşen)      core/animation  Merkezi hareket
   │
core/audio      Oynatma mantığı (arayüz + uygulama)    core/data       Yerel veri/ayarlar
core/network    HTTP istemcisi                         core/errors     Hata modeli
core/update     Sürüm kontrol/indirme/doğrulama mantığı
   │
platform/*      Android ve Windows'a özel uygulamalar (soyut arayüzlerin somutları)
```

Kural: `core` hiçbir zaman `features`'a; ortak kod hiçbir zaman `platform/*`'a doğrudan bağımlı olmaz.

## Klasör yapısı

```
burakify/
├─ lib/
│  ├─ main.dart
│  ├─ app/                 Uygulama kabuğu, rota, tema seçimi
│  ├─ core/
│  │  ├─ design/           Renkler, tipografi, boşluk, bileşenler
│  │  ├─ animation/        Süreler, eğriler, azaltılmış hareket politikası
│  │  ├─ audio/            PlayerService arayüzü, kuyruk, durumlar
│  │  ├─ data/             Ayarlar, favoriler, yerel kütüphane deposu
│  │  ├─ network/          HTTP sarmalayıcı, zaman aşımı, yeniden deneme
│  │  ├─ errors/           AppError türleri, kullanıcıya gösterilecek mesajlar
│  │  └─ update/           UpdateChecker, sürüm karşılaştırma, SHA-256 doğrulama
│  ├─ features/            home, library, player, search, settings
│  └─ platform/
│     ├─ android/          APK kurulum köprüsü, MediaSession entegrasyonu
│     └─ windows/          Windows güncelleyici, medya tuşları
├─ test/                   Birim ve widget testleri
├─ assets/                 audio_samples, fonts, images
├─ docs/                   Bu dokümanlar
├─ tool/                   Yardımcı betikler (sürüm, hash)
└─ .github/workflows/      ci.yml, release-android.yml, release-windows.yml
```

`android/` ve `windows/` klasörleri `flutter create` ile üretilir (Prompt 2); bu ortamda Flutter yok, bu yüzden henüz oluşturulmadı.

## Telefon / tablet / Windows ayrımı

| Cihaz | Düzen | Gezinme |
|---|---|---|
| Telefon (< 600 dp) | Tek sütun | Alt gezinme çubuğu + mini oynatıcı |
| Tablet (600–1024 dp) | İki bölmeli (liste + detay) | Gezinme rayı (rail) |
| Windows / geniş (> 1024 dp) | Yan menü + içerik + sağ kuyruk paneli | Yan menü, klavye kısayolları, medya tuşları |

Ayrım `LayoutBuilder` kırılma noktaları ile yapılır; cihaz türüne değil genişliğe bakılır.

## Hata yönetimi

Tek `AppError` hiyerarşisi (ağ, dosya, ses, güncelleme, bilinmeyen). Her hata kullanıcıya anlaşılır mesaj + "tekrar dene" eylemi taşır. Sessizce yutulan hata yok.

## Telefon ve bilgisayar ayrımı (geliştirici tarafı)

| Telefonla yapılabilir | Bilgisayar/bulut gerektirir |
|---|---|
| Kod/doküman düzenleme (GitHub web/mobil, kod düzenleyici) | `flutter analyze/test` yerel çalıştırma |
| GitHub Actions'ı tetikleme, APK indirme (Actions artifact/Release) | APK'yı yerelde derleme |
| APK'yı telefona kurma ve deneme | Windows paketini derleme/deneme (GitHub Actions yapabilir, çalıştırmak için Windows PC gerekir) |
| Sürüm notu yazma, etiket (tag) atma | Hata ayıklama (debugger) |
