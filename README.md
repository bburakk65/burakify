# Burakify

Özgün, modern bir müzik çalar platformu. Hedefler: Android telefon, Android tablet ve Windows PC.

> **Durum (Prompt 2):** Temel uygulama, Ana Sayfa/arama/ayarlar, tablet ve Windows düzenleri ve CI kodu yazıldı, ancak **derlenmedi ve Flutter testleri çalıştırılmadı** (bu ortamda Flutter SDK indirilemedi). Ayrıntı: [docs/12-PROMPT-2-RAPOR.md](docs/12-PROMPT-2-RAPOR.md).

## Teknoloji

Flutter (Dart) + `just_audio` (arka plan çalma için `audio_service` sonraki aşamada eklenecek). Gerekçe: [docs/01-TECH-DECISION.md](docs/01-TECH-DECISION.md)

## Dokümanlar

| Doküman | İçerik |
|---|---|
| [01-TECH-DECISION](docs/01-TECH-DECISION.md) | Teknoloji karşılaştırması ve seçim |
| [02-ARCHITECTURE](docs/02-ARCHITECTURE.md) | Katmanlar, klasör yapısı, platform ayrımı |
| [03-DESIGN-SYSTEM](docs/03-DESIGN-SYSTEM.md) | Renk, tipografi, bileşenler, düzenler |
| [04-ANIMATION-PLAN](docs/04-ANIMATION-PLAN.md) | 11 animasyon başlığı ve kuralları |
| [05-MUSIC-AND-LEGAL](docs/05-MUSIC-AND-LEGAL.md) | Ses oynatma ve lisans yaklaşımı |
| [06-CI-RELEASE](docs/06-CI-RELEASE.md) | GitHub Actions, sürümleme, imzalama |
| [07-UPDATE-ARCHITECTURE](docs/07-UPDATE-ARCHITECTURE.md) | Android ve Windows güncelleme tasarımı |
| [08-TEST-AND-FIX](docs/08-TEST-AND-FIX.md) | Test listesi ve hata düzeltme protokolü |
| [09-PROMPT-2-TASKS](docs/09-PROMPT-2-TASKS.md) | İkinci aşama görev listesi |
| [11-TABLET-WINDOWS](docs/11-TABLET-WINDOWS.md) | Tablet ve Windows arayüzleri: düzenler, kısayollar, durum ve eksikler |
| [12-PROMPT-2-RAPOR](docs/12-PROMPT-2-RAPOR.md) | Prompt 2 raporu: yapılanlar, doğrulananlar, riskler, sonraki adımlar |
| [10-PLAYBACK-ANDROID-REQUIREMENTS](docs/10-PLAYBACK-ANDROID-REQUIREMENTS.md) | Arka plan çalma, bildirim/kilit ekranı, izinler, ücretsizlik, test matrisi |

## Derleme

Gereksinimler: Flutter (stable). Android için JDK 17 ve Android SDK; Windows için Windows 10+ ve Visual Studio 2022 ("Desktop development with C++").

```bash
bash tool/prepare_platforms.sh     # android/ ve windows/ klasörlerini üretir, minSdk 29 ve uygulama kimliğini ayarlar
flutter pub get
flutter analyze
flutter test
flutter run                         # bağlı cihaz/emülatör veya Windows
flutter build apk --release         # Android sürüm APK'sı (android/key.properties varsa imzalı)
flutter build windows --release     # yalnızca Windows'ta
```

**Telefondan geliştirme:** Kodu GitHub'a yükleyin; **CI** iş akışı test eder ve sürüm APK'sı üretir: `burakify-v0.1.0+1.apk` (Actions → çalıştırma → Artifacts → `burakify-v…-imzali`). İmza için GitHub Secrets gerekir: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`; tanımlı değilse artifact adı `…-gecici-anahtar` olur. Ayrıntı: [docs/12-PROMPT-2-RAPOR.md](docs/12-PROMPT-2-RAPOR.md).

## Gizli bilgiler

Anahtarlar kaynak koda girmez. `.env.example` yalnızca örnektir; imzalama sırları GitHub Secrets'ta tutulur.
