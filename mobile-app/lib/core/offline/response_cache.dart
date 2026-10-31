import 'package:shared_preferences/shared_preferences.dart';

class CachedResponse {
  const CachedResponse(this.body, this.storedAt);

  final String body;
  final DateTime storedAt;
}

/// The last good answer to each GET, for when there is no signal.
///
/// SharedPreferences rather than a database: a farmer's crop list, records
/// and dashboard come to tens of kilobytes, and keeping the store in plain
/// Dart means `flutter test` needs no native SQLite on the machine running it.
abstract interface class ResponseCache {
  Future<CachedResponse?> read(String key);
  Future<void> write(String key, String body);

  /// Everything, on sign-out: the next person on this phone must not see it.
  Future<void> clear();
}

class PrefsResponseCache implements ResponseCache {
  PrefsResponseCache(this._prefs);

  static const _prefix = 'cache:';

  final SharedPreferences _prefs;

  @override
  Future<CachedResponse?> read(String key) async {
    final body = _prefs.getString('$_prefix$key');
    final at = _prefs.getInt('$_prefix$key@');
    if (body == null || at == null) return null;
    return CachedResponse(body, DateTime.fromMillisecondsSinceEpoch(at));
  }

  @override
  Future<void> write(String key, String body) async {
    await _prefs.setString('$_prefix$key', body);
    await _prefs.setInt('$_prefix$key@', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> clear() async {
    for (final key in _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(key);
    }
  }
}
