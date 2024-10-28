#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
echo cd $CI_PRIMARY_REPOSITORY_PATH
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
FLUTTER_VERSION=$(cat .fvmrc | grep "flutter" | cut -d '"' -f 4)
git clone https://github.com/flutter/flutter.git --depth 1 -b $FLUTTER_VERSION $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin:$HOME/.pub-cache/bin"

HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

flutter --version
flutter precache --ios
flutter pub get

echo flutter build appbundle --config-only --flavor $FLAVOR --dart-define-from-file .env.stg --release
flutter build appbundle --config-only --flavor $FLAVOR --dart-define-from-file .env.stg --release
# cd ios && pod install

exit 0