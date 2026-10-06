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
- File names are the store locale codes, so the text can be used as is: the
  production deploy workflow uploads the Android notes with the draft Play
  release (reading them from `main`), and the iOS notes are pasted into App
  Store Connect.
- Each file is plain text. Google Play allows 500 characters per language, the
  App Store 4000.
- The two platforms share most lines; keep platform-only changes (for example
  iOS background downloads, Android notification icons) in that platform's
  files only.

## Writing a new entry

1. List the changes since the previous user release. Release tags carry the
   build number (e.g. `v2.0.0+51`), so look up the full tag of the release users
   last received, then put it in place of `<previous-tag>`:
   ```bash
   git tag -l 'v*' --sort=-creatordate | head -5
   git log --no-merges --format='%h %s' <previous-tag>..HEAD
   ```
2. Keep only what users notice (features and fixes); leave out build, CI,
   analytics, and other internal work.
3. Describe the effect for the listener, not the implementation, and claim only
   what the change actually does.
4. Write both languages with the same content for each platform, then check
   every file against its store's limit (replace `2.0.1` with the version):
   ```bash
   python3 - 2.0.1 <<'EOF'
   import pathlib, sys
   limits = {'android': 500, 'ios': 4000}
   for f in sorted(pathlib.Path('release-notes', sys.argv[1]).glob('*/*.txt')):
       n = len(f.read_text().rstrip())
       print(f, n, 'OK' if n <= limits[f.parent.name] else 'TOO LONG')
   EOF
   ```

The production build that ships these notes is described in
`docs/development/release-build.md`.
