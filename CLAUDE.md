# CLAUDE.md

Guidance for AI assistants (Claude Code and others) working in this repository.

## What this project is

**CodeHero: Python & C++ Mastery** — a gamified Flutter (Dart) mobile app for
learning Python and C++, targeting **Android and iOS**. It combines lesson
formats (theory cards, fill-in-the-blank, visual code constructor, live
sandbox) with retention mechanics (energy/hearts, XP/levels, a non-linear
skill tree, boss fights, daily quests, crafting, weekly leagues) and
monetization (crystal IAP, subscription tiers, rewarded ads).

The app runs in **Local mode by default** (SharedPreferences-backed), so it
builds and runs with **no Firebase configuration**. Firebase (Auth, Firestore)
and server-side logic are layered in later behind interfaces.

## Current state

A full gameplay loop is implemented and runnable in Local mode:

- Clean, minimal dark design system (`lib/core/theme/`) + i18n (`lib/l10n/`,
  `en` + `ru`) + `go_router` auth redirect.
- Local auth and player economy (XP/level/energy/crystals/streak).
- **Working code Sandbox** (Piston) — `features/sandbox`, `features/code_execution`.
- **Lesson engine** (`features/curriculum`, `features/lesson`): four formats —
  theory cards, fill-in-the-blank, sandbox lessons, and a drag-and-drop code
  **constructor**; awards XP, deducts energy on mistakes; **boss** lessons are
  timed with hints hidden.
- **Skill tree** with gated module progression (`features/skilltree`).
- **Daily quests** + streaks (`features/quests`).
- **Crafting** — parts drop from lessons → cosmetics (`features/crafting`).
- **Store** — crystal packs + 3 subscription tiers via `in_app_purchase`, plus
  a rewarded-ad crystal path (demo impl) (`features/store`).
- **Leagues** — 30-player XP leaderboard (client-side mock).

Not yet built (see `docs/architecture.md`): Firebase/Cloud Functions
enablement (real cloud sync, server-validated XP, real matchmaking + weekly
reset, IAP receipt validation), more curriculum content, and real AdMob ads.

**Deferred dependencies (deliberate):** `firebase_*`, `google_sign_in`,
`sign_in_with_apple`, and `google_mobile_ads` are NOT in `pubspec.yaml` yet.
They are unused in Local mode and add native build friction (or, for ads, crash
at launch without an AdMob App ID). `flutterfire configure` adds the Firebase
ones at enablement; add ads when wiring real `RewardedAdService`.

## Toolchain & commands

Requires the **Flutter SDK ≥ 3.22 (Dart ≥ 3.4)**. The `android/` and `ios/`
folders are **not committed** (generated locally, keeps secrets out of git).

| Purpose            | Command                                                        |
| ------------------ | ------------------------------------------------------------- |
| Generate platforms | `flutter create --platforms=android,ios --org com.codehero .` |
| Install deps       | `flutter pub get`                                             |
| Run                | `flutter run`                                                 |
| Analyze / lint     | `flutter analyze`                                             |
| Format             | `dart format .`                                               |
| Test               | `flutter test`                                                |
| Build APK          | `flutter build apk --release`                                 |

l10n code is generated automatically on build (config in `l10n.yaml`).

> **No Flutter SDK is available in this cloud session.** Code here is written
> by hand and cannot be compiled/tested in-session — be extra careful with
> Dart syntax, imports, and null-safety, and prefer patterns that don't rely
> on code generation.

## Architecture conventions

- **Feature-first**: `lib/features/<feature>/{domain,application,presentation}`.
  - `domain` = plain models (hand-written `copyWith`/`toJson`, no codegen).
  - `application` = Riverpod controllers/services + providers.
  - `presentation` = widgets only; no business logic.
- **State**: Riverpod, **classic providers (no `riverpod_generator`)** —
  chosen for build reliability in an environment without codegen. Keep it that
  way unless the maintainer opts into codegen.
- **Models**: hand-written immutable classes with `copyWith`/`toJson`/
  `fromJson`. Avoid `freezed`/`json_serializable` for the same reason.
- **The Local-mode ⇄ server seam**: anything that must be trusted or run on a
  server (secure XP, leagues/MMR, IAP validation, a code-exec proxy) sits
  behind an interface with a Local implementation now. Migrating to Firebase
  Blaze / Cloud Functions should only replace `application`-layer classes —
  never `presentation` or `domain`. Preserve this boundary.
- **Currency/economy mutations** funnel through `PlayerController` so they can
  later be moved server-side without touching callers.
- **Balance/economy numbers** live in `lib/core/constants/app_constants.dart`.
- **Strings** shown to users go through ARB localization, not hard-coded
  literals (add keys to every `app_*.arb`).

## Git workflow

- Default/integration branch is **`main`**. Never push directly to `main`
  unless explicitly asked.
- Feature work on `claude/`-prefixed kebab-case branches; push with
  `git push -u origin <branch>`.
- Imperative commit messages ("Add sandbox screen").
- Do **not** open a pull request unless explicitly requested.
- If a branch's PR was already merged, restart from latest `main`
  (`git fetch origin main && git checkout -B <branch> origin/main`) rather than
  stacking onto merged history.

## Notes for AI assistants

- Verify actual contents (`git ls-files`) before acting; keep this file honest
  as features land.
- Keep changes minimal and scoped to what's asked.
- When adding a feature, update `docs/architecture.md` (roadmap) and, if it
  touches data, `docs/firestore_schema.md`.
- Don't commit `android/`, `ios/`, `google-services.json`,
  `GoogleService-Info.plist`, or `lib/firebase_options.dart` (already
  `.gitignore`d).
