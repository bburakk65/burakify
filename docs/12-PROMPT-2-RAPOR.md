# 12 — Prompt 2 Raporu

**Önce en önemli bilgi:** Bu ortamda Flutter/Dart SDK'sı çalıştırılamadı (indirme sunucuları, pub.dev, npm ve PyPI erişimi kapalı). Bu yüzden `flutter pub get`, `flutter analyze`, `flutter test` ve `flutter build` **hiç çalıştırılmadı**. Aşağıdaki "doğrulananlar" yalnızca gerçekten çalıştırılan kontrollerdir.

## Uygulamanın şu an yapabildikleri (kod olarak yazıldı, çalıştırılmadı)

- Açılış: ayarları okur; okurken yükleme, hata/8 sn zaman aşımında "Tekrar dene" gösterir.
- Varsayılan koyu tema; Ayarlar'dan Koyu / Açık / Sistem seçilir ve kalıcı kaydedilir. Kayıt başarısız olursa kullanıcıya bildirilir.
- Ana Sayfa: logo alanı, başlık, arama alanı (kitaplıktaki dosyaların başlığında gerçekten arar), "çevrimiçi katalog bağlı değil" bilgisi, yerel müzik kartları, boş ve "sonuç bulunamadı" durumları.
- Kitaplık, Kuyruk, Ayarlar sekmeleri; telefonda alt gezinme, tablette ray, Windows'ta yan menü. Android geri tuşu Ana Sayfa dışındaki sekmeden Ana Sayfa'ya döner.
- Yerel müzik dosyası ekleme (dosya seçici; Windows'ta sürükle-bırak), gerçek ses oynatma kodu (`just_audio`), kuyruk, karıştır, tekrar, mini ve tam oynatıcı.
- Hata yönetimi: `AppError`, hassas veriyi (dosya yolu, token/parola) gizleyen `AppLog`.

## Henüz yok

- Gerçek çevrimiçi katalog (sahte katalog yapılmadı; arayüz bunu açıkça söylüyor).
- Android arka plan çalma, medya bildirimi, kilit ekranı kontrolleri; Windows medya tuşları (`audio_service` ve ilgili Android manifest ayarları sonraki aşama).
- Açılış animasyonu, albüm/sanatçı/çalma listesi ekranları, kalıcı kitaplık, güncelleme sistemi, imzalı sürüm APK'sı (anahtar henüz yok).
- `android/` ve `windows/` klasörleri: `flutter create` olmadan üretilemedi; CI'da `tool/prepare_platforms.sh` üretir.

## Bağımlılıklar

| Paket | Neden | Not |
|---|---|---|
| `just_audio` ^0.9.40 | Ses oynatma | Android ve Windows |
| `just_audio_windows` | `just_audio`'nun Windows eklentisi | Kodda import edilmez, yalnızca Windows'ta gerekir |
| `file_picker` ^8.0.0 | Yerel müzik seçme | Depolama izni gerekmez |
| `desktop_drop` | Windows sürükle-bırak | Yalnızca Windows düzeninde kullanılır |
| `shared_preferences` ^2.2.3 | Tema ayarı | |
| `flutter_lints` (dev) | Analiz kuralları | |

**Sürümler doğrulanamadı:** pub.dev'e erişilemediği için bu sürüm aralıklarının var olduğunu ve birbiriyle uyumlu çözümlendiğini bu ortamda doğrulayamadım. İlk `flutter pub get` çıktısına göre düzeltilecek; üretilen `pubspec.lock` depoya eklenmeli.

**Kaldırılanlar (kodda kullanılmıyordu):** `audio_service`, `audio_session`, `connectivity_plus`, `path_provider`, `go_router`, `flutter_riverpod`, `http`, `package_info_plus`, `crypto`. İlgili aşamalarda geri eklenecek. `test/project_consistency_test.dart`, pubspec'teki her paketin kodda kullanıldığını denetler.

Hepsi ücretsiz ve açık kaynaktır; ücretli servis gerekmez.

## Gereksinimler

- **Android APK:** Flutter (stable), JDK 17, Android SDK (CI'da hazır gelir; yerelde Android Studio). `minSdk` 29 (Android 10) — `tool/configure_platforms.py` uygular.
- **Windows:** Windows 10 veya üstü, Visual Studio 2022 ve "Desktop development with C++" iş yükü, Flutter (stable). Windows derlemesi bir Windows bilgisayarda veya GitHub Actions `windows-latest` üzerinde yapılır; Android APK'sından ayrı bir iş (`build-windows`).

## Gerçekten çalıştırılan kontroller ve sonuçları

| Kontrol | Sonuç |
|---|---|
| 3 iş akışı + `pubspec.yaml` + `analysis_options.yaml` YAML ayrıştırma | Geçti |
| `tool/configure_platforms.py` sözdizimi (`py_compile`) | Geçti |
| `tool/prepare_platforms.sh` sözdizimi (`bash -n`) | Geçti |
| `configure_platforms.py`, benim yazdığım örnek `.kts` ve Groovy Gradle dosyalarında | minSdk 29, applicationId, uygulama adı doğru yazıldı; ikinci çalıştırma değişiklik yapmadı; kalıp yoksa hata kodu 1 verdi. **Gerçek `flutter create` çıktısıyla denenmedi.** |
| Yapısal Dart denetimi (52 dosya): parantez dengesi, import çözümleme, kullanılmayan import, testlerin aradığı anahtarların kodda varlığı | Gerçek sorun yok (4 yanlış alarm: dosya adından türeyen test metinleri, elle doğrulandı). Bu **derleyici değildir**; tür hataları yakalamaz. |
| `flutter analyze`, `flutter test`, `flutter build apk`, `flutter build windows` | **Çalıştırılamadı** |

## Yazım sırasında bulunan ve düzeltilen hatalar

| Hata | Kök neden | Düzeltme |
|---|---|---|
| Kullanılmayan import (`library_page.dart`, `bootstrap.dart`) | Kod taşınırken kalmış | Kaldırıldı (analiz uyarısı olurdu) |
| `shell_test.dart`'ta eksik ve gereksiz import | Test yeniden yazılırken | Düzeltildi |
| Eski `shell_test.dart` yeni gezinmeyle uyumsuz | 4 sekmeli yeni kabuk | Yeniden yazıldı |
| `pubspec.yaml`'da 9 kullanılmayan paket | Prompt 1 planlamasından kalma | Kaldırıldı, tutarlılık testi eklendi |
| `flutter create` şablon testi (`widget_test.dart`) projede olmayan `MyApp`'i çağırırdı | Şablon davranışı | `prepare_platforms.sh` siler ve `main.dart`'ı yedekten geri koyar |

## Bilinen riskler (CI ilk çalışınca ortaya çıkabilir)

- Derlenmemiş kodda tür/API hataları olması olası; ilk CI çıktısına göre düzeltilecek.
- `tool/configure_platforms.py` gerçek Flutter şablonuyla ilk kez CI'da çalışacak; kalıp bulunamazsa iş bilerek kırmızı olur.
- Windows'ta kısayol testleri (Boşluk, Ctrl+Q) odak davranışına bağlı; kırılırsa test değil odak yönetimi düzeltilecek.
- Windows alt çubuğu 720–800 px aralığında sıkışabilir (taşma olabilir); gerçek pencerede denenmedi.
- Biçim denetimi (`dart format`) geçici olarak bilgilendirme amaçlı; kod hiç biçimlendirilmedi.

## Telefondan yapabileceğiniz işlemler

1. GitHub uygulaması veya tarayıcıyla boş bir depo açın, bu proje dosyalarını yükleyin (web arayüzünde "Add file → Upload files").
2. Actions sekmesinde **CI** iş akışının sonucuna bakın; kırmızıysa hata çıktısını bana yapıştırın, düzelteyim.
3. Önce 4 GitHub Secret tanımlayın (Settings → Secrets and variables → Actions): `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
4. Yeşil olursa çalıştırmanın "Artifacts" bölümünden `burakify-v0.1.0+1-imzali` dosyasını indirin; içindeki `burakify-v0.1.0+1.apk` telefona kurulur (debug APK değil, sürüm APK'sıdır; bilinmeyen kaynaklardan kuruluma izin gerekir).

**Güncelleme:** `pubspec.yaml` sürümünü artırıp `vX.Y.Z` etiketi atınca release-android.yml aynı anahtarla imzalar; aynı anahtar ve `com.burakify.app` sayesinde yeni APK eskisinin üstüne güncelleme olarak kurulur. Etiket pubspec sürümüyle uyuşmazsa iş bilerek durur.

**Doğrulananlar (bu ortamda):** imzalama yaması örnek `.kts` ve Groovy Gradle dosyalarında doğru çalıştı, ikinci çalıştırma değişiklik yapmadı; iş akışı YAML'ları geçerli; keystore `keytool` ile üretildi. **Doğrulanamayanlar:** gerçek `flutter create` Gradle çıktısına uyum ve gerçek imzalı APK derlemesi (CI'da ilk çalışınca görülecek).

## Prompt 3 için hazır olanlar ve engeller

- Hazır: oynatma/arayüz ayrımı (`PlayerService`, `PlayerController`, `PlaybackStatus`), hata ve günlük altyapısı, ayar deposu, adaptif kabuk, CI iskeleti.
- Engeller: Flutter doğrulaması (depo + Actions gerekli), `audio_service` ve manifest ayarları için gerçek `android/` klasörü, gerçek Android 10 cihaz testi.
