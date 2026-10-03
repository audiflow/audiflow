# Release notes

User-facing "What's New" text for the App Store and Google Play, one folder per
released app version and one subfolder per store.

```
release-notes/<version>/ios/en-US.txt       # App Store
release-notes/<version>/ios/ja-JP.txt
release-notes/<version>/android/en-US.txt   # Google Play
release-notes/<version>/android/ja-JP.txt
```

- `<version>` is the version users see (`version:` in
  `packages/audiflow_app/pubspec.yaml` without the `+build` suffix, e.g. `2.0.1`).
- File names are the store locale codes, so the text can be pasted, or later
  uploaded, as is.
- Each file is plain text. Google Play allows 500 characters per language, the
  App Store 4000.
- The two platforms share most lines; keep platform-only changes (for example
  iOS background downloads, Android notification icons) in that platform's
  files only.

## Writing a new entry

1. List the changes since the previous user release:
   `git log --no-merges --format='%h %s' v<previous>..HEAD`.
2. Keep only what users notice (features and fixes); leave out build, CI,
   analytics, and other internal work.
3. Describe the effect for the listener, not the implementation, and claim only
   what the change actually does.
4. Write both languages with the same content for each platform and check the
   length:
   `python3 -c "print(len(open('release-notes/<version>/android/en-US.txt').read().rstrip()))"`.
