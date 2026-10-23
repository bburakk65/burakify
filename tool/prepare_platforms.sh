#!/usr/bin/env bash
# android/ ve windows/ klasörlerini (yoksa) `flutter create` ile üretir ve
# Burakify ayarlarını uygular. CI'da ve yerelde aynı şekilde çalışır.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d android ] || [ ! -d windows ]; then
  backup="$(mktemp -d)"
  # `flutter create` mevcut dosyaları değiştirmemeli, ama güvence için yedekle.
  cp lib/main.dart "$backup/main.dart"
  flutter create . --platforms=android,windows --org com.burakify --project-name burakify
  cp "$backup/main.dart" lib/main.dart
  # Şablonun ürettiği örnek test bu projenin sınıflarını bilmez; kaldır.
  rm -f test/widget_test.dart
fi

PY="$(command -v python3 || command -v python)"
"$PY" tool/configure_platforms.py
