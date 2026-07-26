# Enabling Firebase, Cloud Functions, AdMob & IAP

The app runs fully in **Local mode** with none of this. Follow these steps when
you're ready to add cloud sync, server-validated economy, real ads and
validated purchases. The client is structured so each step swaps an
`application`-layer implementation without touching `presentation`/`domain`.

## 0. Prerequisites

- A Firebase project.
- **Cloud Functions require the Blaze (pay-as-you-go) plan.** Firestore/Auth
  work on Spark, but the secure XP, league reset and purchase validation in
  `functions/` need Blaze.
- Node 20 + the Firebase CLI: `npm i -g firebase-tools && firebase login`.

## 1. Add Firebase to the Flutter app

```bash
dart pub global activate flutterfire_cli
flutterfire configure         # select your project + android/ios
```

This adds `firebase_core`/`firebase_auth`/`cloud_firestore` to `pubspec.yaml`,
writes `lib/firebase_options.dart`, and drops the native config files
(`google-services.json`, `GoogleService-Info.plist`). All are gitignored.

Initialize in `lib/main.dart` (a hook is already there):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// inside main(), before runApp:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 2. Swap local auth for FirebaseAuth

Replace the sign-in methods in
`lib/features/auth/application/auth_controller.dart`. Keep the same `AuthState`
so the router and UI are unchanged. Add `google_sign_in` and
`sign_in_with_apple` (Apple sign-in is required for iOS App Store if you offer
Google). Sketch:

```dart
Future<void> signInWithGoogle() async {
  final gUser = await GoogleSignIn().signIn();
  final gAuth = await gUser!.authentication;
  final cred = GoogleAuthProvider.credential(
    idToken: gAuth.idToken, accessToken: gAuth.accessToken);
  final result = await FirebaseAuth.instance.signInWithCredential(cred);
  // map result.user -> AppUser and set state
}
```

Listen to `FirebaseAuth.instance.authStateChanges()` to drive `AuthState`.

## 3. Move the economy behind Firestore + Functions

The client is **already wired to the callables behind a flag**. Flip
`AppConfig.useRemoteBackend` to `true`
(`lib/core/config/app_config.dart`) and fill in the two stub bodies:

- `lib/features/backend/application/reward_service.dart` →
  `RemoteRewardService.claimLessonReward` (used by the lesson player).
- `lib/features/backend/application/purchase_validator.dart` →
  `RemotePurchaseValidator.validate` (used by `StoreController` before it
  grants entitlements).

Each stub already contains the exact `FirebaseFunctions.instance.httpsCallable`
call to uncomment. Until the flag is on, the local path runs and the app builds
without firebase dependencies.

### Reference: the seam

- Point a new `FirestorePlayerRepository` at `users/{uid}` (see
  `docs/firestore_schema.md` — one document read powers the whole dashboard).
- For anything trusted, call the callables instead of mutating locally:
  - Lesson rewards → `claimLessonReward({lessonId, isBoss, trackId})`
    (server decides XP, refuses duplicates). Call it from
    `PlayerController.completeLesson`.
  - Purchases → `validatePurchase({productId, purchaseToken})` from
    `StoreController._deliver` instead of granting on-device.

Example callable from Dart:

```dart
final callable = FirebaseFunctions.instance.httpsCallable('claimLessonReward');
final res = await callable.call({'lessonId': id, 'isBoss': isBoss, 'trackId': track});
final awarded = res.data['awarded'] as int;
```

## 4. Deploy rules, indexes and functions

```bash
firebase deploy --only firestore:rules,firestore:indexes
cd functions && npm install && npm run build && cd ..
firebase deploy --only functions
```

- `firestore.rules` — clients read their own data and may change only
  cosmetic/non-economic fields; all economy writes go through functions.
- `functions/src/index.ts` — `onUserCreate`, `claimLessonReward`,
  `resetLeagues` (weekly), `validatePurchase`.

> `validatePurchase` is a **stub**: wire the Google Play Developer API / App
> Store Server API to verify the purchase token before granting. Do not ship
> the stub to production.

## 5. Real matchmaking & leagues

Replace the client-side mock in
`lib/features/leagues/application/league_controller.dart` with a query over
`leagues/{leagueId}/members` ordered by `weeklyXp` (index already declared in
`firestore.indexes.json`). Extend `resetLeagues` to also re-shuffle players
into fresh 30-player groups by level/MMR.

## 6. Real ads (AdMob)

1. Add the dependency: `flutter pub add google_mobile_ads`.
2. Put your **AdMob App ID** in the native manifests (required — the SDK
   crashes at launch without it):
   - Android `AndroidManifest.xml`:
     ```xml
     <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXX~YYYYYYYY"/>
     ```
   - iOS `Info.plist`: `GADApplicationIdentifier` = your App ID.
3. Replace `lib/features/store/application/rewarded_ad_service.dart` with a real
   `RewardedAd.load(...).show(onUserEarnedReward: ...)`; call `onReward` from
   the earned-reward callback. The UI depends only on that interface.

## 7. In-app purchases

`in_app_purchase` is already wired in `StoreController`. Create the product IDs
from `lib/features/store/domain/store_products.dart`
(`crystals_small/medium/large`, `sub_plus/pro/ultimate`) in **Google Play
Console** and **App Store Connect**. Once live, `queryProductDetails` returns
prices and purchases flow through — then route delivery through
`validatePurchase` (step 3) for server-side receipt checks.
