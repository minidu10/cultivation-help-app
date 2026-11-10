/// Build-time configuration, set with --dart-define.
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
///   flutter build apk --dart-define=API_BASE_URL=https://agromaster.duckdns.org/api
///
/// The default is the local backend as the Android emulator sees it (10.0.2.2
/// is the host machine), so `flutter run` works against `docker compose up`
/// with no flags at all.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );
}
