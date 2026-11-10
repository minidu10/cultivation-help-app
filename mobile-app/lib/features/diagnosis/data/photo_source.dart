import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Takes or chooses a photo and shrinks it for upload.
///
/// An interface so widget tests can hand back fixed bytes instead of opening
/// a camera that does not exist.
abstract interface class PhotoSource {
  /// A JPEG ready to send, or null if the farmer backed out.
  Future<Uint8List?> take({required bool fromCamera});
}

final photoSourceProvider = Provider<PhotoSource>((ref) => DevicePhotoSource());

class DevicePhotoSource implements PhotoSource {
  /// The longer side after shrinking: plenty for the model to see spots.
  static const _maxSide = 1280;

  final _picker = ImagePicker();

  @override
  Future<Uint8List?> take({required bool fromCamera}) async {
    // No resizing here: image_picker keeps the EXIF rotation tag instead of
    // turning the pixels, and the server strips EXIF, so portrait photos
    // would arrive sideways. The compressor below rotates them upright.
    final picked = await _picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (picked == null) return null;

    final compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: _maxSide,
      minHeight: _maxSide,
      quality: 85,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    // A format the compressor cannot read: send it as it is, the server
    // checks and shrinks it anyway.
    return compressed ?? await picked.readAsBytes();
  }
}
