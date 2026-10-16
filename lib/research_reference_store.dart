/// A reference picture or PDF's file, stored with the research entry it is.
///
/// **Not a second asset store.** Per-record assets have one home, the
/// `RecordAssetRows` table, keyed by project, record and role, with
/// `RecordAvatarStore` reading the `avatar` role and `VoiceNoteStore` the
/// `voice` role. A reference's file is the same kind of thing under the
/// `reference` role (authoros-core's `ResearchReferences.assetRole`), kept on
/// the research entry that describes it, so this reads and writes that table
/// for that role and nothing else.
///
/// The bytes are kept as supplied, as an avatar's are, and for the same
/// reasons: a path dies when the file moves, and re-encoding a photograph as
/// PNG makes it larger.
///
/// Added October 16, 2026, for AOS Worldsmith's research library.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:authoros_core/research_reference.dart';
import 'package:drift/drift.dart' as drift;

import 'authoros_database.dart';

/// One reference's file.
class ResearchReferenceFile {
  const ResearchReferenceFile({
    required this.bytes,
    required this.mediaType,
    this.width,
    this.height,
    this.updatedAt,
  });

  final Uint8List bytes;

  /// Sniffed from the file's own bytes, never its name.
  final String mediaType;
  final int? width;
  final int? height;
  final DateTime? updatedAt;

  bool get isImage => ResearchReferences.isImage(mediaType);

  /// Validates a file the author picked: one of the types a reference may
  /// be, within [ResearchReferences.maxBytes], and, for a picture, one this
  /// platform can draw. Nothing throws: a refusal is an answer to show.
  static Future<ResearchReferenceImport> fromBytes(
    Uint8List bytes, {
    DateTime? timestamp,
  }) async {
    final rejection = ResearchReferences.rejection(bytes);
    if (rejection != null) {
      return ResearchReferenceImport.refused(rejection.message);
    }
    final mediaType = ResearchReferences.sniff(bytes)!;
    int? width;
    int? height;
    if (ResearchReferences.isImage(mediaType)) {
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        width = frame.image.width;
        height = frame.image.height;
        frame.image.dispose();
        codec.dispose();
      } on Object {
        // Refused rather than stored as a broken box, as an avatar is.
        return const ResearchReferenceImport.refused(
          'That picture could not be opened.',
        );
      }
    }
    return ResearchReferenceImport.accepted(ResearchReferenceFile(
      bytes: bytes,
      mediaType: mediaType,
      width: width,
      height: height,
      updatedAt: timestamp,
    ));
  }
}

/// The outcome of offering a file up as a reference.
class ResearchReferenceImport {
  const ResearchReferenceImport.accepted(ResearchReferenceFile this.file)
      : refusal = null;
  const ResearchReferenceImport.refused(String this.refusal) : file = null;

  final ResearchReferenceFile? file;

  /// What to tell the author when the file cannot be kept.
  final String? refusal;
}

/// What a reference's file is, without its bytes: for a list of many.
class ResearchReferenceInfo {
  const ResearchReferenceInfo({
    required this.recordId,
    required this.mediaType,
    required this.byteLength,
    required this.updatedAt,
    this.width,
    this.height,
  });

  final String recordId;
  final String mediaType;
  final int byteLength;
  final int? width;
  final int? height;
  final DateTime updatedAt;

  bool get isImage => ResearchReferences.isImage(mediaType);

  /// *PDF · 1.2 MB*, *PNG · 1200 x 800 · 340 KB*.
  String get summary {
    final kind = mediaType == ResearchReferences.pdfMediaType
        ? 'PDF'
        : mediaType.split('/').last.toUpperCase();
    final size = byteLength < 1024 * 1024
        ? '${(byteLength / 1024).ceil()} KB'
        : '${(byteLength / (1024 * 1024)).toStringAsFixed(1)} MB';
    return [
      kind,
      if (width != null && height != null) '$width x $height',
      size,
    ].join(' · ');
  }
}

class ResearchReferenceStore {
  const ResearchReferenceStore({required this.database});

  final AuthorOsDatabase database;

  static const role = ResearchReferences.assetRole;

  Future<ResearchReferenceFile?> load(String projectId, String recordId) async {
    final query = database.select(database.recordAssetRows)
      ..where((row) =>
          row.projectId.equals(projectId) &
          row.recordId.equals(recordId) &
          row.role.equals(role));
    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : ResearchReferenceFile(
            bytes: Uint8List.fromList(row.bytes),
            mediaType: row.mediaType,
            width: row.width,
            height: row.height,
            updatedAt: row.updatedAt.toUtc(),
          );
  }

  /// Every reference file in [projectId], described but not read, keyed by
  /// the research entry it belongs to. The size is SQLite's own count of
  /// the stored bytes, so a library of fifty PDFs is not fifty reads.
  Future<Map<String, ResearchReferenceInfo>> infoOf(String projectId) async {
    final rows = await database.customSelect(
      'SELECT record_id, media_type, length(bytes) AS size, width, height, '
      'updated_at FROM record_asset_rows '
      'WHERE project_id = ? AND role = ?',
      variables: [
        drift.Variable.withString(projectId),
        drift.Variable.withString(role),
      ],
      readsFrom: {database.recordAssetRows},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('record_id'): ResearchReferenceInfo(
          recordId: row.read<String>('record_id'),
          mediaType: row.read<String>('media_type'),
          byteLength: row.read<int>('size'),
          width: row.readNullable<int>('width'),
          height: row.readNullable<int>('height'),
          updatedAt: row.read<DateTime>('updated_at').toUtc(),
        ),
    };
  }

  Future<void> save(
    String projectId,
    String recordId,
    ResearchReferenceFile file, {
    DateTime? timestamp,
  }) async {
    final rejection = ResearchReferences.rejection(file.bytes);
    if (rejection != null) throw ArgumentError(rejection.message);
    await database.into(database.recordAssetRows).insertOnConflictUpdate(
          RecordAssetRowsCompanion.insert(
            projectId: projectId,
            recordId: recordId,
            role: role,
            mediaType: file.mediaType,
            bytes: file.bytes,
            width: drift.Value(file.width),
            height: drift.Value(file.height),
            updatedAt: timestamp ?? file.updatedAt ?? DateTime.now().toUtc(),
            extensionJson: '{}',
          ),
        );
  }

  Future<void> remove(String projectId, String recordId) async {
    await (database.delete(database.recordAssetRows)
          ..where((row) =>
              row.projectId.equals(projectId) &
              row.recordId.equals(recordId) &
              row.role.equals(role)))
        .go();
  }
}
