.PHONY: help bootstrap clean get codegen codegen-watch analyze test test-coverage format check build-android-dev build-android-stg build-android-prod build-ios-dev build-ios-stg build-ios-prod upload-ios-stg upload-ios-prod run-dev run-stg run-prod icons splash git-prune-merged

# Default target
help:
	@echo "Audiflow Development Commands"
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make bootstrap        - Bootstrap workspace (install dependencies)"
	@echo "  make clean            - Clean build artifacts and dependencies"
	@echo "  make get              - Get dependencies for all packages"
	@echo ""
	@echo "Code Generation:"
	@echo "  make codegen          - Run code generation for all packages"
	@echo "  make codegen-watch    - Run code generation in watch mode"
	@echo ""
	@echo "Quality & Testing:"
	@echo "  make analyze          - Run static analysis"
	@echo "  make format           - Format code"
	@echo "  make test             - Run all tests"
	@echo "  make test-coverage    - Run tests with coverage report"
	@echo "  make check            - Run analyze + format check + test"
	@echo ""
	@echo "Build & Run:"
	@echo "  make run-dev          - Run app in dev flavor"
	@echo "  make run-stg          - Run app in staging flavor"
	@echo "  make run-prod         - Run app in production flavor"
	@echo ""
	@echo "Android:"
	@echo "  make build-android-dev  - Build dev AAB"
	@echo "  make build-android-stg  - Build staging AAB"
	@echo "  make build-android-prod - Build production release AAB"
	@echo ""
	@echo "iOS:"
	@echo "  make build-ios-dev    - Build dev IPA"
	@echo "  make build-ios-stg    - Build staging IPA"
	@echo "  make build-ios-prod   - Build production IPA"
	@echo "  make upload-ios-stg   - Build + upload staging to TestFlight"
	@echo "  make upload-ios-prod  - Build + upload production to TestFlight"
	@echo ""
	@echo "Assets:"
	@echo "  make icons            - Generate app icons"
	@echo "  make splash           - Generate splash screens"
	@echo ""
	@echo "Git:"
	@echo "  make git-prune-merged - Delete local branches merged into main/develop"

# Setup & Dependencies
bootstrap:
	@echo "Bootstrapping workspace..."
	melos bootstrap

clean:
	@echo "Cleaning workspace..."
	melos clean

get:
	@echo "Getting dependencies..."
	melos run get

# Code Generation
codegen:
	@echo "Running code generation..."
	melos run codegen

codegen-watch:
	@echo "Running code generation in watch mode..."
	melos run codegen:watch

# Quality & Testing
analyze:
	@echo "Running static analysis..."
	melos run analyze

format:
	@echo "Formatting code..."
	dart format --set-exit-if-changed .

format-fix:
	@echo "Fixing code formatting..."
	dart format .

test:
	@echo "Running tests..."
	melos run test --no-select

test-coverage:
	@echo "Running tests with coverage..."
	melos run test:coverage --no-select

check: analyze test
	@echo "All checks passed!"

# Build & Run
run-dev:
	@echo "Running dev flavor..."
	cd packages/audiflow_app && flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev

run-stg:
	@echo "Running staging flavor..."
	cd packages/audiflow_app && flutter run --flavor stg -t lib/main_stg.dart --dart-define-from-file=../../.env.stg

run-prod:
	@echo "Running production flavor..."
	cd packages/audiflow_app && flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=../../.env.prod

# Android
build-android-dev:
	@echo "Building dev AAB..."
	cd packages/audiflow_app && flutter build appbundle --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev
	open packages/audiflow_app/build/app/outputs/bundle/devRelease/

build-android-stg:
	@echo "Building staging AAB..."
	cd packages/audiflow_app && flutter build appbundle --flavor stg -t lib/main_stg.dart --dart-define-from-file=../../.env.stg
	open packages/audiflow_app/build/app/outputs/bundle/stgRelease/

build-android-prod:
	@echo "Building production release AAB..."
	cd packages/audiflow_app && flutter build appbundle --flavor prod -t lib/main_prod.dart --release --dart-define-from-file=../../.env.prod
	open packages/audiflow_app/build/app/outputs/bundle/prodRelease/

# Assets
icons:
	@echo "Generating app icons..."
	cd packages/audiflow_app && dart run flutter_launcher_icons

splash:
	@echo "Generating splash screens..."
	cd packages/audiflow_app && dart run flutter_native_splash:create

# iOS
build-ios-dev:
	@echo "Building iOS dev IPA..."
	cd packages/audiflow_app && flutter build ipa --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev

build-ios-stg:
	@echo "Building iOS staging IPA..."
	cd packages/audiflow_app && flutter build ipa --flavor stg -t lib/main_stg.dart --dart-define-from-file=../../.env.stg

build-ios-prod:
	@echo "Building iOS production IPA..."
	cd packages/audiflow_app && flutter build ipa --flavor prod -t lib/main_prod.dart --dart-define-from-file=../../.env.prod

upload-ios-stg: build-ios-stg
	@echo "Uploading staging IPA to TestFlight..."
	xcrun altool --upload-app --type ios \
		-f packages/audiflow_app/build/ios/ipa/*.ipa \
		--apiKey $(APP_STORE_CONNECT_KEY_ID) \
		--apiIssuer $(APP_STORE_CONNECT_ISSUER_ID)

upload-ios-prod: build-ios-prod
	@echo "Uploading production IPA to TestFlight..."
	xcrun altool --upload-app --type ios \
		-f packages/audiflow_app/build/ios/ipa/*.ipa \
		--apiKey $(APP_STORE_CONNECT_KEY_ID) \
		--apiIssuer $(APP_STORE_CONNECT_ISSUER_ID)

# Utilities
version:
	@echo "Flutter version:"
	@flutter --version
	@echo ""
	@echo "Dart version:"
	@dart --version
	@echo ""
	@echo "Melos version:"
	@melos --version

packages:
	@echo "Workspace packages:"
	@melos list

outdated:
	@echo "Checking for outdated packages..."
	@melos exec -- "flutter pub outdated"

upgrade:
	@echo "Upgrading packages..."
	@melos exec -- "flutter pub upgrade"

# Git
install-hooks:
	@echo "Installing git hooks..."
	@cp .pre-commit-config.yaml .git/hooks/pre-commit || true
	@chmod +x .git/hooks/pre-commit || true
	@echo "Git hooks installed!"

git-prune-merged:
	@echo "Pruning merged branches..."
	@git fetch --prune
	@git branch --merged | grep -vE '^\*|main|master|develop' | xargs -r git branch -d 2>/dev/null || echo "No merged branches to prune"
	@echo "Done!"
