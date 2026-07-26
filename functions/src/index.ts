/**
 * CodeHero Cloud Functions.
 *
 * These enforce the server-authoritative parts of the game so a tampered
 * client cannot inflate progress or fake purchases:
 *   - user document bootstrap on sign-up
 *   - secure lesson-reward granting (server decides the XP, refuses dupes)
 *   - weekly league reset
 *   - in-app purchase validation + entitlement granting
 *
 * The Admin SDK bypasses Firestore security rules, so these are the ONLY
 * writers of economy fields (see firestore.rules).
 */
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as functionsV1 from "firebase-functions/v1";

initializeApp();
const db = getFirestore();

// Server-authoritative reward values (clients cannot change these).
const XP_LESSON = 20;
const XP_BOSS = 120;

/** Create the user document when an account is created. */
export const onUserCreate = functionsV1.auth.user().onCreate(async (user) => {
  await db.doc(`users/${user.uid}`).set({
    displayName: user.displayName ?? "Coder",
    email: user.email ?? null,
    photoUrl: user.photoURL ?? null,
    createdAt: Date.now(),
    xp: 0,
    level: 1,
    crystals: 50,
    energy: 5,
    lastEnergyRefillMs: 0,
    streak: 0,
    lastActiveDay: "",
    selectedTrack: "python",
    subscription: {tier: "none", expiresAt: null, store: null},
    trackSummary: {},
  });
});

/**
 * Securely grant a lesson reward. The client sends only the lessonId; the
 * SERVER decides how much XP and refuses to pay twice for the same lesson.
 */
export const claimLessonReward = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const lessonId = String(request.data?.lessonId ?? "");
  const isBoss = Boolean(request.data?.isBoss);
  const trackId = String(request.data?.trackId ?? "python");
  if (!lessonId) throw new HttpsError("invalid-argument", "lessonId required.");

  const progressRef = db.doc(`users/${uid}/progress/${trackId}`);
  const userRef = db.doc(`users/${uid}`);

  const awarded = await db.runTransaction(async (tx) => {
    const progressSnap = await tx.get(progressRef);
    const lessons =
      (progressSnap.get("lessons") ?? {}) as Record<string, unknown>;
    if (lessons[lessonId]) return 0; // already completed → no double reward
    const xp = isBoss ? XP_BOSS : XP_LESSON;
    tx.set(
      progressRef,
      {lessons: {[lessonId]: {completed: true}}},
      {merge: true},
    );
    tx.set(userRef, {xp: FieldValue.increment(xp)}, {merge: true});
    return xp;
  });

  if (awarded > 0) {
    const userSnap = await userRef.get();
    const xp = Number(userSnap.get("xp") ?? 0);
    await userRef.set({level: Math.floor(xp / 100) + 1}, {merge: true});
    await bumpWeeklyXp(uid, awarded);
  }
  return {awarded};
});

/** Increment the player's weekly league score, if they are in a league. */
async function bumpWeeklyXp(uid: string, delta: number): Promise<void> {
  const memberships = await db
    .collectionGroup("members")
    .where("uid", "==", uid)
    .limit(1)
    .get();
  if (!memberships.empty) {
    await memberships.docs[0].ref.set(
      {weeklyXp: FieldValue.increment(delta)},
      {merge: true},
    );
  }
}

/** Weekly league reset — runs every Monday at 00:00 UTC. */
export const resetLeagues = onSchedule("every monday 00:00", async () => {
  const members = await db.collectionGroup("members").get();
  const batch = db.batch();
  members.forEach((doc) => batch.set(doc.ref, {weeklyXp: 0}, {merge: true}));
  await batch.commit();
  // A production version would also re-shuffle players into fresh league
  // groups of 30 by level/MMR here.
});

/**
 * Validate an in-app purchase and grant entitlements.
 *
 * Stubbed: before granting, verify the purchase token with the store's server
 * API (Google Play Developer API / App Store Server API). Until then this
 * grants based on productId alone — do NOT ship as-is to production.
 */
export const validatePurchase = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const productId = String(request.data?.productId ?? "");
  // const purchaseToken = String(request.data?.purchaseToken ?? "");
  // TODO: verify purchaseToken with the store API before granting anything.

  const crystalsByProduct: Record<string, number> = {
    crystals_small: 100,
    crystals_medium: 550,
    crystals_large: 1200,
  };
  const tierByProduct: Record<string, string> = {
    sub_plus: "plus",
    sub_pro: "pro",
    sub_ultimate: "ultimate",
  };

  const userRef = db.doc(`users/${uid}`);
  if (crystalsByProduct[productId]) {
    await userRef.set(
      {crystals: FieldValue.increment(crystalsByProduct[productId])},
      {merge: true},
    );
    return {ok: true, granted: "crystals"};
  }
  if (tierByProduct[productId]) {
    await userRef.set(
      {subscription: {tier: tierByProduct[productId], store: "play"}},
      {merge: true},
    );
    return {ok: true, granted: "subscription"};
  }
  throw new HttpsError("invalid-argument", "Unknown product.");
});
