/// A voice note's audio, stored with the record it belongs to.
///
/// **Not a second asset store.** Per-record assets already have one home —
/// the `RecordAssetRows` table, keyed by project, record and *role* — and
/// `RecordAvatarStore` is its reader for the `avatar` role. A voice note is
/// the same kind of thing under another role: an idea's audio, the way a
/// character's portrait is its picture. So this reads and writes that table,
/// role `voice`, and nothing else.
///
/// Added September 25, 2026 for the Sketch It page's *Voice Note*.
library;

import 'package:drift/drift.dart';

import 'authoros_database.dart';

/// One recording.
class VoiceNote {
  const VoiceNote({
    required this.bytes,
    this.mediaType = voiceNoteMediaType,
    this.updatedAt,
  });

  final Uint8List bytes;
  final String mediaType;
  final DateTime? updatedAt;
}

/// What the recorder writes: uncompressed 16-bit PCM in a WAV container,
/// which every platform the app ships to can play back.
const String voiceNoteMediaType = 'audio/wav';

class VoiceNoteStore {
  const VoiceNoteStore({required this.database});

  final AuthorOsDatabase database;

  /// The asset role a voice note is stored under.
  static const voiceRole = 'voice';

  /// Four minutes of 16 kHz mono — the recorder stops itself well before.
  static const maxBytes = 8 * 1024 * 1024;

  AuthorOsDatabase get _database => database;

  Future<VoiceNote?> load(String projectId, String recordId) async {
    final query = _database.select(_database.recordAssetRows)
      ..where((row) =>
          row.projectId.equals(projectId) &
          row.recordId.equals(recordId) &
          row.role.equals(voiceRole));
    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : VoiceNote(
            bytes: Uint8List.fromList(row.bytes),
            mediaType: row.mediaType,
            updatedAt: row.updatedAt,
          );
  }

  Future<void> save(
    String projectId,
    String recordId,
    VoiceNote note, {
    DateTime? timestamp,
  }) async {
    if (note.bytes.isEmpty || note.bytes.length > maxBytes) {
      throw ArgumentError('A voice note must be between 1 byte and '
          '${maxBytes ~/ (1024 * 1024)} MB.');
    }
    await _database.into(_database.recordAssetRows).insertOnConflictUpdate(
          RecordAssetRowsCompanion.insert(
            projectId: projectId,
            recordId: recordId,
            role: voiceRole,
            mediaType: note.mediaType,
            bytes: note.bytes,
            updatedAt: timestamp ?? note.updatedAt ?? DateTime.now().toUtc(),
            extensionJson: '{}',
          ),
        );
  }

  Future<void> remove(String projectId, String recordId) async {
    await (_database.delete(_database.recordAssetRows)
          ..where((row) =>
              row.projectId.equals(projectId) &
              row.recordId.equals(recordId) &
              row.role.equals(voiceRole)))
        .go();
  }
}
