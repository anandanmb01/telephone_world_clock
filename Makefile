.PHONY: help clean build run install all

help:
	@echo "Available targets:"
	@echo "  clean       - Clean Flutter build cache and Android build"
	@echo "  build       - Build Android APK (release)"
	@echo "  build-debug - Build Android APK (debug)"
	@echo "  run         - Run app on connected Android device/emulator"
	@echo "  install     - Install dependencies"
	@echo "  all         - Clean, install dependencies, and run"

clean:
	@echo "Cleaning Flutter build cache..."
	flutter clean
	@echo "Clean complete!"

install:
	@echo "Installing Flutter dependencies..."
	flutter pub get
	@echo "Dependencies installed!"

build:
	@echo "Building Android APK (release)..."
	flutter build apk --release
	@echo "Build complete! APK location: build/app/outputs/flutter-apk/app-release.apk"

build-debug:
	@echo "Building Android APK (debug)..."
	flutter build apk --debug
	@echo "Build complete! APK location: build/app/outputs/flutter-apk/app-debug.apk"

run:
	@echo "Running app on Android device/emulator..."
	flutter run

all: clean install run
	@echo "All done!"
