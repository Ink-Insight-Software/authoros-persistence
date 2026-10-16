/// Deleting a story branch (authoros_core 0.18.0): the branch, its overlays,
/// its history and its search rows go; canon, canon's history and every
/// other branch stay byte-identical; and an archive written afterwards
/// carries nothing of it.
library;

import 'dart:convert';

import 'package:authoros_core/archive/authoros_archive.dart';
import 'package:authoros_core/branch_domain.dart';
import 'package:authoros_core/branch_service.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/connection_engine.dart';
import 'package:authoros_core/record_service.dart';
import 'package:authoros_persistence/authoros_database.dart';
import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const project = 'world-1';
  final at = DateTime.utc(2026, 10, 16, 9);
  late AuthorOsDatabase database;
  late DriftConnectedDomainRepository repository;
  late BranchService branches;
  late AuthorRecord aster;
  late AuthorRecord varrow;
  late RecordLink trade;

  AuthorRecord civilisation(String id, String title, {String? branchId}) =>
      AuthorRecord(
        id: id,
        typeId: 'civilisation',
        scopeType:
            branchId == null ? RecordScopeType.project : RecordScopeType.branch,
        scopeId: branchId ?? project,
        projectId: project,
        branchId: branchId,
        canonStatus: branchId == null ? CanonStatus.canon : CanonStatus.draft,
        title: title,
        createdAt: at,
        updatedAt: at,
      );

  StoryBranch branch(String id) => StoryBranch(
        id: id,
        projectId: project,
        name: 'Scenario $id',
        kind: BranchKind.whatIf,
        createdAt: at,
      );

  Future<void> fill(String branchId) async {
    await branches.createBranch(branch(branchId));
    await branches.createRecord(
      branchId,
      civilisation('$branchId-new', 'Ashen $branchId', branchId: branchId),
      timestamp: at,
    );
    await branches.overrideRecord(
      branchId,
      aster.id,
      title: 'Aster in $branchId',
      timestamp: at,
    );
    await branches.hideConnection(branchId, trade.id, timestamp: at);
    await branches.addConnection(
      branchId,
      RecordLink(
        id: '$branchId-war',
        sourceId: aster.id,
        targetId: varrow.id,
        typeId: 'atWarWith',
        scopeId: project,
        direction: RecordLinkDirection.undirected,
        createdAt: at,
        updatedAt: at,
      ),
      timestamp: at,
    );
  }

  Future<int> searchRows(String branchId) async => (await database.customSelect(
        'SELECT COUNT(*) AS n FROM author_search WHERE branch_id = ?',
        variables: [Variable<String>(branchId)],
      ).getSingle())
          .read<int>('n');

  setUp(() async {
    database = AuthorOsDatabase(NativeDatabase.memory());
    repository = DriftConnectedDomainRepository(database);
    final records = RecordService(projectId: project, repository: repository);
    aster = await records.createRecord(civilisation('aster', 'Aster'));
    varrow = await records.createRecord(civilisation('varrow', 'Varrow'));
    trade = await ConnectionEngine(
      scopeId: project,
      repository: repository,
      registry: await records.connectionRegistry(),
    ).connect(
      sourceId: aster.id,
      targetId: varrow.id,
      typeId: 'tradesWith',
      direction: RecordLinkDirection.undirected,
      timestamp: at,
    );
    branches = BranchService(projectId: project, repository: repository);
    await fill('keep');
    await fill('gone');
  });

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDown(() => database.close());

  /// Everything but the deleted branch's own rows, as JSON.
  Future<String> rest() async {
    final snapshot = await repository.snapshot();
    String lines(Iterable<Map<String, Object?>> rows) =>
        (rows.map(jsonEncode).toList()..sort()).join('\n');
    return [
      lines(snapshot.records.map((r) => r.toJson())),
      lines(snapshot.links.map((l) => l.toJson())),
      lines([
        for (final b in snapshot.branches)
          if (b.id != 'gone') b.toJson(),
      ]),
      lines([
        for (final o in snapshot.branchRecordOverlays)
          if (o.branchId != 'gone') o.toJson(),
      ]),
      lines([
        for (final o in snapshot.branchLinkOverlays)
          if (o.branchId != 'gone') o.toJson(),
      ]),
      lines([
        for (final v in snapshot.versions)
          if (v.branchId != 'gone') v.toJson(),
      ]),
      lines([
        for (final e in snapshot.auditEvents)
          if (e.branchId != 'gone') e.toJson(),
      ]),
    ].join('\n---\n');
  }

  test(
      'a deleted branch takes its overlays, history and search rows, and '
      'nothing else', () async {
    final before = await rest();
    final snapshot = await repository.snapshot();
    expect(snapshot.versions.where((v) => v.branchId == 'gone'), isNotEmpty);
    expect(await searchRows('gone'), greaterThan(0));
    final keptSearch = await searchRows('keep');

    final removed = await branches.deleteBranch('gone');

    final after = await repository.snapshot();
    expect(after.branches.map((b) => b.id), ['keep']);
    expect(await repository.branchRecordOverlays(['gone']), isEmpty);
    expect(await repository.branchLinkOverlays(['gone']), isEmpty);
    expect(after.versions.where((v) => v.branchId == 'gone'), isEmpty);
    expect(after.auditEvents.where((e) => e.branchId == 'gone'), isEmpty);
    expect(await searchRows('gone'), 0);
    expect(await searchRows('keep'), keptSearch);
    // Canon, canon's history and the other branch, byte for byte.
    expect(await rest(), before);
    // One branch, two record and two link overlays, and a version and an
    // audit event for each of those five.
    expect(removed, 15);
    // The other branch still resolves over canon.
    expect(
      (await branches.recordsForBranch('keep')).map((r) => r.title),
      containsAll(['Aster in keep', 'Ashen keep']),
    );
    // A second delete finds nothing.
    expect(await repository.deleteBranch('gone'), 0);
  });

  test('an archive written after a delete carries nothing of the branch',
      () async {
    await branches.deleteBranch('gone');
    const service = AuthorOsArchiveService();
    final bytes = service.exportSnapshot(
      await repository.snapshot(),
      archiveId: 'archive-1',
      rootId: project,
      applicationVersion: 'test',
      platform: 'test',
      createdAt: at,
    );
    final contents = service.importArchive(bytes);
    final snapshot = contents.snapshot;
    expect(snapshot.branches.map((b) => b.id), ['keep']);
    expect(
      snapshot.branchRecordOverlays.map((o) => o.branchId).toSet(),
      {'keep'},
    );
    expect(
      snapshot.branchLinkOverlays.map((o) => o.branchId).toSet(),
      {'keep'},
    );
    expect(snapshot.versions.where((v) => v.branchId == 'gone'), isEmpty);
    expect(snapshot.auditEvents.where((e) => e.branchId == 'gone'), isEmpty);

    // And restored into another database, the branch is not there either.
    final elsewhere = AuthorOsDatabase(NativeDatabase.memory());
    addTearDown(elsewhere.close);
    final restored = DriftConnectedDomainRepository(elsewhere);
    await restored.replaceSnapshot(snapshot);
    expect(
      (await restored.branchesByProject(project)).map((b) => b.id),
      ['keep'],
    );
  });
}
