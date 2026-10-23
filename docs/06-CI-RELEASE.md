# 06 — GitHub, Otomatik Derleme ve Sürümleme

## Depo durumu

Bu ortamda GitHub erişimi **çalışmıyor** (ortamdaki token geçersiz). Depo oluşturulmadı, hiçbir şey yüklenmedi. Kullanıcı GitHub'da boş bir depo açıp dosyaları yükleyecek (Prompt 2'de adım adım anlatılacak).

## İş akışları (`.github/workflows/`)

| Dosya | Tetik | İş |
|---|---|---|
| `ci.yml` | push / pull request | `flutter pub get`, `flutter analyze`, `flutter test` |
| `release-android.yml` | `v*` etiketi | İmzalı APK derle, SHA-256 üret, GitHub Release'e yükle |
| `release-windows.yml` | `v*` etiketi | Windows derlemesi, ZIP paketi, SHA-256, Release'e yükle |

Not: Bu iş akışları yazıldı ancak bu ortamda **çalıştırılmadı**; ilk gerçek çalıştırma depo kurulunca olacak. Flutter sürümü `FLUTTER_VERSION` ile sabitlenir; Prompt 2'de güncel kararlı sürüme göre doğrulanır.

## Sürüm numaralandırma

`MAJOR.MINOR.PATCH+BUILD` (ör. `0.1.0+1`). Etiket `v0.1.0`. `BUILD` her sürümde artar (Android `versionCode`); aksi halde güncelleme kurulamaz.

## APK imzalama

- Tek bir yükleme (upload) anahtarı oluşturulur; **aynı anahtar her sürümde kullanılır** (aksi halde Android güncellemeyi reddeder).
- Keystore **depoya girmez**. GitHub Secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
- Keystore'un güvenli yedeği kullanıcıda tutulmalı; kaybı = mevcut kurulumlara güncelleme verilememesi.
- Uygulama kimliği (applicationId) sabit: `com.burakify.app` (Prompt 2'de doğrulanıp sabitlenecek).

## Windows paketleme

Taşınabilir ZIP (ilk adım), sonra MSIX veya Inno Setup kurulumu. Windows kod imzalama sertifikası ücretlidir; olmadan SmartScreen uyarısı çıkar. Bu, Prompt 10'da karar verilecek bir maliyet kalemidir.
