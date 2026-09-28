# authoros_persistence

AuthorOS's project database, moved out of `lib/persistence/` on September 28,
2026 so that a standalone application opens projects with the same schema
rather than keeping a store of its own. The decision is
[ADR-0028](../docs/architecture/ADR-0028-the-record-store-is-a-shared-package.md).
The first application to need it is AOS Worldsmith, whose Phase 1 gate is to
create, save, reopen, back up and restore a project without AuthorOS Write.

## What is in it

The four files that were `lib/persistence/`:

- `authoros_database.dart`: `AuthorOsDatabase`, its 22 tables, its migrations
  (schema version 25) and `DriftConnectedDomainRepository`
- `authoros_database.g.dart`: its generated part
- `record_avatar.dart` and `voice_note_store.dart`: the two stores over the
  record-asset table

They moved unchanged apart from two things:

- **Their imports of the core** now name `package:authoros_core/...`.
- **The two stores take their database.** `RecordAvatarStore` and
  `VoiceNoteStore` used to fall back to AuthorOS Write's global database when
  given none. Every caller already passed one, so the fallback is gone and
  `database` is required.

It is a Flutter package, not pure Dart like `authoros_core`, because Drift
opens its file through `drift_flutter` and the avatar store decodes images
with `dart:ui`.

## What is not in it

**Which database file an application opens.** `authorOsDatabase` and
`authorOsRepository` stay in AuthorOS Write, in
`lib/persistence/authoros_database.dart`, beside the export of this package.
Every application calls `AuthorOsDatabase.defaults()`, or passes its own
executor, and holds its own globals.

**An application's own state.** No application may add a table here. What is
not a project record is kept in the application's own storage (ADR-0028,
*Consequences*).

**The web assets.** A browser build needs `sqlite3.wasm` and `drift_worker.js`
served beside `index.html`. Each application copies them in its own build with
`scripts/provision-drift-web-assets.sh`.

## How AuthorOS Write uses it

It is the workspace's third member, beside the application and
`authoros_core`, so there is still one resolution and one `pubspec.lock`.
`lib/persistence/` keeps an export for each file that moved, so no import in
the application changed.

**Source-reading tests must read this package**, since the exports have no
source to read. `test/support/source_tree.dart` lists `authoros_persistence/lib`
as a source root, and its `sourcePathFor` follows `lib/persistence/...` here.

## Regenerating the schema

```
cd authoros_persistence
dart run build_runner build --delete-conflicting-outputs
```

Run it here, where the part file lives. After the move it regenerated the
committed file byte for byte.
