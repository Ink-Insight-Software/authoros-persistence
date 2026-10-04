# Changelog

## 0.2.0

- **Its own repository**, moved from AOS-Write's
  `flutter-author-studio-v1/authoros_persistence/` with its history, so that
  AOS Worldsmith can depend on it. No code changed. The package is no longer
  a pub workspace member (`resolution: workspace` is gone), and gains a smoke
  test and CI.

## 0.1.0

- The four files of AOS-Write's `lib/persistence/`, moved into a package on
  September 28, 2026 (ADR-0028). Schema version 25 then; 27 at 0.2.0.
