# 04 — Animasyon Planı

Tüm süre ve eğriler `lib/core/animation/` içinde merkezi tutulur (`BurakifyMotion`). Ekranlar süreyi doğrudan yazmaz.

## Merkezi politika

`MotionPolicy` üç mod üretir: **full**, **reduced**, **minimal**.
- `reduced`: sistem "animasyonları kaldır / azalt" ayarı (`MediaQuery.disableAnimations`) veya kullanıcı ayarı açıkken; hareket yerine kısa solma (≤100 ms).
- `minimal`: düşük donanım. Başlangıç sezgisi: kare süresi sürekli 16 ms'yi aşarsa otomatik düşür; kullanıcı ayarından elle de seçilebilir. Eşikler gerçek cihazda ölçülerek Prompt 10'da belirlenecek.

## Animasyon listesi

| # | Animasyon | Tasarım | Kurallar |
|---|---|---|---|
| 1 | Logo/açılış | Logo çizgisi çizilir, amber ışık dolar (~900 ms) | Sahte yükleme yok; gerçek başlatma bitince kapanır |
| 2 | İlk / sonraki açılış | İlk açılış: tam sürüm. Sonraki: ≤300 ms kısa logo solması. Bayrak `SharedPreferences`'ta | Uzun açılış her seferinde gösterilmez |
| 3 | Ekran geçişi | Yatay kayma + solma (250–300 ms); Windows'ta yalnız solma | Reduced'da yalnız solma |
| 4 | Albüm kapağı → çalma ekranı | Hero geçişi (kapak boyut/konum eşleşir) | Kapak yoksa yer tutucu da Hero olur |
| 5 | Mini → tam oynatıcı | Sürüklenebilir panel (aşağı/yukarı), yay eğrisi | Jest + tıklama ile; erişilebilir düğme alternatifi |
| 6 | Favori / düğme | Kalp ölçek + dolgu (180 ms), düğme basılı ölçek 0.96 | Haptik yalnız destekleyen cihazda |
| 7 | İskelet yükleme | Hafif parıltı (shimmer) | **En çok 10 sn**; sonra hata durumu + "tekrar dene". Sonsuz yükleme yok |
| 8 | İndirme/güncelleme ilerlemesi | Çubuk, değer **gerçek bayt oranından** | Toplam bilinmiyorsa belirsiz (indeterminate) göster, yüzde uydurma |
| 9 | Hata/başarı bildirimi | Alttan kayan çubuk, 4 sn; hata kalıcı eylemli | Ekran okuyucuya duyurulur |
| 10 | Azaltılmış hareket | Yukarıdaki politika | Her animasyon `MotionPolicy` sorar |
| 11 | Düşük donanım | Gölge/blur/parçacık kapatılır, süre kısalır | Müzik çalma performansı animasyondan önceliklidir |

## Kural özeti

- Gerçek işlem olmadan yüzde gösterilmez.
- Her yükleme için zaman aşımı + hata yolu bulunur.
- Animasyon ses çalmayı asla bloke etmez (ses ayrı servis).
