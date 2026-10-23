import 'package:flutter/foundation.dart';

/// Arayüz düzeni sınıfı. Telefon, tablet ve masaüstü ayrı düzenler kullanır.
enum FormFactor { phone, tablet, desktop }

/// Android'de bu genişlikten itibaren tablet düzeni.
const double kTabletMinWidth = 600;

/// Masaüstü işletim sistemlerinde bu genişliğin altı kompakt (telefon) düzen.
const double kDesktopMinWidth = 720;

/// Tablette bu genişlikten itibaren sağda kalıcı "çalıyor" paneli.
const double kTabletSidePaneMinWidth = 900;

/// Masaüstünde bu genişlikten itibaren sağ kuyruk paneli gösterilebilir.
const double kQueuePanelMinWidth = 1100;

bool isDesktopPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.windows ||
    platform == TargetPlatform.linux ||
    platform == TargetPlatform.macOS;

/// Genişlik ve platforma göre düzen sınıfını seçer.
///
/// Masaüstü işletim sistemi: [kDesktopMinWidth] ve üstü -> desktop, altı -> phone.
/// Diğer platformlar: [kTabletMinWidth] ve üstü -> tablet, altı -> phone.
FormFactor formFactorFor({
  required double width,
  required TargetPlatform platform,
}) {
  if (isDesktopPlatform(platform)) {
    return width >= kDesktopMinWidth ? FormFactor.desktop : FormFactor.phone;
  }
  return width >= kTabletMinWidth ? FormFactor.tablet : FormFactor.phone;
}
