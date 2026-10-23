# 03 — Tasarım Sistemi

Özgün kimlik: başka bir müzik platformunun logosu, renkleri veya ekran düzeni kopyalanmaz. Burakify "gece ışığı" fikrine dayanır: derin lacivert yüzeyler ve sıcak amber vurgu.

## Renk token'ları (başlangıç; Prompt 2'de kodlanır)

| Token | Koyu tema | Açık tema |
|---|---|---|
| `surface` | `#0E1020` | `#F7F6F3` |
| `surfaceRaised` | `#171A2E` | `#FFFFFF` |
| `onSurface` | `#ECEAF4` | `#17182A` |
| `onSurfaceMuted` | `#A5A3B8` | `#5C5B70` |
| `accent` | `#FFB547` (amber) | `#A35F00` |
| `accentSecondary` | `#6C7BFF` | `#4350D6` |
| `success` / `error` / `warning` | `#4ADE80` / `#FF6B6B` / `#FFC857` | `#1E8E4A` / `#C62828` / `#9A6B00` |

Kontrast hedefi: gövde metni en az 4.5:1 (WCAG AA); Prompt 2'de kod içinde test edilecek.

## Tipografi

Başlık: Sora veya Outfit; gövde: Inter. (Yazı tipi dosyaları asset olarak eklenecek; lisansları açık-kaynak OFL.) Ölçek: 12 / 14 / 16 / 20 / 28 / 40. Sistem yazı boyutu ayarı desteklenir (ölçekleme 2.0'a kadar taşmasız).

## İkonlar

Tek aile kullanılır (Material Symbols Rounded); kalınlık ve boyut sabit (24 dp, 2 dp çizgi). Karışık ikon setleri yok.

## Bileşenler

Kart (albüm/çalma listesi), birincil/ikincil/metin düğmeleri, liste satırı (parça), gezinme (alt çubuk / rail / yan menü), mini oynatıcı, ilerleme çubuğu, **boş durum**, **hata durumu** (mesaj + tekrar dene), **iskelet yükleme**, bildirim çubuğu (başarı/hata).

## Düzenler

Telefon, tablet ve Windows için `02-ARCHITECTURE.md`'deki kırılma noktaları.

## Erişilebilirlik

- Dokunma hedefi en az 48×48 dp.
- Tüm ikon düğmelerinde `Semantics` etiketi.
- Renk tek başına bilgi taşımaz.
- Azaltılmış hareket (bkz. 04).
- Klavye odağı Windows'ta görünür.
