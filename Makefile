.PHONY: help bootstrap clean get codegen codegen-watch analyze test test-coverage format check build-dev build-stg build-prod run-dev run-stg run-prod icons splash

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
	@echo "  make build-dev        - Build dev APK"
	@echo "  make build-stg        - Build staging APK"
	@echo "  make build-prod       - Build production release APK"
	@echo ""
	@echo "Assets:"
	@echo "  make icons            - Generate app icons"
	@echo "  make splash           - Generate splash screens"

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
	cd packages/audiflow_app && flutter run --flavor dev -t lib/main_dev.dart

run-stg:
	@echo "Running staging flavor..."
	cd packages/audiflow_app && flutter run --flavor stg -t lib/main_stg.dart

run-prod:
	@echo "Running production flavor..."
	cd packages/audiflow_app && flutter run --flavor prod -t lib/main_prod.dart

build-dev:
	@echo "Building dev APK..."
	cd packages/audiflow_app && flutter build apk --flavor dev -t lib/main_dev.dart

build-stg:
	@echo "Building staging APK..."
	cd packages/audiflow_app && flutter build apk --flavor stg -t lib/main_stg.dart

build-prod:
	@echo "Building production release APK..."
	cd packages/audiflow_app && flutter build apk --flavor prod -t lib/main_prod.dart --release

# Assets
icons:
	@echo "Generating app icons..."
	cd packages/audiflow_app && dart run flutter_launcher_icons

splash:
	@echo "Generating splash screens..."
	cd packages/audiflow_app && dart run flutter_native_splash:create

# iOS specific
build-ios-dev:
	@echo "Building iOS dev..."
	cd packages/audiflow_app && flutter build ios --flavor dev -t lib/main_dev.dart --no-codesign

build-ios-prod:
	@echo "Building iOS production..."
	cd packages/audiflow_app && flutter build ios --flavor prod -t lib/main_prod.dart --release

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

# Git hooks
install-hooks:
	@echo "Installing git hooks..."
	@cp .pre-commit-config.yaml .git/hooks/pre-commit || true
	@chmod +x .git/hooks/pre-commit || true
	@echo "Git hooks installed!"
