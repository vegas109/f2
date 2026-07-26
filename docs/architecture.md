# CodeHero — Architecture

## Stack

- **Flutter (Dart)** — Android + iOS.
- **Riverpod** — state management (classic providers; no codegen, for build
  reliability).
- **go_router** — declarative, auth-gated routing.
- **Firebase** (Auth, Firestore) — optional; the app runs in **Local mode**
  until `flutterfire configure` is run.
- **Piston API** — remote code execution for the Sandbox and code lessons.
- **Hive / SharedPreferences** — offline lesson content and cached progress.

## Feature-first folder layout

```
lib/
  app.dart                     # MaterialApp.router + localization wiring
  main.dart                    # bootstrap (prefs, Firebase later), ProviderScope
  core/
    constants/                 # tunable economy + API constants
    router/                    # go_router + auth redirect
    theme/                     # colors, ThemeData, code text style
    utils/                     # Result<T>, helpers
    widgets/                   # shared UI (StatPill, ...)
  features/
    auth/          {domain, application, presentation}
    code_execution/{domain, application}        # Piston service (swappable)
    sandbox/       {application, presentation}
    player/        {domain, application}         # XP / energy / crystals
    home/          {presentation}                # Learn dashboard
    leagues/       {presentation}                # weekly leagues (stub)
    profile/       {presentation}
    shell/         {presentation}                # bottom-nav host
  l10n/                        # ARB translations (en, ru, ...)
```

Each feature is split into `domain` (models), `application` (controllers /
services / providers) and `presentation` (widgets). This keeps UI free of
business logic and makes the "swap Local mode → Firebase / server" migration a
matter of replacing `application` implementations.

## The Local-mode ⇄ Server seam

Firebase Spark (the free plan) has **no Cloud Functions**, so anything that
must be trusted (XP anti-cheat, weekly league matchmaking, IAP receipt
validation) cannot run securely yet. The architecture isolates these behind
interfaces so the move to Blaze is a drop-in:

| Concern            | Interface                 | Local mode (now)          | Server mode (Blaze)              |
| ------------------ | ------------------------- | ------------------------- | -------------------------------- |
| Code execution     | `CodeExecutionService`    | public Piston, direct     | Cloud Functions proxy / Judge0   |
| Auth               | `AuthController`          | SharedPreferences user    | FirebaseAuth (Google/Apple/email)|
| Progress/economy   | `PlayerController`        | SharedPreferences         | Firestore + callable functions   |
| Leagues/MMR        | `LeagueService` (planned) | mocked leaderboard        | scheduled Cloud Functions        |
| Purchases          | `PurchaseValidator` (planned) | client-trusted        | server receipt validation        |

Only the `application` layer changes; `presentation` and `domain` stay put.

## Roadmap (build order)

1. ✅ Foundation: theme, routing, i18n, local auth, player economy, **working
   Sandbox** (Piston), dashboard.
2. ✅ Curriculum engine: theory cards, fill-in-the-blank, sandbox lessons,
   drag-and-drop constructor; XP rewards + energy loss on mistakes.
3. ✅ Skill tree (gated module progression) + ✅ boss fights (timed, no hints).
4. ✅ Daily quests + streaks.
5. ✅ Crafting (part drops → skins/avatars).
6. ✅ Monetization: crystal IAP + 3 subscription tiers (in_app_purchase);
   rewarded-ad crystals (demo impl — real AdMob deferred).
7. ✅ Leagues: client-side 30-player XP board (mock).
8. 🟨 Firebase enablement — **server scaffolding written** (`functions/`,
   `firestore.rules`, `firestore.indexes.json`) with a step-by-step guide in
   `docs/firebase_enablement.md`; the Flutter-side swap (auth/economy) is the
   remaining work and requires the Blaze plan.
9. ✅ Onboarding + ✅ cosmetics equipping. ⬜ Remaining polish: real AdMob ads,
   wiring the client to the callables.
