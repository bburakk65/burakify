# 07 — Güncelleme Mimarisi

## Android akışı

1. **Sürüm bilgisi:** GitHub Releases `latest` (veya `update.json`) çekilir; zaman aşımı + hata yolu var.
2. **Karşılaştırma:** `package_info_plus` mevcut sürüm ile semver + build numarası karşılaştırılır.
3. **Notlar:** Release gövdesi (metin olarak, HTML çalıştırılmadan) gösterilir.
4. **İndirme:** Yalnızca kullanıcı "İndir"e basarsa. İlerleme gerçek bayt oranından.
5. **Bütünlük:** Release'teki SHA-256 ile indirilen dosyanın özeti karşılaştırılır; uyuşmazsa dosya silinir, hata gösterilir.
6. **Kurulum:** Android paket yükleyici (`ACTION_VIEW`/PackageInstaller + `FileProvider`) başlatılır. Sessiz kurulum **yoktur**; sistem onay ekranı çıkar.
7. **İzin:** Android 8+ için "bilinmeyen uygulamaları yükle" izni uygulama için gerekir; izin yoksa açıklama + ayarlara yönlendirme.
8. **İptal/başarısızlık:** indirme iptali, ağ kopması, yetersiz depolama, doğrulama hatası, kullanıcının kurulumu reddetmesi ayrı durumlardır; her biri mesaj + tekrar dene.

Önkoşullar: aynı `applicationId`, aynı imza anahtarı, artan `versionCode`.

Güvenlik notu: SHA-256 aynı yerden geliyorsa tek başına tam güvence değildir; asıl koruma Android'in imza uyumu kontrolüdür (farklı anahtarla imzalı APK mevcut uygulamanın üzerine kurulmaz). Ek olarak yalnızca HTTPS kullanılır.

## Durum makinesi

`idle → checking → upToDate | available → downloading → verifying → readyToInstall → installing`; her durumdan `failed(reason)` ve `cancelled`.

## Windows (ayrı tasarım)

Başlangıç: yeni sürüm bildirimi + Release sayfasına/ZIP'e yönlendirme. Sonra: MSIX ile Windows'un kendi güncelleme mekanizması veya Inno Setup ile indirilen kurulum dosyasının doğrulanıp çalıştırılması. Android kodundan bağımsız (`platform/windows`).
