import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../data/weather_models.dart';
import '../data/weather_repository.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final weather = ref.watch(farmWeatherProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weather.when(
          loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          // Weather is a nice-to-have on this screen; failing quietly with a
          // line of text is better than an error panel above the figures.
          error: (_, _) => Row(
            children: [
              Icon(Icons.cloud_off_outlined, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.weatherUnavailable)),
              IconButton(
                tooltip: l10n.retry,
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(farmWeatherProvider),
              ),
            ],
          ),
          data: (w) => _WeatherBody(w),
        ),
      ),
    );
  }
}

class _WeatherBody extends StatelessWidget {
  const _WeatherBody(this.weather);

  final FarmWeather weather;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = weather.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (c.iconUrl != null)
              Image.network(c.iconUrl!, width: 56, height: 56, errorBuilder: (_, _, _) => const Icon(Icons.wb_sunny_outlined, size: 40))
            else
              const Icon(Icons.wb_sunny_outlined, size: 40),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.location ?? l10n.weatherTitle, style: theme.textTheme.labelLarge),
                  Text(c.description ?? '', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              '${(c.temperatureC ?? 0).round()}°',
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            if (c.feelsLikeC != null) Text(l10n.feelsLike(c.feelsLikeC!.round()), style: theme.textTheme.bodySmall),
            if (c.humidity != null) Text(l10n.humidityValue(c.humidity!), style: theme.textTheme.bodySmall),
            if (c.windSpeed != null)
              Text(l10n.windValue(c.windSpeed!.toStringAsFixed(1)), style: theme.textTheme.bodySmall),
          ],
        ),
        if (weather.forecast.isNotEmpty) ...[
          const Divider(height: 24),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.forecast.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _Slot(weather.forecast[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot(this.item);

  final ForecastItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // OpenWeather slots are UTC; show them in the phone's time.
    final time = item.dateTime == null ? null : DateTime.tryParse('${item.dateTime!.replaceFirst(' ', 'T')}Z')?.toLocal();
    return Column(
      children: [
        Text(time == null ? '' : '${time.hour.toString().padLeft(2, '0')}:00', style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text('${(item.temperatureC ?? 0).round()}°', style: theme.textTheme.titleSmall),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.water_drop, size: 12, color: theme.colorScheme.primary),
            Text(context.l10n.rainChance(item.rainChancePercent), style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
