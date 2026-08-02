/// Central configuration for Black Fury.
///
/// SECURITY NOTE:
/// Realtime Database REST calls made directly from a mobile client will
/// always expose whatever `auth` value is baked into the APK — anyone can
/// decompile the app and extract this string. Treat this key as PUBLIC.
/// Before shipping to real users:
///   1. Lock down Firebase Realtime Database Security Rules so reads/writes
///      require proper Firebase Authentication (not just a static key).
///   2. Consider proxying requests through a backend (Cloud Functions) that
///      holds the real secret server-side.
///   3. Rotate this key if it has ever been committed to a public repo.
class AppConfig {
  AppConfig._();

  static const String appName = 'Black Fury';
  static const String packageName = 'com.blackfury.vehiclecontrol';

  /// Firebase Realtime Database base URL (no trailing slash).
  static const String firebaseBaseUrl =
      'https://black-fury-4bdc5-default-rtdb.firebaseio.com';

  /// Firebase REST auth key (see security note above).
  static const String firebaseAuthKey =
      'BOmVoQrL90O5AOHL8iDyLRLNGkm_5IC2fFE_KvbngpOPzmEfB66hES1NR2r8HN3DGmbkzt7d888wH5F9bO0NY5E';

  // --- REST Endpoints ---------------------------------------------------
  static String get vehicleDataUrl =>
      '$firebaseBaseUrl/vehicle/data.json?auth=$firebaseAuthKey';

  static String get isThiefUrl =>
      '$firebaseBaseUrl/vehicle/is_thief.json?auth=$firebaseAuthKey';

  static String get relayControlUrl =>
      '$firebaseBaseUrl/vehicle/appControlRelay.json?auth=$firebaseAuthKey';

  // --- Polling ------------------------------------------------------------
  static const Duration pollInterval = Duration(seconds: 3);

  // --- Vehicle assumptions --------------------------------------------
  /// Used to estimate remaining range from fuel percentage.
  /// Adjust to match the actual tank capacity / fuel economy of the bike.
  static const double tankCapacityLiters = 12.0;
  static const double kmPerLiter = 40.0;
}
