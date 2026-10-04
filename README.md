# authoros_persistence

**AuthorOS's project database, and its one copy.** The Drift schema, its
migrations and `DriftConnectedDomainRepository`. AuthorOS Write and the
standalone applications open their projects through it, so a project written
by one opens in another with the same schema; none of them keeps a store of
its own (AOS-Write ADR-0028).

It moved here from `flutter-author-studio-v1/authoros_persistence/` in
`Ink-Insight-Software/AOS-Write` on October 4, 2026, with its history. Before
that it was a member of AOS-Write's workspace, which no other repository can
read: AOS-Write is private. It moved for the reason `authoros_core` did, so
that AOS Worldsmith (`Ink-Insight-Software/AuthorOS-Expansions`) can depend on
it from its CI and its web build with no credential.

**A change to the database is made here first.** It reaches an application
only when that application moves its pin, and that application's suite runs
against it before it ships.

## Using it

Depend on a commit, never a branch:

```yaml
dependencies:
  authoros_persistence:
    git:
      url: https://github.com/Ink-Insight-Software/authoros-persistence.git
      ref: <commit>
  authoros_core:
    git:
      url: https://github.com/Ink-Insight-Software/authoros-core.git
      ref: <the commit this package's pubspec.yaml pins>
```

**Pin `authoros_core` at the commit this package pins.** Two git refs for one
package do not resolve, so pub reports the conflict rather than building two
cores. Move both pins together.

## What is in it

- `authoros_database.dart`: `AuthorOsDatabase`, its 22 tables, its migrations
  (schema version 27) and `DriftConnectedDomainRepository`
- `authoros_database.g.dart`: its generated part
- `record_avatar.dart` and `voice_note_store.dart`: the two stores over the
  record-asset table. Each takes its database; neither falls back to a global.

It is a Flutter package, not pure Dart like `authoros_core`, because Drift
opens its file through `drift_flutter` and the avatar store decodes images
with `dart:ui`.

## What is not in it

**Which database file an application opens.** Each application calls
`AuthorOsDatabase.defaults()`, or passes its own executor, and holds its own
globals. AuthorOS Write keeps `authorOsDatabase` and `authorOsRepository` in
its `lib/persistence/authoros_database.dart`.

**An application's own state.** No application may add a table here. What is
not a project record is kept in the application's own storage (ADR-0028,
*Consequences*).

**The web assets.** A browser build needs `sqlite3.wasm` and `drift_worker.js`
served beside `index.html`, matching the resolved `drift`. Each application
copies them in its own build; AOS-Write's `scripts/provision-drift-web-assets.sh`
is the reference.

## Working on it

```
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after a schema change
```

The generated part is committed. A schema change bumps
`AuthorOsDatabase.currentSchemaVersion` and adds its migration step.
