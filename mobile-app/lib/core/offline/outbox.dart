import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

enum OutboxKind { expense, harvest }

/// A record saved on the phone while offline, waiting to be sent.
///
/// [clientRef] is also inside [body]. The server keeps one row per
/// (crop, clientRef), so sending an entry again after a lost reply is
/// harmless, which is what makes retrying safe.
@immutable
class OutboxEntry {
  const OutboxEntry({
    required this.clientRef,
    required this.kind,
    required this.cropId,
    required this.body,
    required this.label,
    required this.createdAt,
  });

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
        clientRef: json['clientRef'] as String,
        kind: OutboxKind.values.byName(json['kind'] as String),
        cropId: json['cropId'] as int,
        body: Map<String, Object?>.from(json['body'] as Map),
        label: json['label'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String clientRef;
  final OutboxKind kind;
  final int cropId;
  final Map<String, Object?> body;

  /// What the farmer recognises it by in the list, e.g. "Urea 50kg".
  final String label;
  final DateTime createdAt;

  String get path => '/crops/$cropId/${kind == OutboxKind.expense ? 'expenses' : 'harvests'}';

  Map<String, Object?> toJson() => {
        'clientRef': clientRef,
        'kind': kind.name,
        'cropId': cropId,
        'body': body,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
      };
}

@immutable
class OutboxState {
  const OutboxState({this.pending = const [], this.rejected = const [], this.syncing = false});

  final List<OutboxEntry> pending;

  /// Entries the server refused (say, the crop was deleted meanwhile). They
  /// cannot succeed on retry, so they are set aside to show, not resent.
  final List<String> rejected;
  final bool syncing;

  List<OutboxEntry> forCrop(int cropId, OutboxKind kind) =>
      pending.where((e) => e.cropId == cropId && e.kind == kind).toList();

  OutboxState copyWith({List<OutboxEntry>? pending, List<String>? rejected, bool? syncing}) => OutboxState(
        pending: pending ?? this.pending,
        rejected: rejected ?? this.rejected,
        syncing: syncing ?? this.syncing,
      );
}

/// Called with each crop whose records changed, so its screens can reload.
typedef OnSynced = void Function(int cropId);

final outboxProvider = NotifierProvider<OutboxController, OutboxState>(OutboxController.new);

class OutboxController extends Notifier<OutboxState> {
  static const _key = 'outbox';

  /// Set by the app shell so a sync refreshes the screens that showed the
  /// entry as pending.
  OnSynced? onSynced;

  @override
  OutboxState build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    if (saved == null) return const OutboxState();
    final entries = (jsonDecode(saved) as List<dynamic>)
        .map((e) => OutboxEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return OutboxState(pending: entries);
  }

  Future<void> enqueue(OutboxEntry entry) async {
    state = state.copyWith(pending: [...state.pending, entry]);
    await _persist();
  }

  /// Sends everything waiting, oldest first. Stops at the first entry that
  /// gets no reply (still offline) so order is kept; anything the server
  /// refuses outright is set aside rather than retried forever.
  Future<void> flush() async {
    if (state.syncing || state.pending.isEmpty) return;
    state = state.copyWith(syncing: true);
    final dio = ref.read(dioProvider);
    try {
      while (state.pending.isNotEmpty) {
        final entry = state.pending.first;
        try {
          await dio.post<void>(entry.path, data: entry.body);
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          if (status == null || status >= 500 || status == 429 || status == 401) break;
          state = state.copyWith(rejected: [...state.rejected, entry.label]);
        }
        state = state.copyWith(pending: state.pending.skip(1).toList());
        await _persist();
        onSynced?.call(entry.cropId);
      }
    } finally {
      state = state.copyWith(syncing: false);
    }
  }

  void dismissRejected() => state = state.copyWith(rejected: const []);

  /// Sign-out: queued records belong to the person signing out.
  Future<void> clear() async {
    state = const OutboxState();
    await ref.read(sharedPreferencesProvider).remove(_key);
  }

  Future<void> _persist() => ref
      .read(sharedPreferencesProvider)
      .setString(_key, jsonEncode(state.pending.map((e) => e.toJson()).toList()));
}
