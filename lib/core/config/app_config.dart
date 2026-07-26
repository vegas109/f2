/// Compile-time configuration flags.
class AppConfig {
  AppConfig._();

  /// When `true`, economy-critical actions (lesson rewards, purchase delivery)
  /// route through Cloud Functions callables instead of being applied on the
  /// device. This is the anti-cheat / server-authoritative path.
  ///
  /// Default `false` (Local mode). Flip to `true` only AFTER enabling Firebase
  /// and wiring the callables — see `docs/firebase_enablement.md`. Until then
  /// the "remote" services are stubs that fall back to the local path, so the
  /// app keeps working (and building without firebase dependencies) either way.
  static const bool useRemoteBackend = false;
}
