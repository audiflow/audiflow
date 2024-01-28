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

gen_options = \
	--build-filter="lib/**/*.freezed.dart lib/**/*.g.dart"

.PHONY: gen
gen: ## Run Dart's code generator.
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: gen-watch
gen-watch: ## Watch code to kick Dart's code generator.
gen-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs $(gen_options)

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

.PHONY: gen-arb
gen-arb: ## Generate ARB files from Dart code getters
gen-arb:
	dart run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n/L.dart

.PHONY: gen-l10n
gen-l10n: ## Generate Dart code from ARB files
gen-l10n: gen-arb
	dart run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/L.dart lib/l10n/intl_*.arb

.PHONY: format
format: ## Format Dart code.
format:
	@dart format $(shell find . -name "*.dart" -not \( -name "*.*freezed.dart" -o -name "*.*g.dart" -o -path "./lib/l10n/*" \))