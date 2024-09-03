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
	@flutter pub run flutter_launcher_icons

.PHONY: build-aab
build-aab: ## Build appbundle
build-aab:
	@flutter build appbundle
