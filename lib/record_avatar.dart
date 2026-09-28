/// A picture the author attached to one record — a character's face, today.
///
/// The bytes are kept, not a path to them. A filesystem path breaks the moment
/// the picture is moved, renamed, or the project is opened on another machine,
/// and the browser's file picker returns an object URL that dies with the tab —
/// so a path-backed avatar looked fine until the first reload and then quietly
/// became a placeholder. Owning the bytes is what makes an avatar part of the
/// project rather than a reference to something outside it.
///
/// Stored exactly as supplied. Re-encoding is tempting and wrong for the same
/// reason it is wrong for a book cover: Flutter can only re-encode to PNG, and
/// a photograph as PNG is several times larger than the JPEG it came from.
/// Import validates and bounds instead.
///
/// This lives beside the table it owns rather than in `lib/core`: it binds
/// drift to store the bytes and `dart:ui` to check they decode, and core is
/// quarantined from both. See `test/core_boundary_architecture_test.dart`.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' as drift;

import 'package:authoros_core/image_media_type.dart';
import 'authoros_database.dart';

/// A stored picture, ready to draw.
class RecordAvatar {
  const RecordAvatar({
    required this.bytes,
    required this.mediaType,
    this.width,
    this.height,
    this.updatedAt,
  });

  final Uint8List bytes;

  /// The IANA type, determined from the file's own magic bytes rather than its
  /// name — an extension is a claim, not evidence.
  final String mediaType;

  final int? width;
  final int? height;
  final DateTime? updatedAt;

  /// Comfortably more than a portrait needs, bounded so one picture cannot
  /// dominate the database or a future sync payload.
  ///
  /// Smaller than a book cover's ceiling on purpose: a cover is displayed at
  /// full page and may be a retailer-grade asset, while an avatar is drawn in a
  /// circle sixty pixels across. A project holds one cover and can hold
  /// hundreds of avatars.
  static const maxBytes = 4 * 1024 * 1024;

  int get byteLength => bytes.length;

  /// A short human description, for a studio to show beside the picture.
  String get summary {
    final size = byteLength < 1024 * 1024
        ? '${(byteLength / 1024).round()} KB'
        : '${(byteLength / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (width == null || height == null) return size;
    return '$width x $height  ·  $size';
  }

  /// Validates and describes a file the author picked.
  ///
  /// Nothing throws: a file the app cannot use is an ordinary answer the
  /// surface reports, not an exception it has to catch.
  static Future<RecordAvatarImport> fromBytes(
    Uint8List bytes, {
    DateTime? timestamp,
  }) async {
    if (bytes.isEmpty) {
      return const RecordAvatarImport.rejected(RecordAvatarRejection.empty);
    }
    if (bytes.length > maxBytes) {
      return const RecordAvatarImport.rejected(RecordAvatarRejection.tooLarge);
    }
    final mediaType = sniffImageMediaType(bytes);
    if (mediaType == null) {
      return const RecordAvatarImport.rejected(
        RecordAvatarRejection.unsupportedType,
      );
    }

    int? width;
    int? height;
    try {
      final decoded = await ui.instantiateImageCodec(bytes);
      final frame = await decoded.getNextFrame();
      width = frame.image.width;
      height = frame.image.height;
      frame.image.dispose();
      decoded.dispose();
    } on Object {
      // The bytes carry a signature this app knows but the platform's own
      // decoder will not open them. Refuse rather than store something that
      // would draw as a broken box wherever it appeared.
      return const RecordAvatarImport.rejected(
        RecordAvatarRejection.undecodable,
      );
    }

    return RecordAvatarImport.accepted(
      RecordAvatar(
        bytes: bytes,
        mediaType: mediaType,
        width: width,
        height: height,
        updatedAt: timestamp,
      ),
    );
  }
}

/// Why a picked file could not become an avatar.
enum RecordAvatarRejection {
  empty,
  tooLarge,
  unsupportedType,
  undecodable;

  /// What to tell the author, in their terms rather than the format's.
  String get message => switch (this) {
        empty => 'That file is empty.',
        tooLarge => 'That picture is larger than 4 MB. Try a smaller one.',
        unsupportedType => 'That is not a JPEG, PNG, GIF or WebP image.',
        undecodable => 'That picture could not be opened.',
      };
}

/// The outcome of offering a file up as an avatar.
class RecordAvatarImport {
  const RecordAvatarImport.accepted(RecordAvatar this.avatar)
      : rejection = null;
  const RecordAvatarImport.rejected(RecordAvatarRejection this.rejection)
      : avatar = null;

  final RecordAvatar? avatar;
  final RecordAvatarRejection? rejection;

  bool get accepted => avatar != null;
}

/// Reads and writes per-record assets.
///
/// Keyed by project, record and role, so a character has at most one avatar and
/// replacing it is an upsert rather than an accumulation.
class RecordAvatarStore {
  const RecordAvatarStore({required this.database});

  final AuthorOsDatabase database;

  static const avatarRole = 'avatar';

  AuthorOsDatabase get _database => database;

  Future<RecordAvatar?> load(String projectId, String recordId) async {
    final query = _database.select(_database.recordAssetRows)
      ..where((row) =>
          row.projectId.equals(projectId) &
          row.recordId.equals(recordId) &
          row.role.equals(avatarRole));
    final row = await query.getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Every avatar among [recordIds], keyed by record id.
  ///
  /// One query rather than one per record: a family tree asks for its whole
  /// cast at once, and a tree of forty people should not be forty round trips.
  /// Records with no avatar are simply absent from the result.
  Future<Map<String, RecordAvatar>> loadMany(
    String projectId,
    Iterable<String> recordIds,
  ) async {
    final ids = recordIds.toSet().toList();
    if (ids.isEmpty) return const {};

    final query = _database.select(_database.recordAssetRows)
      ..where((row) =>
          row.projectId.equals(projectId) &
          row.role.equals(avatarRole) &
          row.recordId.isIn(ids));
    final rows = await query.get();
    return {for (final row in rows) row.recordId: _fromRow(row)};
  }

  Future<void> save(
    String projectId,
    String recordId,
    RecordAvatar avatar, {
    DateTime? timestamp,
  }) async {
    await _database.into(_database.recordAssetRows).insertOnConflictUpdate(
          RecordAssetRowsCompanion.insert(
            projectId: projectId,
            recordId: recordId,
            role: avatarRole,
            mediaType: avatar.mediaType,
            bytes: avatar.bytes,
            width: drift.Value(avatar.width),
            height: drift.Value(avatar.height),
            updatedAt: timestamp ?? avatar.updatedAt ?? DateTime.now().toUtc(),
            extensionJson: '{}',
          ),
        );
  }

  Future<void> remove(String projectId, String recordId) async {
    await (_database.delete(_database.recordAssetRows)
          ..where((row) =>
              row.projectId.equals(projectId) &
              row.recordId.equals(recordId) &
              row.role.equals(avatarRole)))
        .go();
  }

  static RecordAvatar _fromRow(RecordAssetRow row) => RecordAvatar(
        bytes: Uint8List.fromList(row.bytes),
        mediaType: row.mediaType,
        width: row.width,
        height: row.height,
        updatedAt: row.updatedAt,
      );
}
