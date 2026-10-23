#!/usr/bin/env python3
"""Üretilen Android projesini Burakify gereksinimlerine göre yapılandırır.

- minSdk 29 (Android 10 ve üzeri)
- applicationId com.burakify.app
- Uygulama adı "Burakify"
- Release imzalama: android/key.properties varsa release derlemesi onunla imzalanır,
  yoksa Flutter şablonundaki gibi debug anahtarına düşer (yerel deneme için).

Beklenen kalıp bulunamazsa sessizce geçmez, hata verip çıkar; böylece Flutter
şablonu değiştiğinde yanlış yapılandırılmış bir APK üretilmez.
NOT: Bu betik bu ortamda gerçek bir `flutter create` çıktısıyla denenemedi.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP_ID = "com.burakify.app"
MIN_SDK = "29"
APP_LABEL = "Burakify"


def patch(path: pathlib.Path, pattern: str, replacement: str, what: str) -> bool:
    text = path.read_text(encoding="utf-8")
    new_text, count = re.subn(pattern, replacement, text)
    if count == 0:
        print(f"HATA: {path.relative_to(ROOT)} içinde '{what}' kalıbı bulunamadı")
        return False
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")
    print(f"tamam: {what} -> {path.relative_to(ROOT)}")
    return True


KTS_HEAD = """import java.io.FileInputStream
import java.util.Properties

"""
KTS_LOAD = """val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

"""
KTS_SIGNING = """    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

"""
KTS_USE = 'signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")'

GROOVY_LOAD = """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

"""
GROOVY_SIGNING = """    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

"""
GROOVY_USE = "signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug"


def patch_signing(gradle: pathlib.Path) -> bool:
    text = gradle.read_text(encoding="utf-8")
    if "keystoreProperties" in text:
        print(f"tamam: release imzalama zaten ekli -> {gradle.relative_to(ROOT)}")
        return True
    kts = gradle.suffix == ".kts"
    use_pat = r"signingConfig\s*=\s*signingConfigs\.getByName\(\"debug\"\)" if kts else r"signingConfig\s+signingConfigs\.debug"
    if not re.search(r"^android\s*\{", text, re.M) or not re.search(r"^\s*buildTypes\s*\{", text, re.M) or not re.search(use_pat, text):
        print(f"HATA: {gradle.relative_to(ROOT)} içinde imzalama için gereken kalıplar (android {{, buildTypes {{, debug signingConfig) bulunamadı")
        return False
    load = KTS_LOAD if kts else GROOVY_LOAD
    signing = KTS_SIGNING if kts else GROOVY_SIGNING
    use = KTS_USE if kts else GROOVY_USE
    text = re.sub(r"^android\s*\{", lambda m: load + m.group(0), text, count=1, flags=re.M)
    text = re.sub(r"^(\s*)buildTypes\s*\{", lambda m: signing + m.group(0), text, count=1, flags=re.M)
    text = re.sub(use_pat, lambda m: use, text, count=1)
    if kts:
        text = KTS_HEAD + text
    gradle.write_text(text, encoding="utf-8")
    print(f"tamam: release imzalama -> {gradle.relative_to(ROOT)}")
    return True


def main() -> int:
    android = ROOT / "android"
    if not android.is_dir():
        print("android/ klasörü yok, atlandı")
        return 0

    gradle = next(
        (p for p in (android / "app" / "build.gradle.kts", android / "app" / "build.gradle") if p.exists()),
        None,
    )
    manifest = android / "app" / "src" / "main" / "AndroidManifest.xml"
    if gradle is None or not manifest.exists():
        print("HATA: Android gradle dosyası veya AndroidManifest.xml bulunamadı")
        return 1

    ok = True
    # `minSdk = flutter.minSdkVersion` (kts / yeni groovy) veya `minSdkVersion flutter.minSdkVersion`
    ok &= patch(gradle, r"(minSdk(?:Version)?\s*=?\s*)(?:flutter\.minSdkVersion|\d+)", rf"\g<1>{MIN_SDK}", f"minSdk {MIN_SDK}")
    ok &= patch(gradle, r'(applicationId\s*=?\s*)"[^"]*"', rf'\g<1>"{APP_ID}"', f"applicationId {APP_ID}")
    ok &= patch(manifest, r'(android:label=")[^"]*(")', rf"\g<1>{APP_LABEL}\g<2>", f"uygulama adı {APP_LABEL}")
    ok &= patch_signing(gradle)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
