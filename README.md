# CodeHero: Python & C++ Mastery

An interactive, gamified mobile app (Flutter) for learning **Python** and
**C++** — from Junior to Middle+ — with lessons, a live code sandbox, energy,
XP, a skill tree, daily quests, crafting, leagues, and monetization.

> **Status:** early build. The runnable foundation is in place — clean dark UI,
> multi-language (en/ru), local auth, player economy (XP/energy/crystals), and a
> **working code Sandbox** that executes Python/C++ via the Piston API. Lessons,
> skill tree, quests, crafting, leagues and store are being added step by step
> (see `docs/architecture.md`).

## Quick start

This repo contains the Flutter **source** (`lib/`, `pubspec.yaml`, assets). The
platform folders (`android/`, `ios/`) are generated locally so no secrets are
committed. From a machine with the Flutter SDK installed:

```bash
# 1. Generate the Android/iOS runner projects (leaves lib/ and pubspec untouched)
flutter create --platforms=android,ios --org com.codehero .

# 2. Fetch dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run
```

The app starts in **Local mode** — fully usable without any Firebase setup.
You can sign in (guest/email/Google/Apple all work locally), browse the
dashboard, pick a track, and run real Python/C++ in the Sandbox.

### Build a release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Requirements

- Flutter SDK **>= 3.22** (Dart >= 3.4)
- Android Studio / Xcode toolchains for the target platform

## Enabling Firebase (optional, later)

Local mode needs no config. To turn on real cloud sync, auth and (eventually)
leagues:

```bash
dart pub global activate flutterfire_cli
flutterfire configure          # generates lib/firebase_options.dart
```

Then initialize Firebase in `main.dart` (a commented hook is already there).
Note: server-side features (secure XP, weekly leagues, IAP receipt validation)
require **Cloud Functions**, which need the **Blaze** plan — the code is
structured so these swap in without touching the UI. See `docs/architecture.md`.

## Documentation

- `docs/architecture.md` — stack, folder layout, the Local-mode ⇄ server seam,
  and the feature roadmap.
- `docs/firestore_schema.md` — the read-minimizing Firestore data model.
- `docs/firebase_enablement.md` — step-by-step guide to turning on Firebase,
  Cloud Functions, AdMob and IAP (`functions/` holds the server code).
- `CLAUDE.md` — guidance for AI assistants working in this repo.

## Code execution

Code runs through the public **Piston** API (`emkc.org`). The
`CodeExecutionService` interface (`lib/features/code_execution/`) is backend-
agnostic, so it can be repointed at a Cloud Functions proxy or self-hosted
Judge0 later without changing callers.
