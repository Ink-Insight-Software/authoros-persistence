/// The package works on its own: a project written through it reads back.
///
/// AuthorOS Write's suite exercises the database in depth. This is the check
/// that the package needs nothing from any application to open, write and
/// read a project.
library;

import 'package:authoros_core/project_roster_entry.dart';
import 'package:authoros_core/starter_project.dart';
import 'package:authoros_persistence/authoros_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a project written to the roster reads back with its kind', () async {
    final database = AuthorOsDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftConnectedDomainRepository(database);
    final at = DateTime.utc(2026, 10, 4);

    await repository.putProjectRosterEntry(
      ProjectRosterEntry(
        project: const StarterProject(
          id: 'world-1',
          title: 'The Ashen Reach',
          genre: 'Fantasy',
          projectType: 'world',
          wordGoal: 0,
          acts: [],
          chapters: [],
          characterSheets: [],
          beatChecklist: [],
          firstSceneTitle: 'Opening Scene',
        ),
        createdAt: at,
        updatedAt: at,
      ),
    );

    final roster = await repository.projectRoster();
    expect(roster.map((entry) => entry.projectId), ['world-1']);
    expect(roster.single.title, 'The Ashen Reach');
    expect(roster.single.project.projectType, 'world');
  });

  test('a new database is at the current schema version', () {
    final database = AuthorOsDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    expect(database.schemaVersion, AuthorOsDatabase.currentSchemaVersion);
  });
}
