# Release notes

User-facing "What's New" text for the App Store and Google Play, one folder per
released app version.

```
release-notes/<version>/en-US.txt
release-notes/<version>/ja-JP.txt
```

- `<version>` is the version users see (`version:` in
  `packages/audiflow_app/pubspec.yaml` without the `+build` suffix, e.g. `2.0.1`).
- File names are the store locale codes, so the text can be pasted, or later
  uploaded, as is.
- Each file is plain text, at most 500 characters (the Google Play limit; the
  App Store allows 4000), so one text works for both stores.

## Writing a new entry

1. List the changes since the previous user release:
   `git log --no-merges --format='%h %s' v<previous>..HEAD`.
2. Keep only what users notice (features and fixes); leave out build, CI,
   analytics, and other internal work.
3. Describe the effect for the listener, not the implementation, and claim only
   what the change actually does.
4. Write both languages with the same content and check the length:
   `python3 -c "print(len(open('release-notes/<version>/en-US.txt').read().rstrip()))"`.
