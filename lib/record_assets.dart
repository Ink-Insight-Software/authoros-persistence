/// Every per-record asset, whatever its role, for the archive and for copies.
///
/// **Not a third asset store.** `RecordAvatarStore`, `VoiceNoteStore` and
/// `ResearchReferenceStore` each read and write one role of the
/// `RecordAssetRows` table. This reads the table whole, in the core's
/// `RecordAsset` shape, so that a backup can carry every file a project holds
/// (roles this build has never heard of included), a restore can put them
/// back, and a duplicate can take them to the copies' ids.
///
/// Added October 16, 2026, when the archive began carrying record assets
/// (authoros-core 0.20.0). Before it, no avatar, voice note or attachment
/// travelled in a backup.
library;

import 'dart:convert';

import 'package:authoros_core/record_asset.dart';
import 'package:drift/drift.dart';

import 'authoros_database.dart';

class RecordAssets {
  const RecordAssets({required this.database});

  final AuthorOsDatabase database;

  /// Every asset in the database, ordered by project, record and role.
  Future<List<RecordAsset>> all() => _read(database.select(
        database.recordAssetRows,
      ));

  /// Every asset of [projectId].
  Future<List<RecordAsset>> ofProject(String projectId) =>
      _read(database.select(database.recordAssetRows)
        ..where((row) => row.projectId.equals(projectId)));

  /// Writes [assets], each replacing whatever its project, record and role
  /// held. Nothing else is touched.
  Future<void> putAll(Iterable<RecordAsset> assets) async {
    await database.transaction(() async {
      for (final asset in assets) {
        await database
            .into(database.recordAssetRows)
            .insertOnConflictUpdate(_companion(asset));
      }
    });
  }

  /// Replaces every asset in the database with [assets], in one
  /// transaction: what a whole-installation restore does.
  Future<void> replaceAll(Iterable<RecordAsset> assets) async {
    await database.transaction(() async {
      await database.delete(database.recordAssetRows).go();
      for (final asset in assets) {
        await database
            .into(database.recordAssetRows)
            .insertOnConflictUpdate(_companion(asset));
      }
    });
  }

  /// Copies [assets] into project [to], each under the id [recordIds] gives
  /// its record. An asset whose record has no copy is left behind, as a
  /// copy leaves the record behind. Returns how many were written.
  Future<int> copyInto(
    Iterable<RecordAsset> assets, {
    required String to,
    required Map<String, String> recordIds,
  }) async {
    final moved = [
      for (final asset in assets)
        if (recordIds[asset.recordId] case final id?)
          asset.movedTo(projectId: to, recordId: id),
    ];
    await putAll(moved);
    return moved.length;
  }

  Future<List<RecordAsset>> _read(
    SimpleSelectStatement<$RecordAssetRowsTable, RecordAssetRow> query,
  ) async {
    query.orderBy([
      (row) => OrderingTerm.asc(row.projectId),
      (row) => OrderingTerm.asc(row.recordId),
      (row) => OrderingTerm.asc(row.role),
    ]);
    return [
      for (final row in await query.get())
        RecordAsset(
          projectId: row.projectId,
          recordId: row.recordId,
          role: row.role,
          mediaType: row.mediaType,
          bytes: Uint8List.fromList(row.bytes),
          width: row.width,
          height: row.height,
          updatedAt: row.updatedAt.toUtc(),
          extension: _extension(row.extensionJson),
        ),
    ];
  }

  static RecordAssetRowsCompanion _companion(RecordAsset asset) =>
      RecordAssetRowsCompanion.insert(
        projectId: asset.projectId,
        recordId: asset.recordId,
        role: asset.role,
        mediaType: asset.mediaType,
        bytes: asset.bytes,
        width: Value(asset.width),
        height: Value(asset.height),
        updatedAt: asset.updatedAt,
        extensionJson: jsonEncode(asset.extension),
      );

  static Map<String, Object?> _extension(String json) {
    try {
      final decoded = jsonDecode(json);
      return decoded is Map ? Map<String, Object?>.from(decoded) : const {};
    } on FormatException {
      return const {};
    }
  }
}
