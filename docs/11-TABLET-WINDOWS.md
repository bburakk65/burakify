# 11 — Tablet ve Windows Arayüzleri

**Doğrulama durumu: HİÇBİR kod bu ortamda derlenmedi veya test edilmedi.** Flutter SDK'nın Dart bileşeni indirilemedi (ağ izni yok). Yazılan testler çalıştırılmadı; ilk gerçek doğrulama GitHub Actions `ci.yml` veya Flutter kurulu bir bilgisayarda olacak.

## Düzen seçimi (`lib/app/layout/form_factor.dart`)

| Platform | Genişlik | Düzen |
|---|---|---|
| Android | < 600 dp | Telefon: alt gezinme çubuğu + mini oynatıcı + tam ekran oynatıcı sayfası |
| Android | ≥ 600 dp | **Tablet**: sol gezinme rayı + içerik; < 900 dp mini oynatıcı, ≥ 900 dp sağda kalıcı "çalıyor" paneli |
| Windows | < 720 px | Kompakt (telefon düzeni, pencere küçülünce) |
| Windows | ≥ 720 px | **Masaüstü**: sol yan menü + içerik + alt oynatıcı çubuğu |
| Windows | ≥ 1100 px | Ek olarak sağ kuyruk paneli (Ctrl+Q ile aç/kapat); daha darsa kuyruk çekmece olarak açılır |

Android'de çok geniş tablet bile masaüstü düzenine geçmez; ayrım genişliğe ve platforma birlikte bakar. Seçili sekme ve panel durumu, yön/boyut değişse de `AdaptiveShell` içinde korunur. Bölünmüş ekran, pencere genişliğine göre aynı mantıkla telefon düzenine düşer.

## Özellikler ve durumları

| Özellik | Durum |
|---|---|
| Tablet gezinme rayı, çok sütunlu kitaplık ızgarası (genişliğe göre sütun sayısı) | Yazıldı, test edilmedi |
| Tablet yatay/dikey geçiş, sağ "çalıyor" paneli | Yazıldı, test edilmedi |
| Mini → tam oynatıcı geçişi (alttan yükselme + solma; azaltılmış harekette yalnızca kısa solma) | Yazıldı, test edilmedi |
| Windows yan menü, merkez içerik, sağ kuyruk paneli, alt oynatıcı çubuğu | Yazıldı, test edilmedi |
| Klavye: Boşluk, Ctrl+→/←, Ctrl+O, Ctrl+Q (tablet klavyesinde de çalışır) | Yazıldı, test edilmedi |
| Windows dosya seçici (Ctrl+O / düğme) ve sürükle-bırak (`desktop_drop`) | Yazıldı; sürükle-bırak için otomatik test yok, elle denenmeli |
| Gerçek ses (`just_audio`), kuyruk, karıştır, tekrar, ses seviyesi (Windows çubuğu) | Yazıldı, test edilmedi |
| Pencere küçültülünce çalmanın sürmesi | Ses uygulama sürecinde çalar, pencere durumuna bağlı değildir; **Windows'ta denenmedi** |
| Dokunma, fare ve klavye odağı | Standart Material bileşenleri kullanıldı; elle denenmedi |

## Henüz YOK (dürüst liste)

- **Windows sistem medya kontrolleri** (medya tuşları, ses paneli/SMTC): eklenmedi. Plan: SMTC destekleyen bir paket (ör. `smtc_windows`) değerlendirilecek, lisansı ve sürümü doğrulanacak.
- **Android arka plan çalma, bildirim, kilit ekranı:** eklenmedi (`audio_service` ayrı aşama, bkz. docs/10).
- **Albüm / sanatçı / çalma listesi ekranları:** eklenmedi. Dosya etiketleri (albüm, sanatçı, kapak) okunmuyor; kitaplık yalnızca "şarkılar". Etiket okuma paketi seçilince eklenecek.
- **Kalıcı kitaplık:** liste bellekte tutulur, uygulama kapanınca kaybolur.
- **Kuyruk sürükle-sırala, klasör bırakma:** yok (klasörler atlanır).
- **Hero (paylaşılan öğe) kapak geçişi:** kullanılmadı; aynı ağaçta çift Hero çakışması riski nedeniyle yalnızca sayfa geçişi var.
- **Çalışan müzik oynatma özelliği "korunacak" denmişti:** Prompt 1'de hiç oynatıcı kodu yoktu; bu aşamada ilk kez yazıldı.

## Bilinen sınırlamalar

- Boşluk tuşu, odaktaki düğmeyi "etkinleştirmek" yerine oynat/duraklat yapar.
- `just_audio_windows` ve `desktop_drop` sürüm aralıkları geniş bırakıldı; `pub get` sonrası sabitlenmeli.
- `ci.yml`: biçim denetimi geçici olarak bilgilendirme amaçlı, `flutter analyze` `info` düzeyini engellemez.

## Windows paketi, sürüm ve güncelleme (plan)

- **Paket:** ilk aşamada taşınabilir ZIP (`release-windows.yml` bunu üretir, SHA-256 ile). Sonra MSIX veya Inno Setup kurulum dosyası. Windows paketi Android APK'sı ile karıştırılmaz.
- **Sürüm:** `pubspec.yaml` `MAJOR.MINOR.PATCH+BUILD`; etiket `vX.Y.Z` hem APK hem Windows sürümünü tetikler.
- **Güncelleme akışı:** GitHub Releases'ten sürüm bilgisi → mevcut sürümle karşılaştır → notları göster → kullanıcı onayıyla indir → SHA-256 doğrula → ZIP için kullanıcıya klasörü değiştirme/yeniden başlatma yönergesi, kurulum paketi için doğrulanmış kurulumu başlat. Sessiz arka plan güncellemesi yok. Windows güncellemesi Android akışından ayrı (`platform/windows`).
- **İmza:** kod imzalama sertifikası ücretlidir; imzasız dağıtımda SmartScreen uyarısı çıkar (ücretsiz seçenek bu).

## Elle test listesi (Windows PC ve Android tablet gerekir)

1. Tablet dikey → yatay: sağ panel görünür/kaybolur, sekme korunur.
2. Tablet bölünmüş ekran: dar pencerede telefon düzeni.
3. Tablet klavye/fare: Boşluk, Ctrl+O, tekerlek kaydırma.
4. Windows: pencereyi küçült/büyüt (720 / 1100 px eşikleri), Ctrl+Q, kuyruk çekmecesi.
5. Windows: dosya seç, dosya sürükle-bırak (mp3, txt karışık), klasör bırak.
6. Windows: çalarken pencereyi küçült → ses sürmeli.
7. Bozuk ses dosyası → hata mesajı, uygulama çökmemeli.
