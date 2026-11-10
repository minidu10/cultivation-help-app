import 'package:agromaster/features/crops/data/crop_models.dart';
import 'package:agromaster/features/crops/data/crop_repository.dart';
import 'package:agromaster/features/crops/presentation/crops_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _crops = [
  Crop(id: 1, name: 'Paddy', variety: 'BG 300', plantingDate: DateTime(2026, 4, 1), status: CropStatus.growing),
  Crop(id: 2, name: 'Green Chilli', plantingDate: DateTime(2026, 3, 1), status: CropStatus.growing),
  Crop(id: 3, name: 'Big Onion', plantingDate: DateTime(2026, 1, 1), status: CropStatus.failed),
];

void main() {
  testWidgets('lists every crop with a filter chip per status that has crops', (tester) async {
    await pumpScreen(tester, const CropsScreen(), overrides: [cropsProvider.overrideWith((ref) async => _crops)]);
    await tester.pumpAndSettle();

    expect(find.text('Paddy · BG 300'), findsOneWidget);
    expect(find.text('Green Chilli'), findsOneWidget);
    expect(find.text('Big Onion'), findsOneWidget);
    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('Growing (2)'), findsOneWidget);
    expect(find.text('Failed (1)'), findsOneWidget);
    // No harvested crops, so no chip for them.
    expect(find.textContaining('Harvested ('), findsNothing);
  });

  testWidgets('a filter chip narrows the list', (tester) async {
    await pumpScreen(tester, const CropsScreen(), overrides: [cropsProvider.overrideWith((ref) async => _crops)]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Failed (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Big Onion'), findsOneWidget);
    expect(find.text('Paddy · BG 300'), findsNothing);

    await tester.tap(find.text('All (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Paddy · BG 300'), findsOneWidget);
  });

  testWidgets('a farmer with no crops is told how to start', (tester) async {
    await pumpScreen(tester, const CropsScreen(), overrides: [cropsProvider.overrideWith((ref) async => <Crop>[])]);
    await tester.pumpAndSettle();

    expect(find.text('No crops yet'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Add crop'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await pumpScreen(
      tester,
      const CropsScreen(),
      overrides: [cropsProvider.overrideWith((ref) async => throw Exception('offline'))],
    );
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });
}
