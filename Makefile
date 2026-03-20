.PHONY: help bootstrap clean get codegen codegen-watch analyze format format-fix test test-coverage check run-dev run-stg run-prod build-android-dev build-ios-dev icons splash version packages outdated upgrade install-hooks git-prune-merged

.DEFAULT_GOAL := help

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

## Setup & Dependencies

bootstrap: ## Bootstrap workspace (install dependencies)
	melos bootstrap

clean: ## Clean build artifacts and dependencies
	melos clean

get: ## Get dependencies for all packages
	melos run get

## Code Generation

codegen: ## Run code generation for all packages
	melos run codegen

codegen-watch: ## Run code generation in watch mode
	melos run codegen:watch

## Quality & Testing

analyze: ## Run static analysis
	melos run analyze

format: ## Check code formatting
	dart format --set-exit-if-changed .

format-fix: ## Fix code formatting
	dart format .

test: ## Run all tests
	melos run test --no-select

test-coverage: ## Run tests with coverage report
	melos run test:coverage --no-select

check: analyze test ## Run analyze + test
	@echo "All checks passed!"

## Build & Run

run-dev: ## Run app in dev flavor
	cd packages/audiflow_app && flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev

run-stg: ## Run app in staging flavor
	cd packages/audiflow_app && flutter run --flavor stg -t lib/main_stg.dart --dart-define-from-file=../../.env.stg

run-prod: ## Run app in production flavor
	cd packages/audiflow_app && flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=../../.env.prod

build-android-dev: ## Build dev AAB
	cd packages/audiflow_app && flutter build appbundle --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev
	open packages/audiflow_app/build/app/outputs/bundle/devRelease/

build-ios-dev: ## Build dev IPA
	cd packages/audiflow_app && flutter build ipa --flavor dev -t lib/main_dev.dart --dart-define-from-file=../../.env.dev

## Assets

icons: ## Generate app icons
	cd packages/audiflow_app && dart run flutter_launcher_icons

splash: ## Generate splash screens
	cd packages/audiflow_app && dart run flutter_native_splash:create

## Utilities

version: ## Show Flutter, Dart, and Melos versions
	@flutter --version
	@dart --version
	@melos --version

packages: ## List workspace packages
	@melos list

outdated: ## Check for outdated packages
	@melos exec -- "flutter pub outdated"

upgrade: ## Upgrade all packages
	@melos exec -- "flutter pub upgrade"

## Git

install-hooks: ## Install git hooks
	@if [ -f .pre-commit-config.yaml ]; then \
		cp .pre-commit-config.yaml .git/hooks/pre-commit && \
		chmod +x .git/hooks/pre-commit && \
		echo "Git hooks installed!"; \
	else \
		echo "Warning: .pre-commit-config.yaml not found, skipping hook install"; \
	fi

git-prune-merged: ## Delete local branches merged into main/develop
	@git fetch --prune
	@git branch --merged | grep -vE '^\*|main|master|develop' | xargs -r git branch -d 2>/dev/null || echo "No merged branches to prune"
