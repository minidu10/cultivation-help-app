import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/request.dart';
import '../../../core/providers.dart';
import '../../../core/session/session_controller.dart';
import 'weather_models.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) => WeatherRepository(ref.watch(dioProvider)));

class FarmWeather {
  const FarmWeather(this.current, this.forecast);

  final CurrentWeather current;
  final List<ForecastItem> forecast;
}

/// Weather for the farmer's saved town, falling back to Colombo when none is
/// set or the town is not recognised, so the card is never just empty.
final farmWeatherProvider = FutureProvider.autoDispose<FarmWeather>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  final city = ref.watch(sessionControllerProvider.select((s) => s.user?.city))?.trim();

  if (city != null && city.isNotEmpty) {
    try {
      return await repo.byLocation(city);
    } on Exception {
      // Unknown town: fall through to the default.
    }
  }
  return repo.byCoordinates(WeatherRepository.colomboLat, WeatherRepository.colomboLon);
});

class WeatherRepository {
  WeatherRepository(this._dio);

  static const colomboLat = 6.9271;
  static const colomboLon = 79.8612;

  final Dio _dio;

  Future<FarmWeather> byLocation(String location) => guard(() async {
        final results = await Future.wait([
          _dio.get<Map<String, dynamic>>('/weather/current/by-location', queryParameters: {'location': location}),
          _dio.get<Map<String, dynamic>>('/weather/forecast/by-location',
              queryParameters: {'location': location, 'count': 8}),
        ]);
        return _bundle(results);
      });

  Future<FarmWeather> byCoordinates(double lat, double lon) => guard(() async {
        final results = await Future.wait([
          _dio.get<Map<String, dynamic>>('/weather/current', queryParameters: {'lat': lat, 'lon': lon}),
          _dio.get<Map<String, dynamic>>('/weather/forecast', queryParameters: {'lat': lat, 'lon': lon, 'count': 8}),
        ]);
        return _bundle(results);
      });

  FarmWeather _bundle(List<Response<Map<String, dynamic>>> results) => FarmWeather(
        CurrentWeather.fromJson(results[0].data!),
        Forecast.fromJson(results[1].data!).items,
      );
}
