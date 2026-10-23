import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/formatters.dart';
import '../../../core/format/labels.dart';
import '../../../core/widgets/common.dart';
import '../../crops/data/crop_models.dart';
import '../../crops/data/crop_repository.dart';
import '../data/photo_source.dart';
import 'diagnosis_screen.dart';

/// The camera button: camera or gallery, then which crop it is (skipped when
/// only one is growing, or when started from a crop's own page), then the answer.
Future<void> startScan(BuildContext context, WidgetRef ref, {Crop? crop}) async {
  final l10n = context.l10n;
  final navigator = Navigator.of(context, rootNavigator: true);

  final fromCamera = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.scanChooseSource, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.scanTakePhoto),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.scanFromGallery),
            onTap: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (fromCamera == null || !context.mounted) return;

  final target = crop ?? await _chooseCrop(context, ref);
  if (target == null || !context.mounted) return;

  final photo = await ref.read(photoSourceProvider).take(fromCamera: fromCamera);
  if (photo == null) return;

  await navigator.push(MaterialPageRoute<void>(builder: (_) => DiagnosisScreen(crop: target, photo: photo)));
}

Future<Crop?> _chooseCrop(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final List<Crop> crops;
  try {
    crops = await ref.read(cropsProvider.future);
  } on Exception catch (e) {
    if (context.mounted) showError(context, e);
    return null;
  }
  // Growing crops first; those are the ones a farmer is photographing.
  final choices = [...crops.where((c) => c.status.isActive), ...crops.where((c) => !c.status.isActive)];
  if (choices.isEmpty) {
    if (context.mounted) showMessage(context, l10n.scanNoCrops);
    return null;
  }
  if (choices.length == 1 || !context.mounted) return choices.first;

  return showModalBottomSheet<Crop>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l10n.scanChooseCrop, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final c in choices)
              ListTile(
                leading: Icon(c.status.icon, color: c.status.color),
                title: Text([c.name, if (c.variety?.isNotEmpty ?? false) c.variety].join(' · ')),
                subtitle: Text(c.status.label(l10n)),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    ),
  );
}
