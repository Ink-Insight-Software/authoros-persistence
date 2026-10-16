/// Reference files under the `reference` role, and every role read whole for
/// the archive and for copies.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:authoros_core/archive/authoros_archive.dart';
import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/record_asset.dart';
import 'package:authoros_core/research_reference.dart';
import 'package:authoros_persistence/authoros_database.dart';
import 'package:authoros_persistence/record_assets.dart';
import 'package:authoros_persistence/record_avatar.dart';
import 'package:authoros_persistence/research_reference_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 16, 9);
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
    '60e6kgAAAABJRU5ErkJggg==',
  );
  final pdf = Uint8List.fromList(utf8.encode('%PDF-1.7\nA chart.\n%%EOF'));

  late AuthorOsDatabase database;
  setUp(() => database = AuthorOsDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
      'a picked file is checked: pictures decode, PDFs pass, others are '
      'refused with a reason', () async {
    final picture = await ResearchReferenceFile.fromBytes(png);
    expect(picture.file?.mediaType, 'image/png');
    expect((picture.file?.width, picture.file?.height), (1, 1));

    final chart = await ResearchReferenceFile.fromBytes(pdf);
    expect(chart.file?.mediaType, 'application/pdf');
    expect(chart.file?.width, isNull);

    final text = await ResearchReferenceFile.fromBytes(
      Uint8List.fromList(utf8.encode('just words')),
    );
    expect(text.file, isNull);
    expect(text.refusal, contains('PDF'));

    final broken = await ResearchReferenceFile.fromBytes(
      Uint8List.fromList([...png.take(12)]),
    );
    expect(broken.refusal, 'That picture could not be opened.');

    final big = Uint8List(ResearchReferences.maxBytes + 1)
      ..setAll(0, utf8.encode('%PDF-'));
    expect((await ResearchReferenceFile.fromBytes(big)).refusal,
        contains('10 MB'));
  });

  test(
      'a reference file saves, describes itself without its bytes, and is '
      'removed without touching the avatar beside it', () async {
    final references = ResearchReferenceStore(database: database);
    final avatars = RecordAvatarStore(database: database);
    await references.save(
      'world-a',
      'reference-chart',
      ResearchReferenceFile(bytes: pdf, mediaType: 'application/pdf'),
      timestamp: at,
    );
    await references.save(
      'world-a',
      'reference-face',
      ResearchReferenceFile(
          bytes: png, mediaType: 'image/png', width: 1, height: 1),
      timestamp: at,
    );
    await avatars.save(
      'world-a',
      'reference-face',
      RecordAvatar(bytes: png, mediaType: 'image/png'),
      timestamp: at,
    );

    final loaded = await references.load('world-a', 'reference-chart');
    expect(loaded!.bytes, pdf);
    expect(loaded.isImage, isFalse);

    final info = await references.infoOf('world-a');
    expect(info.keys.toSet(), {'reference-chart', 'reference-face'});
    expect(info['reference-chart']!.byteLength, pdf.length);
    expect(info['reference-chart']!.updatedAt, at);
    expect(info['reference-chart']!.summary, 'PDF · 1 KB');
    expect(info['reference-face']!.summary, 'PNG · 1 x 1 · 1 KB');
    expect(await references.infoOf('world-b'), isEmpty);

    await references.remove('world-a', 'reference-face');
    expect(await references.load('world-a', 'reference-face'), isNull);
    expect(await avatars.load('world-a', 'reference-face'), isNotNull);

    expect(
      () => references.save(
        'world-a',
        'x',
        ResearchReferenceFile(bytes: Uint8List(0), mediaType: 'image/png'),
      ),
      throwsArgumentError,
    );
  });

  test('every role reads back whole, copies to new ids, and replaces',
      () async {
    final references = ResearchReferenceStore(database: database);
    await references.save(
      'world-a',
      'reference-chart',
      ResearchReferenceFile(bytes: pdf, mediaType: 'application/pdf'),
      timestamp: at,
    );
    final assets = RecordAssets(database: database);
    await assets.putAll([
      RecordAsset(
        projectId: 'world-a',
        recordId: 'character-aran',
        role: 'avatar',
        mediaType: 'image/png',
        bytes: png,
        width: 1,
        height: 1,
        updatedAt: at,
        extension: const {'crop': 'square'},
      ),
      RecordAsset(
        projectId: 'world-b',
        recordId: 'idea-1',
        role: 'voice',
        mediaType: 'audio/wav',
        bytes: Uint8List.fromList([1, 2, 3]),
        updatedAt: at,
      ),
    ]);

    final all = await assets.all();
    expect([
      for (final each in all) each.key
    ], [
      'world-a|character-aran|avatar',
      'world-a|reference-chart|reference',
      'world-b|idea-1|voice',
    ]);
    expect(all.first.extension, {'crop': 'square'});
    expect((await assets.ofProject('world-b')).single.role, 'voice');

    final copied = await assets.copyInto(
      await assets.ofProject('world-a'),
      to: 'world-c',
      recordIds: const {'reference-chart': 'reference-copy'},
    );
    expect(copied, 1, reason: 'the avatar has no copy, so it stays behind');
    final copy = await references.load('world-c', 'reference-copy');
    expect(copy!.bytes, pdf);
    expect(await references.load('world-a', 'reference-chart'), isNotNull);

    await assets.replaceAll([all.last]);
    expect([for (final each in await assets.all()) each.key],
        ['world-b|idea-1|voice']);
  });

  test('assets go into an archive and back into another database', () async {
    final assets = RecordAssets(database: database);
    final references = ResearchReferenceStore(database: database);
    await references.save(
      'world-a',
      'reference-chart',
      ResearchReferenceFile(bytes: pdf, mediaType: 'application/pdf'),
      timestamp: at,
    );
    const archives = AuthorOsArchiveService();
    final bytes = archives.exportSnapshot(
      const ConnectedDomainSnapshot(
        records: [],
        manuscriptNodes: [],
        links: [],
      ),
      archiveId: 'a',
      rootId: 'world-a',
      applicationVersion: 'test',
      platform: 'test',
      createdAt: at,
      recordAssets: await assets.all(),
    );

    final other = AuthorOsDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await RecordAssets(database: other)
        .replaceAll(archives.importArchive(bytes).recordAssets);
    final back = await ResearchReferenceStore(database: other)
        .load('world-a', 'reference-chart');
    expect(back!.bytes, pdf);
    expect(back.mediaType, 'application/pdf');
    expect(back.updatedAt, at);
  });
}
