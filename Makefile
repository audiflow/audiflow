.PHONY: help build run

help: ## Show this help message.
	@echo 'usage: make [target] ...'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

list-merged: ## List merged branches
list-merged:
	git remote prune origin --dry-run
	git branch --merged | grep -vE '^\*|master$$|main$$|develop$$' || true

rm-merged: ## Remove merged branches
rm-merged: list-merged confirm
	git remote prune origin
	git branch --merged | grep -vE '^\*|master$$|main$$|develop$$' | xargs -I % git branch -d %

confirm:
	@read -p "Proceed? [y/N] " ans && [ $${ans:-N} = y ]

.PHONY: gen
gen: ## Run Dart's code generator.
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: gen-watch
gen-watch: ## Watch code to kick Dart's code generator.
gen-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

.PHONY: gen-test
gen-test: ## Run Dart's code generator under /test dir.
gen-test:
	flutter pub run build_runner build --delete-conflicting-outputs \
		--build-filter="test/*.dart" \
		--build-filter="test/**/*.dart"

.PHONY: gen-clean
gen-clean: ## Clean cache of Dart's code generator.
gen-clean:
	flutter pub run build_runner clean

.PHONY: gen-loc
gen-loc: ## Generate l10n Dart code from ARB files
gen-loc:
	flutter gen-l10n

.PHONY: format
format: ## Format Dart code.
format:
	@dart format $(shell find . -name "*.dart" -not \( -name "*.*freezed.dart" -o -name "*.*g.dart" -o -path "./lib/localization/*" \))

.PHONY: icon
icon: ## Generate app icons.
icon:
	@dart run flutter_flavorizr -p android:icons -p ios:icons
	# @flutter pub run flutter_launcher_icons

.PHONY: splash
splash: ## Generate app splash screen.
splash:
	@flutter pub run flutter_native_splash:create

.PHONY: build-aab
build-aab: ## Build appbundle
build-aab:
	@flutter build appbundle

.PHONY: ios-dev
ios-dev: ## Build iOS ipa for development
ios-dev:
	@flutter build ipa --flavor dev --dart-define-from-file .env.dev \
	--debug

.PHONY: ios-stg
ios-stg: ## Build iOS ipa for staging
ios-stg:
	@flutter build ipa --flavor stg --dart-define-from-file .env.stg \
	--source-maps

.PHONY: ios-prod
ios-prod: ## Build iOS ipa for production
ios-prod:
	@flutter build ipa --flavor prod --dart-define-from-file .env.prod \
	--source-maps

.PHONY: and-dev
and-dev: ## Build Android App Bundle for development
and-dev:
	@flutter build appbundle --flavor dev --dart-define-from-file .env.dev \
	--debug

.PHONY: and-stg
and-stg: ## Build Android App Bundle for staging
and-stg:
	@flutter build appbundle --flavor stg --dart-define-from-file .env.stg \
	--source-maps

.PHONY: and-prod
and-prod: ## Build Android App Bundle for production
and-prod:
	@flutter build appbundle --flavor prod --dart-define-from-file .env.prod \
	--source-maps
