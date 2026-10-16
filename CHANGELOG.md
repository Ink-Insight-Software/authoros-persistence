# Changelog

## 0.2.9

- **`DriftConnectedDomainRepository.deleteBranch`**, for authoros_core
  0.18.0's new repository method: removes a story branch, its record and
  link overlays, the versions and audit events filed under it and its
  search-index rows, in one transaction. Canon and other branches are
  untouched. Tested in `test/branch_delete_test.dart`, with an archive
  written after the delete.
- **The `authoros_core` pin has not moved yet**: it still names 0.17.0,
  which has no `deleteBranch`. Move it to the merge of the core's 0.18.0
  change when that lands; until then, build against it with a local
  `pubspec_overrides.yaml`.

## 0.2.8

- Pins `authoros_core` at 0.17.0 (`65a0c48`, the merge of
  authoros-core#18), which moves `BranchService` into the core and adds
  nine consequence rules. No code changed.

## 0.2.7

- Pins `authoros_core` at 0.16.0 (`9372516`, the merge of
  authoros-core#17), which moves Language Forge's model into the core and
  carries extension documents in the archive. No code changed.

## 0.2.6

- Pins `authoros_core` at 0.15.0 (`782b4d9`, the merge of
  authoros-core#16), which adds the faith-institution and law-and-war record
  types, four connection types, consequence traversal and the app-presence
  marker for AOS Worldsmith Phases 6 to 10. No code changed.

## 0.2.5

- Pins `authoros_core` at 0.13.0 (`b5cac09`, the merge of
  authoros-core#14), which adds the `title` and `estate` record types, union
  and parentage metadata, and moves the story graph into the core for AOS
  Worldsmith's Ancestry Room. No code changed.

## 0.2.4

- Pins `authoros_core` at 0.12.0 (`6945873`, the merge of
  authoros-core#12), which moves pinned records into the core, one
  collection per project, so AOS Worldsmith pins with the record AOS-Write's
  Story Codex uses. No code changed.

## 0.2.3

- Pins `authoros_core` at 0.11.0 (`1b2bc75`, the merge of
  authoros-core#11), which moves `ConnectionEngine` into the core so AOS
  Worldsmith can link records with it. No code changed.

## 0.2.2

- Pins `authoros_core` at 0.10.0 (`148df25`, the merge of
  authoros-core#10), which adds the `civilisation` record type and the
  `occupies` connection for AOS Worldsmith. No code changed.

## 0.2.1

- Pins `authoros_core` at 0.8.0 (`7959f25`, the merge of
  authoros-core#8), the core AOS-Write's AuthorOS Update 1.7.0 builds
  against. No code changed.

## 0.2.0

- **Its own repository**, moved from AOS-Write's
  `flutter-author-studio-v1/authoros_persistence/` with its history, so that
  AOS Worldsmith can depend on it. No code changed. The package is no longer
  a pub workspace member (`resolution: workspace` is gone), and gains a smoke
  test and CI.

## 0.1.0

- The four files of AOS-Write's `lib/persistence/`, moved into a package on
  September 28, 2026 (ADR-0028). Schema version 25 then; 27 at 0.2.0.
