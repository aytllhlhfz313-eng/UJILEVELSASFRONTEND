#!/usr/bin/env bash
# Build Flutter web di lingkungan Netlify.
# Alamat backend dibaca dari variabel env API_BASE_URL yang diisi di dashboard Netlify.
set -e

VERSION="${FLUTTER_VERSION:-3.44.7}"
SDK_DIR="$HOME/flutter-sdk"

if [ ! -d "$SDK_DIR" ]; then
  echo "Mengunduh Flutter $VERSION ..."
  git clone https://github.com/flutter/flutter.git -b "$VERSION" --depth 1 "$SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"
flutter --version
flutter config --enable-web
flutter pub get

if [ -z "$API_BASE_URL" ]; then
  echo "PERINGATAN: API_BASE_URL belum diisi. Build memakai http://localhost:5000 dan aplikasi tidak akan tersambung ke backend." >&2
fi

flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL:-http://localhost:5000}"
