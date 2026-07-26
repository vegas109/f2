/// App-wide constants and tunable gameplay/economy values.
///
/// Keep balance numbers here so they are easy to tweak in one place.
class AppConstants {
  AppConstants._();

  static const String appName = 'CodeHero';

  // --- Code execution (Piston public API) ---
  // Docs: https://github.com/engineering-online/piston
  static const String pistonBaseUrl = 'https://emkc.org/api/v2/piston';
  static const Duration codeExecutionTimeout = Duration(seconds: 25);

  // Piston language identifiers and versions (kept explicit for determinism).
  static const String pythonRuntime = 'python';
  static const String pythonVersion = '3.10.0';
  static const String cppRuntime = 'c++';
  static const String cppVersion = '10.2.0';

  // --- Energy / hearts economy ---
  static const int maxEnergy = 5;
  static const int energyCostPerMistake = 1;
  static const Duration energyRefillInterval = Duration(minutes: 30);
  static const int energyRefillCostCrystals = 30;

  // --- Currency / rewards ---
  static const int xpPerLesson = 20;
  static const int xpPerBossFight = 120;
  static const int crystalsPerRewardedAd = 15;
  static const int dailyStreakBonusXp = 10;

  // --- Leagues ---
  static const int leagueSize = 30; // players per weekly league group
}
