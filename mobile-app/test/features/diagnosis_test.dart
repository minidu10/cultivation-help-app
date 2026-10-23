import 'dart:convert';
import 'dart:typed_data';

import 'package:agromaster/core/api/api_exception.dart';
import 'package:agromaster/features/crops/data/crop_models.dart';
import 'package:agromaster/features/diagnosis/data/diagnosis_models.dart';
import 'package:agromaster/features/diagnosis/data/diagnosis_repository.dart';
import 'package:agromaster/features/diagnosis/presentation/diagnosis_result.dart';
import 'package:agromaster/features/diagnosis/presentation/diagnosis_screen.dart';
import 'package:agromaster/features/diagnosis/presentation/health_tab.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';

class MockDiagnosisRepository extends Mock implements DiagnosisRepository {}

/// A real 1x1 PNG, so Image.memory has something it can decode.
final _pixel = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');

final _paddy = Crop(id: 7, name: 'Paddy', plantingDate: DateTime(2026, 5, 1), status: CropStatus.growing);

final _blast = Diagnosis(
  id: 11,
  cropId: 7,
  cropGuess: 'Rice',
  condition: 'Rice blast',
  confidence: 0.82,
  symptoms: const ['Diamond-shaped grey lesions'],
  treatmentOrganic: const ['Remove badly affected leaves'],
  treatmentChemical: const ['Tricyclazole, as the label directs'],
  prevention: const ['Avoid excess nitrogen'],
  createdAt: DateTime(2026, 10, 24, 9, 30),
  thumbnailUrl: '/api/crops/7/diagnoses/11/thumbnail',
);

Widget _scrollable(Widget child) => Scaffold(body: SingleChildScrollView(child: child));

void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));

  group('DiagnosisResult', () {
    testWidgets('shows the finding, how sure it is and what to do', (tester) async {
      await pumpScreen(tester, _scrollable(DiagnosisResult(_blast)));

      expect(find.text('Rice blast'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Confidence 82%'), findsOneWidget);
      expect(find.text('Looks like Rice'), findsOneWidget);
      expect(find.text('• Tricyclazole, as the label directs'), findsOneWidget);
      expect(find.textContaining('Follow the product label'), findsOneWidget);
      expect(find.byKey(const Key('see-expert')), findsNothing);
    });

    testWidgets('points to an expert when the model was unsure', (tester) async {
      await pumpScreen(tester, _scrollable(DiagnosisResult(_blast.copyWith(confidence: 0.3, seeExpert: true))));

      expect(find.byKey(const Key('see-expert')), findsOneWidget);
      expect(find.textContaining('Agrarian Service Centre'), findsOneWidget);
    });

    testWidgets('a healthy plant gets no chemical advice', (tester) async {
      await pumpScreen(tester, _scrollable(DiagnosisResult(_blast.copyWith(
        condition: 'Healthy',
        severity: DiagnosisSeverity.none,
        treatmentOrganic: const [],
        treatmentChemical: const [],
      ))));

      expect(find.text('Healthy'), findsWidgets);
      expect(find.text('Chemical options'), findsNothing);
      expect(find.textContaining('Follow the product label'), findsNothing);
    });

    testWidgets('a photo with no plant in it asks for a better one', (tester) async {
      var retakes = 0;
      await pumpScreen(tester, _scrollable(DiagnosisResult(
        const Diagnosis(cropId: 7, isPlant: false, condition: 'Not a plant'),
        onRetake: () => retakes++,
      )));

      expect(find.text('We could not see a plant clearly'), findsOneWidget);
      expect(find.text('Take it in daylight, without flash'), findsOneWidget);

      await tester.tap(find.text('Take another photo'));
      expect(retakes, 1);
    });
  });

  group('DiagnosisScreen', () {
    testWidgets('sends the photo and shows the answer', (tester) async {
      final repo = MockDiagnosisRepository();
      when(() => repo.diagnose(any(), any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return _blast;
      });
      await pumpScreen(tester, DiagnosisScreen(crop: _paddy, photo: _pixel),
          overrides: [diagnosisRepositoryProvider.overrideWithValue(repo)]);

      expect(find.text('Checking the photo…'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Rice blast'), findsOneWidget);
      verify(() => repo.diagnose(7, _pixel)).called(1);
    });

    testWidgets('a daily-limit refusal explains itself and offers no pointless retry', (tester) async {
      final repo = MockDiagnosisRepository();
      when(() => repo.diagnose(any(), any())).thenThrow(
        const ApiException('You have checked 10 photos today, the daily limit. It resets tomorrow.', statusCode: 429),
      );
      await pumpScreen(tester, DiagnosisScreen(crop: _paddy, photo: _pixel),
          overrides: [diagnosisRepositoryProvider.overrideWithValue(repo)]);
      await tester.pumpAndSettle();

      expect(find.textContaining('daily limit'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('an outage can be retried', (tester) async {
      final repo = MockDiagnosisRepository();
      var calls = 0;
      when(() => repo.diagnose(any(), any())).thenAnswer((_) async {
        if (calls++ == 0) throw const ApiException('The crop doctor is unavailable right now.', statusCode: 503);
        return _blast;
      });
      await pumpScreen(tester, DiagnosisScreen(crop: _paddy, photo: _pixel),
          overrides: [diagnosisRepositoryProvider.overrideWithValue(repo)]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Rice blast'), findsOneWidget);
    });
  });

  group('HealthTab', () {
    testWidgets('lists past checks with their photos', (tester) async {
      await pumpScreen(tester, Scaffold(body: HealthTab(crop: _paddy)), overrides: [
        diagnosesProvider.overrideWith((ref, cropId) async => [_blast]),
        thumbnailProvider.overrideWith((ref, url) async => _pixel),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Rice blast'), findsOneWidget);
      expect(find.textContaining('Confidence 82%'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('says when nothing has been checked yet', (tester) async {
      await pumpScreen(tester, Scaffold(body: HealthTab(crop: _paddy)), overrides: [
        diagnosesProvider.overrideWith((ref, cropId) async => <Diagnosis>[]),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('No photos checked for this crop yet.'), findsOneWidget);
      expect(find.text('Check a photo'), findsOneWidget);
    });
  });

  group('DiagnosisRepository', () {
    test('uploads the photo as multipart with its note', () async {
      final adapter = _CapturingAdapter({
        'id': 11, 'cropId': 7, 'isPlant': true, 'condition': 'Rice blast', 'confidence': 0.82,
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))..httpClientAdapter = adapter;

      final result = await DiagnosisRepository(dio).diagnose(7, _pixel, note: '  spots after rain ');

      expect(result.condition, 'Rice blast');
      final form = adapter.last!.data as FormData;
      expect(adapter.last!.path, '/crops/7/diagnoses');
      expect(form.files.single.key, 'image');
      expect(form.files.single.value.contentType.toString(), 'image/jpeg');
      expect(form.fields.single.key, 'note');
      expect(form.fields.single.value, 'spots after rain');
    });

    test('reads an unknown severity as moderate', () {
      final d = Diagnosis.fromJson({'cropId': 1, 'severity': 'catastrophic'});

      expect(d.severity, DiagnosisSeverity.moderate);
    });
  });
}

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.reply);

  final Map<String, Object?> reply;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    // Drain the multipart stream as a real client would.
    await requestStream?.drain<void>();
    return ResponseBody.fromString(jsonEncode(reply), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
