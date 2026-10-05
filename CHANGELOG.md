# Changelog

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
