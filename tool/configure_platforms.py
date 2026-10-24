#!/usr/bin/env python3
"""Üretilen Android projesini Burakify gereksinimlerine göre yapılandırır.

- minSdk 29 (Android 10 ve üzeri)
- applicationId com.burakify.app
- Uygulama adı "Burakify"
- Eklentilerin compileSdk değeri en az 36 olur (flutter_plugin_android_lifecycle
  gibi bağımlılıklar bunu istiyor; eski eklentiler 34 ile derleniyor ve APK derlemesi kırılıyor)
- Arka plan çalma (audio_service / just_audio_background): manifest izinleri, servis,
  medya düğmesi alıcısı ve MainActivity'nin AudioServiceActivity'den türemesi
- Release imzalama: android/key.properties varsa release derlemesi onunla imzalanır,
  yoksa Flutter şablonundaki gibi debug anahtarına düşer (yerel deneme için).

Beklenen kalıp bulunamazsa sessizce geçmez, hata verip çıkar; böylece Flutter
şablonu değiştiğinde yanlış yapılandırılmış bir APK üretilmez.
NOT: Bu betik bu ortamda gerçek bir `flutter create` çıktısıyla denenemedi.
"""
import pathlib
import re
import sys

# Windows'ta varsayılan konsol kodlaması (cp1252) Türkçe karakterleri yazamaz
# ve betiği çökertir; çıktıyı her zaman UTF-8 yap.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass

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


COMPILE_SDK = 36

KTS_COMPILE = """// Burakify: eklentileri en az compileSdk 36 ile derle (tool/configure_platforms.py ekledi).
// evaluationDependsOn'dan ÖNCE durmalı, yoksa afterEvaluate hata verir.
subprojects {
    afterEvaluate {
        if (project.name != "app") {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                androidExt.javaClass.methods
                    .firstOrNull { it.name == "setCompileSdkVersion" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Int::class.javaPrimitiveType }
                    ?.invoke(androidExt, 36)
            }
        }
    }
}

"""
GROOVY_COMPILE = """// Burakify: eklentileri en az compileSdk 36 ile derle (tool/configure_platforms.py ekledi).
subprojects {
    afterEvaluate { p ->
        if (p.name != "app" && p.hasProperty("android")) {
            p.android.compileSdkVersion 36
        }
    }
}

"""


def patch_compile_sdk(android: pathlib.Path) -> bool:
    root_gradle = next(
        (p for p in (android / "build.gradle.kts", android / "build.gradle") if p.exists()),
        None,
    )
    if root_gradle is None:
        print("HATA: android/build.gradle(.kts) bulunamadı")
        return False
    text = root_gradle.read_text(encoding="utf-8")
    if "Burakify: eklentileri en az compileSdk" in text:
        print(f"tamam: compileSdk {COMPILE_SDK} zaten ekli -> {root_gradle.relative_to(ROOT)}")
        return True
    block = KTS_COMPILE if root_gradle.suffix == ".kts" else GROOVY_COMPILE
    m = re.search(r"^allprojects\s*\{", text, re.M)
    pos = m.start() if m else 0
    root_gradle.write_text(text[:pos] + block + text[pos:], encoding="utf-8")
    print(f"tamam: eklentiler için compileSdk {COMPILE_SDK} -> {root_gradle.relative_to(ROOT)}")
    return True


AUDIO_PERMISSIONS = (
    "android.permission.INTERNET",
    "android.permission.WAKE_LOCK",
    "android.permission.FOREGROUND_SERVICE",
    "android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK",
)

AUDIO_COMPONENTS = """        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true" tools:ignore="Instantiatable">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true" tools:ignore="Instantiatable">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
"""


def patch_audio_manifest(manifest: pathlib.Path) -> bool:
    text = manifest.read_text(encoding="utf-8")
    rel = manifest.relative_to(ROOT)
    if "com.ryanheise.audioservice.AudioService" in text:
        print(f"tamam: arka plan çalma manifest ayarı zaten ekli -> {rel}")
        return True
    if not re.search(r"<manifest\b[^>]*>", text) or "</application>" not in text:
        print(f"HATA: {rel} içinde <manifest ...> veya </application> bulunamadı")
        return False
    if "xmlns:tools=" not in text:
        text = re.sub(
            r"<manifest\b",
            '<manifest xmlns:tools="http://schemas.android.com/tools"',
            text,
            count=1,
        )
    perms = "".join(
        f'    <uses-permission android:name="{p}" />\n'
        for p in AUDIO_PERMISSIONS
        if f'android:name="{p}"' not in text
    )
    # İzinler <application> etiketinden önce gelir.
    text = re.sub(r"^(\s*)<application\b", lambda m: perms + m.group(0), text, count=1, flags=re.M)
    text = text.replace("</application>", AUDIO_COMPONENTS + "    </application>", 1)
    manifest.write_text(text, encoding="utf-8")
    print(f"tamam: arka plan çalma izinleri, servis ve alıcı -> {rel}")
    return True


def patch_main_activity(android: pathlib.Path) -> bool:
    src = android / "app" / "src" / "main"
    candidates = [p for p in list(src.rglob("MainActivity.kt")) + list(src.rglob("MainActivity.java"))]
    if not candidates:
        print("HATA: android/app/src/main altında MainActivity bulunamadı")
        return False
    activity = candidates[0]
    text = activity.read_text(encoding="utf-8")
    rel = activity.relative_to(ROOT)
    if "AudioServiceActivity" in text:
        print(f"tamam: MainActivity zaten AudioServiceActivity -> {rel}")
        return True
    if "FlutterActivity" not in text:
        print(f"HATA: {rel} içinde FlutterActivity bulunamadı")
        return False
    text = text.replace(
        "io.flutter.embedding.android.FlutterActivity",
        "com.ryanheise.audioservice.AudioServiceActivity",
    )
    text = text.replace("FlutterActivity", "AudioServiceActivity")
    activity.write_text(text, encoding="utf-8")
    print(f"tamam: MainActivity AudioServiceActivity'den türüyor -> {rel}")
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
    ok &= patch_compile_sdk(android)
    ok &= patch_audio_manifest(manifest)
    ok &= patch_main_activity(android)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
