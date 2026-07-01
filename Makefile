# Foodeez Flutter — Developer shortcuts

PROD_API  = https://int.foodeez.in/restaurant/api/v1
LOCAL_API = http://10.0.2.2:3001/api/v1
API       ?= $(LOCAL_API)

# Install dependencies
get:
	flutter pub get

# Run on Android emulator (dev)
run-android:
	flutter run --dart-define=API_BASE_URL=$(API)

# Run on iOS simulator (dev)
run-ios:
	flutter run -d iPhone --dart-define=API_BASE_URL=http://localhost:3001/api/v1

# Build Android APK (debug)
apk-debug:
	flutter build apk --debug --dart-define=API_BASE_URL=$(API)
	@echo "APK → build/app/outputs/flutter-apk/app-debug.apk"

# Build Android APK (release)
apk-release:
	flutter build apk --release \
		--dart-define=API_BASE_URL=$(PROD_API) \
		--dart-define=PRODUCTION=true \
		--obfuscate \
		--split-debug-info=build/symbols
	@echo "APK → build/app/outputs/flutter-apk/app-release.apk"

# Build Android App Bundle (Play Store)
aab:
	flutter build appbundle --release \
		--dart-define=API_BASE_URL=$(PROD_API) \
		--dart-define=PRODUCTION=true \
		--obfuscate \
		--split-debug-info=build/symbols
	@echo "AAB → build/app/outputs/bundle/release/app-release.aab"

# Build iOS (simulator)
ios-debug:
	flutter build ios --debug --simulator \
		--dart-define=API_BASE_URL=http://localhost:3001/api/v1

# Build iOS (device — requires Apple Developer account)
ios-release:
	flutter build ios --release \
		--dart-define=API_BASE_URL=$(PROD_API) \
		--dart-define=PRODUCTION=true

# Analyze & format
lint:
	flutter analyze
	dart format lib/ --set-exit-if-changed

format:
	dart format lib/

# Clean
clean:
	flutter clean
	cd ios && pod deintegrate || true
	flutter pub get
	cd ios && pod install || true

.PHONY: get run-android run-ios apk-debug apk-release aab ios-debug ios-release lint format clean
