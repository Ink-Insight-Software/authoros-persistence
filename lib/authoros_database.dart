import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:drift_flutter/drift_flutter.dart';

import 'package:authoros_core/connected_domain.dart';
import 'package:authoros_core/connected_domain_repository.dart';
import 'package:authoros_core/connection_types.dart';
import 'package:authoros_core/prose_document.dart';
import 'package:authoros_core/built_in_record_types.dart';
import 'package:authoros_core/record_types.dart';
import 'package:authoros_core/relationship_validation.dart';
import 'package:authoros_core/branch_domain.dart';
import 'package:authoros_core/search_models.dart';
import 'package:authoros_core/version_audit.dart';
import 'package:authoros_core/progression/progression_domain.dart';
import 'package:authoros_core/project_roster_entry.dart';
import 'package:authoros_core/revision_decision.dart';
import 'package:authoros_core/scene_prose.dart';
import 'package:authoros_core/scene_revision.dart';
import 'package:authoros_core/starter_project.dart';
import 'package:authoros_core/writing_goals.dart';
import 'package:authoros_core/writing_series.dart';
import 'package:authoros_core/writing_session.dart';

part 'authoros_database.g.dart';

class ConnectedEntities extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get scopeId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'author_records_type', columns: {#typeId})
@TableIndex(name: 'author_records_scope', columns: {#scopeId})
@TableIndex(name: 'author_records_project', columns: {#projectId})
@TableIndex(name: 'author_records_series_book', columns: {#seriesId, #bookId})
@TableIndex(name: 'author_records_branch', columns: {#branchId})
class AuthorRecordRows extends Table {
  TextColumn get id => text().references(ConnectedEntities, #id)();
  TextColumn get typeId => text()();
  TextColumn get scopeType => text()();
  TextColumn get scopeId => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get bookId => text().nullable()();
  TextColumn get branchId => text().nullable()();
  TextColumn get canonStatus => text().nullable()();
  TextColumn get title => text()();
  TextColumn get status => text()();
  IntColumn get schemaVersion => integer()();
  TextColumn get templateId => text().nullable()();
  IntColumn get templateVersion => integer().nullable()();
  IntColumn get revision => integer()();
  TextColumn get fieldsJson => text()();
  TextColumn get tagsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get extensionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'manuscript_nodes_project', columns: {#projectId})
class ManuscriptNodeRows extends Table {
  TextColumn get id => text().references(ConnectedEntities, #id)();
  TextColumn get projectId => text()();
  TextColumn get nodeType => text()();
  TextColumn get title => text()();
  IntColumn get revision => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get extensionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'record_links_source', columns: {#sourceId})
@TableIndex(name: 'record_links_target', columns: {#targetId})
@TableIndex(name: 'record_links_scope', columns: {#scopeId})
class RecordLinkRows extends Table {
  TextColumn get id => text()();
  @ReferenceName('sourceLinks')
  TextColumn get sourceId => text().references(ConnectedEntities, #id)();
  @ReferenceName('targetLinks')
  TextColumn get targetId => text().references(ConnectedEntities, #id)();
  TextColumn get typeId => text()();
  TextColumn get scopeId => text()();
  TextColumn get direction => text()();
  TextColumn get label => text()();
  IntColumn get revision => integer()();
  TextColumn get metadataJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get extensionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'record_type_definitions_category', columns: {#categoryId})
@TableIndex(
  name: 'record_type_definitions_scope',
  columns: {#scopeType, #scopeId},
)
class RecordTypeDefinitionRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  TextColumn get baseTypeId => text().nullable()();
  TextColumn get scopeType => text()();
  TextColumn get scopeId => text()();
  IntColumn get templateVersion => integer()();
  BoolColumn get builtIn => boolean()();
  TextColumn get definitionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'connection_type_definitions_scope', columns: {#scopeId})
class ConnectionTypeDefinitionRows extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get scopeId => text()();
  BoolColumn get builtIn => boolean()();
  TextColumn get definitionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id, scopeId};
}

@TableIndex(name: 'story_branches_project', columns: {#projectId})
@TableIndex(name: 'story_branches_parent', columns: {#parentBranchId})
class StoryBranchRows extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get parentBranchId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get status => text()();
  TextColumn get branchJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'branch_record_overlays_branch', columns: {#branchId})
class BranchRecordOverlayRows extends Table {
  TextColumn get branchId => text().references(StoryBranchRows, #id)();
  TextColumn get recordId => text()();
  TextColumn get state => text()();
  TextColumn get overlayJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {branchId, recordId};
}

@TableIndex(name: 'branch_link_overlays_branch', columns: {#branchId})
class BranchLinkOverlayRows extends Table {
  TextColumn get branchId => text().references(StoryBranchRows, #id)();
  TextColumn get linkId => text()();
  TextColumn get state => text()();
  TextColumn get overlayJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {branchId, linkId};
}

@TableIndex(name: 'record_versions_entity', columns: {#projectId, #entityId})
@TableIndex(name: 'record_versions_record', columns: {#projectId, #recordId})
@TableIndex(name: 'record_versions_branch', columns: {#projectId, #branchId})
@TableIndex(name: 'record_versions_created', columns: {#projectId, #createdAt})
class RecordVersionRows extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text()();
  TextColumn get entityKind => text()();
  TextColumn get recordId => text()();
  TextColumn get recordType => text()();
  TextColumn get projectId => text()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get bookId => text().nullable()();
  TextColumn get branchId => text().nullable()();
  TextColumn get changeType => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get previousVersionId => text().nullable()();
  TextColumn get versionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'audit_events_entity', columns: {#projectId, #entityId})
@TableIndex(name: 'audit_events_record', columns: {#projectId, #recordId})
@TableIndex(
    name: 'audit_events_series_book', columns: {#projectId, #seriesId, #bookId})
@TableIndex(name: 'audit_events_branch', columns: {#projectId, #branchId})
@TableIndex(name: 'audit_events_change', columns: {#projectId, #changeType})
@TableIndex(name: 'audit_events_created', columns: {#projectId, #createdAt})
class AuditEventRows extends Table {
  TextColumn get id => text()();
  TextColumn get versionId => text()();
  TextColumn get entityId => text()();
  TextColumn get entityKind => text()();
  TextColumn get recordId => text()();
  TextColumn get recordType => text()();
  TextColumn get projectId => text()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get bookId => text().nullable()();
  TextColumn get branchId => text().nullable()();
  TextColumn get changeType => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get eventJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Durable writing-session history.
///
/// Dedicated to that one job: it holds no manuscript text, joins to no
/// record, and is never rewritten. Rows are project-scoped and immutable —
/// a session is what happened, not a view of current state — so writes use
/// insert-or-ignore and later manuscript edits can never revise history.
///
/// Timestamps use drift's `dateTime()` representation: an absolute instant
/// stored as Unix epoch seconds, read back as a local `DateTime`. Calendar
/// questions (today, this week, streaks) are then answered in the author's
/// own local time by `WritingCalendar`.
@TableIndex(name: 'writing_sessions_project', columns: {#projectId})
@TableIndex(
  name: 'writing_sessions_project_started',
  columns: {#projectId, #startedAt},
)
class WritingSessionRows extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get startingWordCount => integer()();
  IntColumn get endingWordCount => integer()();
  IntColumn get wordsAdded => integer()();
  IntColumn get wordsRemoved => integer()();
  TextColumn get chapterId => text().nullable()();
  TextColumn get sceneId => text().nullable()();

  /// Words that arrived in this session without being typed.
  ///
  /// Nullable, and null is load-bearing: it means *nobody was counting*, not
  /// *nothing was pasted*. Every session written before schema 19 carries null
  /// for ever, and progression credits those words in full rather than taking
  /// work away from an author retroactively.
  IntColumn get pastedWords => integer().nullable()();

  /// The AOS Unblocked family whose question opened this session, if one did.
  ///
  /// Null is the ordinary case and means *the author just started writing* —
  /// not that the question failed. Every session written before schema 22
  /// carries null for ever, and every session begun from the manuscript rather
  /// than from a provocation carries null too.
  ///
  /// Stored as `ProvocationFamily.name` rather than its index, so reordering
  /// the enum cannot silently re-label a career's worth of history. Core owns
  /// the vocabulary; this column only records which word was used.
  ///
  /// This is the one measurement the room's whole roadmap waits on. The
  /// engine's design says the reassessment — *which families actually get
  /// someone typing* — is not code, and it was not, because nothing recorded
  /// the pairing. It is a fact about a writing session, not canon derived from
  /// one, so I-9 is untouched: no provocation is written back as a record.
  TextColumn get provocationFamily => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// What the author decided about a finding.
///
/// The table [ADR-0011](../../docs/architecture/ADR-0011-author-decisions-about-findings.md)
/// settled on, and it sits directly beneath `writing_session_rows` because it
/// is the same shape of thing: operational data that is archived without being
/// a node. **Being archived is not being a node.** No foreign key into
/// `connected_entities`, no registered record type, no connection type taking a
/// decision as an endpoint — invariant I-16, and the guard in
/// `test/story_graph_architecture_test.dart` holds all three.
///
/// A record type was refused rather than overlooked. A 120,000-word manuscript
/// produces thousands of findings, and a dismissal that were an `AuthorRecord`
/// would flood the story graph with thousands of nodes that are not story:
/// Lock 3's two-thousand-trees corollary, which is stated as a corollary
/// precisely because it has already caught a real bug.
///
/// **Not append-only, and that is the one place it departs from the table above
/// it.** A session is what happened; a decision is what the author currently
/// thinks, so re-deciding must replace rather than accumulate. `id` is derived
/// from `(projectId, kind, subject)` rather than minted from a clock, which
/// makes an upsert on the primary key the whole of that mechanism.
///
/// `sceneId` and `chapterId` are **nullable soft pointers**. Proximity without
/// participation: a scene deleted out from under a decision leaves a dangling
/// string and breaks nothing.
@TableIndex(name: 'revision_decisions_project', columns: {#projectId})
@TableIndex(
  name: 'revision_decisions_project_kind',
  columns: {#projectId, #kind},
)
class RevisionDecisionRows extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();

  /// `RevisionDecisionKind.name` — a string, so adding a sixth kind can never
  /// make an old row undecodable, and reordering the enum can never re-label a
  /// decision the author made.
  TextColumn get kind => text()();

  /// What the decision is about: the rule, the term, the pass, or the pair.
  /// Built by `RevisionDecisionSubject`, which is where the keying rules and
  /// the argument for them live.
  TextColumn get subject => text()();

  /// Where the author decided, when they decided somewhere. No foreign key.
  TextColumn get sceneId => text().nullable()();
  TextColumn get chapterId => text().nullable()();

  /// The decision itself: dismissed, must-fix, not-for-this-book, complete,
  /// deliberate — or the spelling the author accepted, in their own characters.
  TextColumn get value => text()();
  DateTimeColumn get decidedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Binary assets an author attached to a book.
///
/// Cover art is the first and, in Phase 2, the only one. It lives here rather
/// than beside the rest of the book's settings because those settings are a
/// JSON blob in shared preferences, which on the web is `localStorage` — a
/// roughly five-megabyte quota for the whole origin, shared with the author's
/// prose. A cover is hundreds of kilobytes of binary, so storing it there could
/// fail to save or crowd out the manuscript itself. The embedded database is
/// SQLite over IndexedDB in the browser and has no such ceiling.
///
/// This is an authored asset, not graph truth: it is never the endpoint of a
/// `RecordLink` and it participates in nothing. See the note beside it in
/// `test/story_graph_architecture_test.dart`.
class BookAssetRows extends Table {
  TextColumn get projectId => text()();

  /// Which asset this is. 'cover' today.
  TextColumn get role => text()();

  /// The IANA type, sniffed from the file's own magic bytes on import.
  TextColumn get mediaType => text()();

  BlobColumn get bytes => blob()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get extensionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {projectId, role};
}

/// Binary assets an author attached to a single record.
///
/// Character avatars are the first. This is the per-record counterpart to
/// [BookAssetRows], and exists for the same reason: an image is binary and
/// belongs in the database rather than in the shared-preferences blob that is
/// `localStorage` on the web.
///
/// It replaces storing a *path* to the author's own file, which could not
/// survive being reopened. A desktop path breaks the moment the picture is
/// moved or the project is opened on another machine, and the browser's file
/// picker hands back an object URL that dies with the tab. Keeping the bytes is
/// what makes an avatar something the project owns rather than a reference to
/// something it does not.
///
/// This is an authored asset, not graph truth: it is never the endpoint of a
/// `RecordLink` and it participates in nothing. See the note beside it in
/// `test/story_graph_architecture_test.dart`. [recordId] is a plain column and
/// deliberately not a foreign key — the same choice the rest of this schema
/// makes — so an avatar is cleaned up by the delete path rather than by a
/// cascade the graph cannot see.
class RecordAssetRows extends Table {
  TextColumn get projectId => text()();

  /// The record this belongs to. Not a foreign key; see the note above.
  TextColumn get recordId => text()();

  /// Which asset this is. 'avatar' today.
  TextColumn get role => text()();

  /// The IANA type, sniffed from the file's own magic bytes on import.
  TextColumn get mediaType => text()();

  BlobColumn get bytes => blob()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get extensionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {projectId, recordId, role};
}

/// One project's daily, weekly, and monthly word targets.
///
/// Keyed by the project id rather than a surrogate id, because a project has
/// exactly one set of goals: the schema itself enforces what would otherwise
/// be an invariant the write path had to remember. That also makes a save a
/// plain upsert with no read-modify-write.
///
/// Unlike [WritingSessionRows], this table is overwritten rather than appended
/// to. A session is a historical fact; a goal is the target the author holds
/// right now, and editing it must replace what was there.
///
/// A project with no row here has never had its goals edited and resolves to
/// [WritingGoals.seedDefaults]. Reading never inserts a row, so "never
/// customized" stays distinguishable from "customized back to the defaults".
class WritingGoalRows extends Table {
  TextColumn get projectId => text()();
  IntColumn get dailyWords => integer()();
  IntColumn get weeklyWords => integer()();
  IntColumn get monthlyWords => integer()();

  /// Words meant for one sitting, and words meant for one chapter. `0` in
  /// either means the author has set no such goal.
  ///
  /// Defaulted rather than nullable because zero already carries that meaning
  /// in `WritingGoals` — `hasSessionGoal` is `sessionWords > 0` — so a null
  /// would be a second way to say the same thing, and the readers would then
  /// have to agree about which one they wrote. A row that predates version 25
  /// takes 0 and reads back as "no goal", which is what it always was.
  IntColumn get sessionWords => integer().withDefault(const Constant(0))();
  IntColumn get chapterWords => integer().withDefault(const Constant(0))();

  /// The day the author means to finish by, or null when they have set none.
  ///
  /// Nullable, unlike the two above, because there is no date that means "no
  /// deadline" — every instant is a real day an author could have chosen.
  ///
  /// `WritingGoals.normalized` floors this to local midnight before it is
  /// written, so the column holds a date rather than an instant. Nothing here
  /// re-derives that: a deadline that arrived through sync is normalised by
  /// the same code on the way in.
  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

/// The author's named series.
///
/// Deliberately small: a name and the target a joining book inherits. A series
/// owns no books of its own — membership lives on [ProjectRows], because a
/// book is a project, and a project already knows its title and its target.
///
/// This is library structure, not graph truth. AuthorOS forbids record links
/// across projects, so a series could never have been an edge between books in
/// the first place.
class SeriesRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get defaultTargetWords => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The author's projects — the roster that lets AuthorOS hold more than one
/// book at a time.
///
/// Before this table the app stored exactly one project, in a single
/// preferences key, and saving a second overwrote the first. The roster is
/// additive: `author_studio.starter_project` remains the pointer to whichever
/// project is currently open, and this table is the durable list of every
/// project that exists.
///
/// [payloadJson] holds the whole `StarterProject` rather than exploding it
/// into columns, because it is seed data — chapters, character sheets, acts —
/// that nothing queries by field. Title and word target are read from it, so
/// there is exactly one definition of each.
///
/// [seriesId] and [seriesPosition] are what make a project a book: a project
/// with no series is a standalone novel, which the domain must keep
/// supporting.
@TableIndex(
    name: 'projects_series_position', columns: {#seriesId, #seriesPosition})
class ProjectRows extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  TextColumn get seriesId => text().nullable()();
  IntColumn get seriesPosition => integer().nullable()();

  /// When the author archived this project, or NULL while it is active.
  ///
  /// A column rather than a flag inside [payloadJson], because "which projects
  /// are still in front of me" is a question the roster has to answer in SQL.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// The author profile this project belongs to.
  ///
  /// Nullable, and null is a real state: a project written before ownership
  /// existed. An account can hold several pen names, so those rows cannot be
  /// attributed by guessing — see `ProjectRosterEntry.profileId`.
  TextColumn get profileId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Durable prose history, scene by scene.
///
/// The first place in AuthorOS that has ever kept a copy of a scene's words
/// after they were overwritten. [RecordVersionRows] holds manuscript *nodes* —
/// titles, statuses, metadata — and `ManuscriptService.restoreVersion` says in
/// its own doc comment that it does not roll prose back, because the snapshot
/// it stores has never contained any.
///
/// Append-only, like [WritingSessionRows] and for the same reason: a revision
/// is what the scene said at a moment, not a view of current state, so writes
/// use insert-or-ignore and no later edit can revise it. Unlike sessions it is
/// pruned, by [SceneRevisionRetention] — history that grew without bound would
/// eventually hold more prose than the manuscript it protects.
///
/// [contentDigest] is what makes the recorder cheap: it answers "has this
/// scene changed since its last snapshot?" without reading a single stored
/// body back out.
///
/// Deliberately project-scoped and deliberately not synced. See
/// `core/scene_revision.dart` for why history stays on the device that made
/// it.
@TableIndex(name: 'scene_revisions_scene', columns: {#projectId, #sceneId})
@TableIndex(
  name: 'scene_revisions_scene_captured',
  columns: {#projectId, #sceneId, #capturedAt},
)
class SceneRevisionRows extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get sceneId => text()();
  TextColumn get chapterId => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get contentDigest => text()();
  IntColumn get wordCount => integer()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get trigger => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Continuity findings the author has resolved.
///
/// The one genuinely missing recorder in AuthorOS, and it is a recorder rather
/// than a reader for a reason worth stating: resolving a continuity warning
/// *does* leave a trace today — a record was created, or a link was made, and
/// both write audit events. What no trace says is **why**. Nothing distinguishes
/// "the author created a character" from "the author created a character to
/// close an unknown-character warning", and the second is the accomplishment.
///
/// This is deliberately not folded into `audit_event_rows`. Every audit event
/// carries a `versionId` and an `AuditChangeType`, and that enum describes ways
/// a *record* changed. A resolution is a statement about a finding, and a
/// finding has no entity row and no version — writing one there would mean
/// inventing both.
///
/// Append-only, one row per resolution, written only when a recheck confirms
/// the warning is actually gone. An action that saved successfully but left the
/// warning standing is not a resolution and writes nothing.
///
/// Per-install, like the progression ledger and for the same reason: it is
/// evidence of work done on this device, and it is not carried in the archive.
class ContinuityResolutionRows extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();

  /// `ContinuityWarningType.name` — stored as a string so adding a warning
  /// type can never make an old row undecodable.
  TextColumn get warningType => text()();

  /// `ContinuityActionKind.name`: how the author closed it.
  TextColumn get actionKind => text()();

  /// The record created, where the action created one.
  TextColumn get recordId => text().nullable()();

  /// The link made, where the action made one.
  TextColumn get linkId => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The author's progression state — the only three things about progression
/// that are stored rather than derived.
///
/// Everything else the Achievement Program reports is a pure fold over
/// recorded creative history, recomputed on every read. These two tables hold
/// what a fold cannot recover:
///
/// * **when** an achievement was first earned. Derivation can say the criteria
///   hold today; only a ledger can say they first held in March.
/// * **the XP high-water mark**, so deleting a finished project never demotes
///   the author who finished it.
/// * **the author's reward-tree selection**, which is a choice and not a
///   consequence.
///
/// The first two are *floors, not caches*: derivation runs first, and a floor
/// is consulted only where the answer would otherwise go backwards.
///
/// One row, keyed on a constant. Progression is career-scoped rather than
/// project-scoped — the question is "how far has this author come", not "how
/// far has this book come" — and a career has exactly one answer per install.
class ProgressionStateRows extends Table {
  /// Always [ProgressionStateRows.careerKey]. A single-row table still needs a
  /// primary key, and a constant one makes the upsert idempotent.
  TextColumn get id => text()();
  IntColumn get xpFloor => integer()();

  /// The chosen reward node ids, as a JSON array. Stored as a document rather
  /// than a join table because the selection is read and written whole, is
  /// never queried across authors, and has no meaning split apart.
  TextColumn get rewardSelectionJson => text()();

  /// Which of the owned rewards the author is wearing, as a JSON object of
  /// slot key to node id. Nullable because it arrived after this table did,
  /// and null reads the same as an empty object: nothing applied, which is the
  /// look AuthorOS ships with rather than a missing one.
  TextColumn get rewardLoadoutJson => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// The one row's id.
  static const String careerKey = 'career';
}

/// The unlock ledger: the first instant each achievement's criteria held.
///
/// Append-only in effect. Rows are written with insert-or-ignore, so replaying
/// a load can never move an unlock date later — which is the same rule the
/// engine applies when it folds duplicate entries, stated twice on purpose
/// because the two layers fail differently.
class ProgressionUnlockRows extends Table {
  TextColumn get achievementId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {achievementId};
}

@DriftDatabase(
  tables: [
    ConnectedEntities,
    AuthorRecordRows,
    ManuscriptNodeRows,
    RecordLinkRows,
    RecordTypeDefinitionRows,
    ConnectionTypeDefinitionRows,
    StoryBranchRows,
    BranchRecordOverlayRows,
    BranchLinkOverlayRows,
    RecordVersionRows,
    AuditEventRows,
    WritingSessionRows,
    RevisionDecisionRows,
    BookAssetRows,
    RecordAssetRows,
    WritingGoalRows,
    SeriesRows,
    ProjectRows,
    SceneRevisionRows,
    ProgressionStateRows,
    ProgressionUnlockRows,
    ContinuityResolutionRows,
  ],
)
class AuthorOsDatabase extends _$AuthorOsDatabase {
  AuthorOsDatabase(
    super.executor, {
    int schemaVersion = currentSchemaVersion,
  }) : _schemaVersion = schemaVersion;

  AuthorOsDatabase.defaults()
      : _schemaVersion = currentSchemaVersion,
        super(driftDatabase(
          name: 'authoros_creative',
          web: webOptions,
        ));

  /// Where the browser build finds sqlite.
  ///
  /// On Windows, macOS, Linux and mobile, drift opens a SQLite file through
  /// the platform's own bindings and these options are ignored. The browser
  /// has no such bindings, so drift runs SQLite as WebAssembly instead, backed
  /// by OPFS or IndexedDB. It needs two files served next to `index.html` to
  /// do it, and `driftDatabase` throws without them — which is what left every
  /// Drift-backed Studio reporting "unavailable" on the web.
  ///
  /// Both files are copied out of the resolved `drift` package by
  /// `scripts/provision-drift-web-assets.sh`, so they always match the version
  /// in `pubspec.lock`. Nothing above this line changes: the Studios still
  /// talk to the same [DriftConnectedDomainRepository] on every platform.
  static final DriftWebOptions webOptions = DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  );

  static const currentSchemaVersion = 25;
  final int _schemaVersion;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          if (schemaVersion >= 2) {
            await _createSearchIndex();
          }
          if (schemaVersion >= 13) {
            await _createSceneProseTable();
          }
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2 && to >= 2) {
            await _createSearchIndex();
            await _rebuildSearchIndex();
          }
          if (from < 3 && to >= 3) {
            await migrator.createTable(recordTypeDefinitionRows);
          }
          if (from < 4 && to >= 4) {
            await migrator.createTable(connectionTypeDefinitionRows);
          }
          if (from < 5 && to >= 5) {
            final columns = await customSelect(
              'PRAGMA table_info(author_record_rows)',
            ).get();
            final names =
                columns.map((row) => row.read<String>('name')).toSet();
            if (!names.contains('template_id')) {
              await migrator.addColumn(
                authorRecordRows,
                authorRecordRows.templateId,
              );
            }
            if (!names.contains('template_version')) {
              await migrator.addColumn(
                authorRecordRows,
                authorRecordRows.templateVersion,
              );
            }
          }
          if (from < 6 && to >= 6) {
            final columns = await customSelect(
              'PRAGMA table_info(author_record_rows)',
            ).get();
            final names =
                columns.map((row) => row.read<String>('name')).toSet();
            final additions = <String, GeneratedColumn>{
              'project_id': authorRecordRows.projectId,
              'series_id': authorRecordRows.seriesId,
              'book_id': authorRecordRows.bookId,
              'branch_id': authorRecordRows.branchId,
              'canon_status': authorRecordRows.canonStatus,
            };
            for (final entry in additions.entries) {
              if (!names.contains(entry.key)) {
                await migrator.addColumn(authorRecordRows, entry.value);
              }
            }
            await migrator.createTable(storyBranchRows);
            await migrator.createTable(branchRecordOverlayRows);
            await migrator.createTable(branchLinkOverlayRows);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS author_records_project '
              'ON author_record_rows(project_id)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS author_records_series_book '
              'ON author_record_rows(series_id, book_id)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS author_records_branch '
              'ON author_record_rows(branch_id)',
            );
          }
          if (from < 7 && to >= 7) {
            await customStatement('DROP TABLE IF EXISTS author_search');
            await _createSearchIndex();
            await _rebuildSearchIndex();
          }
          if (from < 8 && to >= 8) {
            await migrator.createTable(recordVersionRows);
            await migrator.createTable(auditEventRows);
          }
          if (from < 9 && to >= 9) {
            await migrator.createTable(writingSessionRows);
          }
          if (from < 10 && to >= 10) {
            await migrator.createTable(writingGoalRows);
          }
          if (from < 11 && to >= 11) {
            await migrator.createTable(seriesRows);
            await migrator.createTable(projectRows);
          }
          if (from < 12 && to >= 12) {
            await migrator.createTable(sceneRevisionRows);
          }
          if (from < 13 && to >= 13) {
            await _createSceneProseTable();
          }
          // Book Studio cover art and export snapshots. Numbered 14 rather
          // than the 10 it was written as: main claimed 10 through 13 while
          // this branch was open, and a step keyed on a version another
          // migration already passed would never run.
          if (from < 14 && to >= 14) {
            await migrator.createTable(bookAssetRows);
          }
          // The backfill version 6 never wrote. See
          // [_backfillCanonicalOwnership].
          if (from < 15 && to >= 15) {
            await _backfillCanonicalOwnership();
          }
          if (from < 16 && to >= 16) {
            await migrator.createTable(recordAssetRows);
          }
          if (from < 17 && to >= 17) {
            // Added nullable, and existing rows are deliberately left null
            // rather than stamped with a profile here. This layer has no
            // business reading the roster of pen names, and an account holding
            // more than one has no correct answer to guess. The one
            // unambiguous case — exactly one profile — is adopted in
            // `ProjectRosterStore.adoptUnownedProjects`.
            //
            // Guarded like the v5 step above, and for a reason worth stating:
            // `onCreate` runs `createAll()`, which builds the *current* table
            // shape whatever version the database is opened at. A file created
            // at an older version by this binary therefore already has the
            // column, and an unguarded ADD COLUMN fails on it with "duplicate
            // column name". Production upgrades never hit that — the old file
            // was written by an old binary — but every migration fixture in
            // the suite does, which is how a green migration can hide behind a
            // wall of unrelated red.
            final columns = await customSelect(
              'PRAGMA table_info(project_rows)',
            ).get();
            final names =
                columns.map((row) => row.read<String>('name')).toSet();
            if (!names.contains('profile_id')) {
              await migrator.addColumn(projectRows, projectRows.profileId);
            }
          }
          // Archiving a project. Written as 17 while this branch was open;
          // main claimed 17 for `profile_id` in the meantime, and a step keyed
          // on a version another migration already passed would never run.
          //
          // Guarded by the same PRAGMA read as the step above, for the same
          // reason: `onCreate` builds the current table shape whatever version
          // the database is opened at, so a fixture created at an older
          // version already has the column and an unguarded ADD COLUMN fails
          // on it.
          if (from < 18 && to >= 18) {
            final columns = await customSelect(
              'PRAGMA table_info(project_rows)',
            ).get();
            final names =
                columns.map((row) => row.read<String>('name')).toSet();
            if (!names.contains('archived_at')) {
              await migrator.addColumn(projectRows, projectRows.archivedAt);
            }
          }
          // Pasted words, so a session can say how its words arrived. Written
          // as 17 while this branch was open; `profile_id` took 17 and
          // `archived_at` took 18 in the meantime, so this is 19 — the third
          // time this tree has had to renumber a step whose version another
          // migration reached first.
          //
          // Asked first, because `createTable` above is CREATE TABLE IF NOT
          // EXISTS and builds from *today's* definition — so a file that
          // reached this migrator through an earlier step, or a test fixture
          // that stamped an old version onto a current schema, may already
          // carry the column. `addColumn` has no IF NOT EXISTS and fails the
          // whole migration on a duplicate name.
          //
          // Existing rows take null: their words were recorded before anything
          // could tell how they arrived, and null is how the session layer
          // says so.
          if (from < 19 && to >= 19) {
            if (!await _hasColumn('writing_session_rows', 'pasted_words')) {
              await migrator.addColumn(
                writingSessionRows,
                writingSessionRows.pastedWords,
              );
            }
          }

          // The Achievement Program's storage. Two new tables rather than
          // columns, so this is `createTable` and needs no PRAGMA guard: drift
          // emits CREATE TABLE IF NOT EXISTS, which is already idempotent
          // against a fixture that stamped an old version onto a current
          // schema.
          //
          // No backfill, and deliberately so. An install upgrading to 20 has a
          // career's worth of writing history and no ledger, and the honest
          // starting state is an empty one: the first evaluation derives every
          // achievement whose criteria hold today and pins each at that
          // moment. The dates will read as "earned today" for work done over
          // years, which is wrong in the small and right in the large — the
          // alternative is inventing the instant a criterion first held, and
          // Lock 8 forbids inventing evidence. `firstSessionAt` in the
          // evidence carries the real span for any surface that wants to say
          // so.
          if (from < 20 && to >= 20) {
            await migrator.createTable(progressionStateRows);
            await migrator.createTable(progressionUnlockRows);
          }

          // The continuity resolution ledger. A new table, so `createTable` is
          // already idempotent and needs no guard.
          //
          // No backfill is possible, and that is the honest state rather than a
          // gap: nothing recorded a resolution before this step existed, so
          // every warning an author closed until now left no trace saying it
          // was a resolution. `continuityResolutions` therefore starts at zero
          // on an upgrading install and counts forward, which understates a
          // long-standing author rather than inventing a figure for them.
          if (from < 21 && to >= 21) {
            await migrator.createTable(continuityResolutionRows);
          }

          // Which provocation family opened a session, where one did. A
          // nullable column with no backfill, for the same reason `pastedWords`
          // had none: every session already recorded was begun without anyone
          // asking, and inventing a family for it would be inventing evidence.
          // Null means "nobody was asked", and the reassessment counts forward
          // from here.
          if (from < 22 && to >= 22) {
            if (!await _hasColumn(
                'writing_session_rows', 'provocation_family')) {
              await migrator.addColumn(
                writingSessionRows,
                writingSessionRows.provocationFamily,
              );
            }
          }

          // Which of the owned rewards the author is wearing. Nullable with no
          // backfill, and the null is meaningful rather than a gap: an install
          // upgrading to 23 has a reward selection and has never been asked
          // what to apply, so "nothing applied" is the true answer and also the
          // correct look — the reward tree's own rule is that an author wearing
          // none of it is using a complete application, not a lesser one.
          //
          // PRAGMA-guarded like every other added column here, because
          // `onCreate` builds today's table shape at whatever version the file
          // is opened at, and `addColumn` has no IF NOT EXISTS.
          if (from < 23 && to >= 23) {
            if (!await _hasColumn(
                'progression_state_rows', 'reward_loadout_json')) {
              await migrator.addColumn(
                progressionStateRows,
                progressionStateRows.rewardLoadoutJson,
              );
            }
          }

          // Author decisions about findings — ADR-0011. A new table rather
          // than a column, and nothing to backfill: an install upgrading to 24
          // has never been able to record a decision, so an empty table is the
          // true state of what the author has said rather than a gap in it.
          if (from < 24 && to >= 24) {
            await migrator.createTable(revisionDecisionRows);
          }

          // The three goal fields that had nowhere to live.
          //
          // `WritingGoals` grew `sessionWords`, `chapterWords` and `deadline`
          // in the free-base-model restructure, and they round-tripped through
          // `toJson`/`fromJson` — but JSON is not where a goal is stored. This
          // table had five columns, the companion never wrote the new three and
          // the row reader never read them, so `save` returned what it was
          // handed and `load` returned 0, 0 and null. Phase 9's deadline
          // arithmetic could not run on a real deadline, because no real
          // deadline survived a reload.
          //
          // Nothing to backfill, and that is exactly right rather than a gap:
          // an install upgrading to 25 has never been able to store any of
          // these, so "no session goal, no chapter goal, no deadline" is the
          // true state of every existing row rather than a value lost. The
          // two integers take their column default of 0 and the deadline
          // takes null, which is what all three already read as.
          //
          // PRAGMA-guarded like every other `addColumn` in this migrator, for
          // the reason stated at step 18: `onCreate` builds today's table
          // shape whatever version the database is opened at, so a fixture
          // stamped with an older version already carries these columns, and
          // `addColumn` has no IF NOT EXISTS.
          if (from < 25 && to >= 25) {
            if (!await _hasColumn('writing_goal_rows', 'session_words')) {
              await migrator.addColumn(
                  writingGoalRows, writingGoalRows.sessionWords);
            }
            if (!await _hasColumn('writing_goal_rows', 'chapter_words')) {
              await migrator.addColumn(
                  writingGoalRows, writingGoalRows.chapterWords);
            }
            if (!await _hasColumn('writing_goal_rows', 'deadline')) {
              await migrator.addColumn(
                  writingGoalRows, writingGoalRows.deadline);
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = FULL');
        },
      );

  /// Lifts ownership out of `fields` and into the columns that own it.
  ///
  /// Version 6 added `project_id`, `series_id`, `book_id`, `branch_id` and
  /// `canon_status` with `addColumn` and backfilled none of them, so every
  /// record written under versions 1-5 still carries five NULL columns and
  /// keeps its ownership in the fields JSON. `AuthorRecord.fromJson` has
  /// reconciled that on read ever since, which is why nothing broke -- but a
  /// value only reachable by decoding a JSON blob is invisible to SQL.
  /// `recordsByProject` filters on `project_id OR scope_id`, so a pre-v6
  /// record owned by a project but scoped to a book or a series matches
  /// neither and cannot be found at all.
  ///
  /// This is that missing step, and it is deliberately the *smaller* half of
  /// what `fromJson` does:
  ///
  /// * A column is written only where it **is NULL**. An existing canonical
  ///   value is never overwritten, never re-derived, and never compared
  ///   against the legacy field -- `RecordService.changeScope` rewrites the
  ///   columns and copies `fields` across untouched, so a stale mirror
  ///   disagreeing with a live column is normal and the column is right.
  /// * Nothing is ever written back into `fields`. The mirror is not
  ///   refreshed, not removed, not touched.
  /// * `canon_status` is written only when the legacy value is exactly a
  ///   [CanonStatus] name. `fromJson` maps anything else to `draft`; doing
  ///   that here would materialise a guess as though it were recorded fact,
  ///   and would flatten the World vocabulary -- `_world.canonStatus` holds
  ///   `research` and `authorNotes`, which no column can represent. An
  ///   unrecognised value leaves the column NULL, where `fromJson` goes on
  ///   applying its default exactly as before.
  ///
  /// Together those make it idempotent: a second run finds no NULL column it
  /// can fill and writes nothing.
  Future<void> _backfillCanonicalOwnership() async {
    final rows = await customSelect(
      'SELECT id, fields_json FROM author_record_rows '
      'WHERE project_id IS NULL OR series_id IS NULL OR book_id IS NULL '
      'OR branch_id IS NULL OR canon_status IS NULL',
    ).get();
    if (rows.isEmpty) return;
    const canonNames = {
      'canon',
      'draft',
      'proposed',
      'deprecated',
      'nonCanon',
      'alternate',
    };
    await transaction(() async {
      for (final row in rows) {
        final Map<String, Object?> fields;
        try {
          final decoded = jsonDecode(row.read<String>('fields_json'));
          if (decoded is! Map) continue;
          fields = Map<String, Object?>.from(decoded);
        } on FormatException {
          // A row whose fields will not parse is left exactly as it is. The
          // backfill is an improvement, not a gate on opening the database.
          continue;
        }
        String? legacy(String id) {
          final value = fields[id] ?? fields['_codex.$id'];
          if (value is! String) return null;
          final trimmed = value.trim();
          return trimmed.isEmpty ? null : trimmed;
        }

        final canon = () {
          final value =
              fields['_codex.canonStatus'] ?? fields['_world.canonStatus'];
          return value is String && canonNames.contains(value) ? value : null;
        }();

        final assignments = <String, String>{
          if (legacy('projectId') != null) 'project_id': legacy('projectId')!,
          if (legacy('seriesId') != null) 'series_id': legacy('seriesId')!,
          if (legacy('bookId') != null) 'book_id': legacy('bookId')!,
          if (legacy('branchId') != null) 'branch_id': legacy('branchId')!,
          if (canon != null) 'canon_status': canon,
        };
        if (assignments.isEmpty) continue;
        // COALESCE per column, never a row-level `WHERE ... IS NULL` guard: a
        // record can have a real `project_id` and still be missing its
        // `book_id`, and a row-level guard would let the one that is missing
        // authorise overwriting the one that is not. COALESCE keeps every
        // column that already has a value and fills only the empty ones, which
        // is also what makes a second run a no-op.
        final setClause = assignments.keys
            .map((column) => '$column = COALESCE($column, ?)')
            .join(', ');
        await customUpdate(
          'UPDATE author_record_rows SET $setClause WHERE id = ?',
          variables: [
            ...assignments.values.map(Variable<String>.new),
            Variable<String>(row.read<String>('id')),
          ],
          updates: {authorRecordRows},
        );
      }
    });
  }

  /// Creates the table that holds each scene's current prose.
  ///
  /// Written as SQL rather than a drift table class, the same way the FTS
  /// index below is, because prose is deliberately *not* part of the record
  /// graph: it carries no entity row, no typed links and no branch overlay,
  /// and a generated dataclass would invite exactly the joins this separation
  /// exists to prevent. It also keeps the change out of the ten-thousand-line
  /// generated file, where a schema addition is unreviewable.
  ///
  /// Version 13, not 10: versions 10, 11 and 12 are already spent on writing
  /// goals, the series and project roster, and scene revisions. A migration
  /// version is consumed the moment a build ships it, because drift records
  /// the applied version in the user's own database file -- so reusing one
  /// would leave anyone who had run the earlier build skipping the step
  /// entirely and opening an app whose tables do not exist.
  ///
  /// There is no history table here. Scene history is `scene_revision_rows`,
  /// and there is one of it.
  ///
  /// Instants are stored as milliseconds since the Unix epoch in UTC. Drift's
  /// own `DateTimeColumn` stores whole seconds, which is coarser than an
  /// autosave interval.
  Future<void> _createSceneProseTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS scene_prose_rows(
        scene_id TEXT NOT NULL PRIMARY KEY,
        project_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        revision INTEGER NOT NULL,
        document_json TEXT NOT NULL,
        plain_text TEXT NOT NULL,
        word_count INTEGER NOT NULL,
        is_formatted INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS scene_prose_project '
      'ON scene_prose_rows(project_id)',
    );
  }

  /// Whether [table] already has [column].
  ///
  /// SQLite has no `ADD COLUMN IF NOT EXISTS`, and drift's `createTable` is
  /// `IF NOT EXISTS` — so a table can arrive at a column-adding migration step
  /// already carrying the column, and the ALTER would fail the whole upgrade.
  /// Asking first is the only safe order.
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((row) => row.read<String>('name') == column);
  }

  Future<void> _createSearchIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS author_search USING fts5(
        entity_id UNINDEXED,
        entity_kind UNINDEXED,
        project_id UNINDEXED,
        series_id UNINDEXED,
        book_id UNINDEXED,
        branch_id UNINDEXED,
        canon_status UNINDEXED,
        lifecycle_status UNINDEXED,
        type_id UNINDEXED,
        template_id UNINDEXED,
        title,
        body,
        tags
      )
    ''');
  }

  Future<void> _rebuildSearchIndex() async {
    await customStatement('DELETE FROM author_search');
    await customStatement('''
      INSERT INTO author_search(
        entity_id, entity_kind, project_id, series_id, book_id, branch_id,
        canon_status, lifecycle_status, type_id, template_id, title, body, tags
      )
      SELECT id, 'record', COALESCE(project_id, scope_id), series_id, book_id,
        branch_id, COALESCE(canon_status, 'draft'), status, type_id,
        template_id, title, fields_json, tags_json
      FROM author_record_rows
    ''');
    await customStatement('''
      INSERT INTO author_search(
        entity_id, entity_kind, project_id, canon_status, lifecycle_status,
        type_id, title, body, tags
      )
      SELECT id, 'manuscriptNode', project_id, 'canon', 'active', node_type,
        title, extension_json, '[]'
      FROM manuscript_node_rows
      WHERE node_type <> 'manuscript'
    ''');
    final overlays = await customSelect('''
      SELECT o.overlay_json, b.project_id
      FROM branch_record_overlay_rows o
      JOIN story_branch_rows b ON b.id = o.branch_id
    ''').get();
    for (final row in overlays) {
      final overlay = BranchRecordOverlay.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(row.read<String>('overlay_json')) as Map,
        ),
      );
      await _indexBranchOverlay(overlay, row.read<String>('project_id'));
    }
  }

  Future<void> _indexBranchOverlay(
    BranchRecordOverlay overlay,
    String projectId,
  ) async {
    final created = overlay.createdRecord;
    final canonical = await customSelect('''
      SELECT series_id, book_id, canon_status, status, type_id, template_id,
        title, tags_json
      FROM author_record_rows WHERE id = ?
    ''', variables: [Variable<String>(overlay.recordId)]).getSingleOrNull();
    final entityId = branchSearchEntityId(overlay.branchId, overlay.recordId);
    await customStatement(
      'DELETE FROM author_search WHERE entity_id = ?',
      [entityId],
    );
    if (overlay.state == BranchRecordState.hidden) return;
    await customStatement('''
      INSERT INTO author_search(
        entity_id, entity_kind, project_id, series_id, book_id, branch_id,
        canon_status, lifecycle_status, type_id, template_id, title, body, tags
      ) VALUES (?, 'branchRecord', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      entityId,
      projectId,
      created?.seriesId ?? canonical?.readNullable<String>('series_id'),
      created?.bookId ?? canonical?.readNullable<String>('book_id'),
      overlay.branchId,
      (overlay.canonStatus ?? created?.canonStatus)?.name ??
          canonical?.readNullable<String>('canon_status') ??
          CanonStatus.draft.name,
      created?.status.name ??
          canonical?.readNullable<String>('status') ??
          AuthorRecordStatus.active.name,
      created?.typeId ?? canonical?.readNullable<String>('type_id'),
      created?.templateId ?? canonical?.readNullable<String>('template_id'),
      overlay.title ??
          created?.title ??
          canonical?.readNullable<String>('title') ??
          '',
      jsonEncode({
        ...?created?.fields,
        ...overlay.fields,
        'removedFieldIds': overlay.removedFieldIds,
      }),
      jsonEncode(
        overlay.tags ??
            created?.tags ??
            _decodeStringList(canonical?.readNullable<String>('tags_json')),
      ),
    ]);
  }
}

/// [kSharedScopeTypes] as the strings `scope_type` actually stores.
///
/// Derived rather than retyped, so the SQL predicate and the Dart predicate
/// cannot drift apart.
final List<String> _sharedScopeNames =
    kSharedScopeTypes.map((scope) => scope.name).toList();

class DriftConnectedDomainRepository implements ConnectedDomainRepository {
  const DriftConnectedDomainRepository(this.database);

  final AuthorOsDatabase database;

  @override
  Future<void> putManuscriptNodes(
    Iterable<ManuscriptNodeReference> nodes,
  ) async {
    final nodeList = nodes.toList();
    await database.transaction(() async {
      for (final node in nodeList) {
        await _putEntity(node.id, 'manuscriptNode', node.projectId);
        await _putManuscriptNode(node);
      }
    });
  }

  /// Removes a manuscript node from the connected store.
  ///
  /// Chapters and scenes are shared entities, so deleting one has to clear its
  /// entity row and its entry in the shared search index too, or a deleted
  /// scene would keep answering searches and connection lookups.
  @override
  Future<void> removeManuscriptNodes(Iterable<String> nodeIds) async {
    final ids = nodeIds.toSet().toList();
    if (ids.isEmpty) return;
    await database.transaction(() async {
      for (final id in ids) {
        // Edges reference the entity row, so they have to go first. The
        // foreign key would otherwise refuse the delete outright, and a node
        // whose links were not disconnected beforehand could not be removed
        // at all -- which is how a deleted scene became a permanent ghost.
        await (database.delete(database.recordLinkRows)
              ..where((table) =>
                  table.sourceId.equals(id) | table.targetId.equals(id)))
            .go();
        await (database.delete(database.manuscriptNodeRows)
              ..where((table) => table.id.equals(id)))
            .go();
        await (database.delete(database.connectedEntities)
              ..where((table) => table.id.equals(id)))
            .go();
        if (database.schemaVersion >= 2) {
          await database.customStatement(
            'DELETE FROM author_search WHERE entity_id = ? AND entity_kind = ?',
            [id, SearchEntityKind.manuscriptNode.name],
          );
        }
        await removeSceneProse([id]);
      }
    });
  }

  // --- Scene prose --------------------------------------------------------
  //
  // One row per scene, holding what that scene says now. Writing a scene costs
  // one row, not one re-serialisation of the whole manuscript, which is the
  // point of storing prose here rather than in the manuscript blob.
  //
  // Current prose only. Scene history lives in `scene_revision_rows` and is
  // reached through `SceneRevisionService`; nothing below writes it, and
  // nothing below is a second answer to what a scene used to say.
  //
  // Everything no-ops on a database older than schema 13, the same way the
  // search-index helpers no-op below schema 2, so a migration-pinned test
  // database still opens and still answers.

  bool get _supportsSceneProse => database.schemaVersion >= 13;

  /// What a save needs to tell changed scenes from unchanged ones.
  ///
  /// Deliberately does not select `document_json`: decoding every scene in the
  /// project on every autosave tick would reintroduce, in CPU, the
  /// whole-manuscript cost that moving prose out of the blob removed.
  @override
  Future<Map<String, SceneProseDigest>> sceneProseDigestsForProject(
    String projectId,
  ) async {
    if (!_supportsSceneProse) return const {};
    final rows = await database.customSelect(
      'SELECT scene_id, chapter_id, plain_text, word_count, revision, '
      'is_formatted, updated_at FROM scene_prose_rows WHERE project_id = ?',
      variables: [Variable<String>(projectId)],
    ).get();
    return {
      for (final row in rows)
        row.read<String>('scene_id'): _proseDigestFromRow(row),
    };
  }

  /// Every scene's prose in [projectId], keyed by scene id.
  ///
  /// One query for the whole project: loading a manuscript should not cost a
  /// round trip per scene.
  @override
  Future<Map<String, SceneProse>> sceneProseForProject(String projectId) async {
    if (!_supportsSceneProse) return const {};
    final rows = await database.customSelect(
      'SELECT * FROM scene_prose_rows WHERE project_id = ?',
      variables: [Variable<String>(projectId)],
    ).get();
    return {
      for (final row in rows) row.read<String>('scene_id'): _proseFromRow(row),
    };
  }

  @override
  Future<SceneProse?> sceneProseById(String sceneId) async {
    if (!_supportsSceneProse) return null;
    final row = await database.customSelect(
      'SELECT * FROM scene_prose_rows WHERE scene_id = ?',
      variables: [Variable<String>(sceneId)],
    ).getSingleOrNull();
    return row == null ? null : _proseFromRow(row);
  }

  /// Writes [prose], replacing whatever those scenes said before.
  ///
  /// The caller decides which scenes are in the list; passing only the scenes
  /// whose text changed is what keeps an autosave proportional to the edit
  /// rather than to the manuscript. The search index is refreshed for each one
  /// so prose becomes findable at the moment it is saved.
  @override
  Future<void> putSceneProse(Iterable<SceneProse> prose) async {
    if (!_supportsSceneProse) return;
    final entries = prose.toList();
    if (entries.isEmpty) return;
    await database.transaction(() async {
      for (final entry in entries) {
        await database.customStatement(
          'INSERT INTO scene_prose_rows('
          'scene_id, project_id, chapter_id, revision, document_json, '
          'plain_text, word_count, is_formatted, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) '
          'ON CONFLICT(scene_id) DO UPDATE SET '
          'project_id = excluded.project_id, '
          'chapter_id = excluded.chapter_id, '
          'revision = excluded.revision, '
          'document_json = excluded.document_json, '
          'plain_text = excluded.plain_text, '
          'word_count = excluded.word_count, '
          'is_formatted = excluded.is_formatted, '
          'updated_at = excluded.updated_at',
          [
            entry.sceneId,
            entry.projectId,
            entry.chapterId,
            entry.revision,
            jsonEncode(entry.document.toJson()),
            entry.plainText,
            entry.wordCount,
            entry.document.isPlainText ? 0 : 1,
            entry.updatedAt.toUtc().millisecondsSinceEpoch,
          ],
        );
        await _reindexSceneNode(entry.sceneId);
      }
    });
  }

  /// Removes the current prose of [sceneIds].
  ///
  /// Called whenever a scene stops existing. Prose carries no foreign key into
  /// the entity table -- it is not graph data -- so nothing else would collect
  /// it, and a deleted scene's words would sit in the database, and in search
  /// results, for the life of the project.
  ///
  /// Revisions are deliberately left alone: deleting a scene captures a
  /// `deletion` revision precisely so its words survive it, and dropping the
  /// history here would undo that.
  @override
  Future<void> removeSceneProse(Iterable<String> sceneIds) async {
    if (!_supportsSceneProse) return;
    final ids = sceneIds.toSet().toList();
    if (ids.isEmpty) return;
    for (final id in ids) {
      await database.customStatement(
        'DELETE FROM scene_prose_rows WHERE scene_id = ?',
        [id],
      );
    }
  }

  /// Removes every scene's prose in [projectId].
  @override
  Future<void> removeSceneProseForProject(String projectId) async {
    if (!_supportsSceneProse) return;
    await database.customStatement(
      'DELETE FROM scene_prose_rows WHERE project_id = ?',
      [projectId],
    );
  }

  SceneProse _proseFromRow(QueryRow row) => SceneProse(
        sceneId: row.read<String>('scene_id'),
        projectId: row.read<String>('project_id'),
        chapterId: row.read<String>('chapter_id'),
        revision: row.read<int>('revision'),
        document: _documentFromJson(row.read<String>('document_json')),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('updated_at'),
          isUtc: true,
        ),
      );

  SceneProseDigest _proseDigestFromRow(QueryRow row) => SceneProseDigest(
        sceneId: row.read<String>('scene_id'),
        chapterId: row.read<String>('chapter_id'),
        plainText: row.read<String>('plain_text'),
        wordCount: row.read<int>('word_count'),
        revision: row.read<int>('revision'),
        isFormatted: row.read<int>('is_formatted') != 0,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('updated_at'),
          isUtc: true,
        ),
      );

  ProseDocument _documentFromJson(String encoded) => ProseDocument.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );

  /// Rewrites the search entry for [sceneId] so it includes the scene's prose.
  ///
  /// Prose only became searchable when it moved into the database; before
  /// this, the index carried a scene's metadata and nothing an author had
  /// actually written.
  Future<void> _reindexSceneNode(String sceneId) async {
    if (database.schemaVersion < 2) return;
    final node = await manuscriptNodeById(sceneId);
    if (node == null) return;
    await _putManuscriptNode(node);
  }

  @override
  Future<void> putRecordsAndLinks({
    required Iterable<AuthorRecord> records,
    required Iterable<RecordLink> links,
  }) async {
    final recordList = records.toList();
    final linkList = links.toList();
    await database.transaction(() async {
      for (final record in recordList) {
        await _putEntity(record.id, 'record', record.scopeId);
        await _putRecord(record);
      }
      for (final link in linkList) {
        await _putLink(link);
      }
    });
  }

  @override
  Future<void> putRecord(AuthorRecord record) async {
    await database.transaction(() async {
      await _putEntity(record.id, 'record', record.scopeId);
      await _putRecord(record);
    });
  }

  @override
  Future<void> putLink(RecordLink link) async {
    await database.transaction(() async {
      await _putLink(link);
    });
  }

  @override
  Future<void> putRecordWithHistory({
    required AuthorRecord record,
    required Iterable<RecordLink> links,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await _putEntity(record.id, 'record', record.scopeId);
      await _putRecord(record);
      for (final link in links) {
        await _putLink(link);
      }
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> putLinkWithHistory({
    required RecordLink link,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await _putLink(link);
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> deleteLinkWithHistory({
    required String linkId,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await (database.delete(database.recordLinkRows)
            ..where((table) => table.id.equals(linkId)))
          .go();
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> putBranchWithHistory({
    required StoryBranch branch,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await putBranch(branch);
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> putBranchRecordOverlayWithHistory({
    required BranchRecordOverlay overlay,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await putBranchRecordOverlay(overlay);
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> putBranchLinkOverlayWithHistory({
    required BranchLinkOverlay overlay,
    required RecordVersion version,
    required AuditEvent auditEvent,
  }) async {
    await database.transaction(() async {
      await putBranchLinkOverlay(overlay);
      await _appendHistory(version, auditEvent);
    });
  }

  @override
  Future<void> appendHistory(
    RecordVersion version,
    AuditEvent auditEvent,
  ) =>
      database.transaction(() => _appendHistory(version, auditEvent));

  @override
  Future<RecordVersion?> versionById(String id, String projectId) async {
    final row = await (database.select(database.recordVersionRows)
          ..where((table) =>
              table.id.equals(id) & table.projectId.equals(projectId)))
        .getSingleOrNull();
    return row == null ? null : _versionFromRow(row);
  }

  @override
  Future<List<RecordVersion>> versionHistory(HistoryFilter filter) async {
    final query = database.select(database.recordVersionRows)
      ..where((table) {
        var predicate = table.projectId.equals(filter.projectId);
        if (filter.recordId != null) {
          predicate = predicate & table.recordId.equals(filter.recordId!);
        }
        if (filter.recordType != null) {
          predicate = predicate & table.recordType.equals(filter.recordType!);
        }
        if (filter.seriesId != null) {
          predicate = predicate & table.seriesId.equals(filter.seriesId!);
        }
        if (filter.bookId != null) {
          predicate = predicate & table.bookId.equals(filter.bookId!);
        }
        if (filter.seriesId != null) {
          predicate = predicate & table.seriesId.equals(filter.seriesId!);
        }
        if (filter.bookId != null) {
          predicate = predicate & table.bookId.equals(filter.bookId!);
        }
        if (filter.branchId != null) {
          predicate = predicate & table.branchId.equals(filter.branchId!);
        } else if (filter.recordId != null) {
          predicate = predicate & table.branchId.isNull();
        }
        if (filter.changeType != null) {
          predicate =
              predicate & table.changeType.equals(filter.changeType!.name);
        }
        if (filter.from != null) {
          predicate =
              predicate & table.createdAt.isBiggerOrEqualValue(filter.from!);
        }
        if (filter.to != null) {
          predicate =
              predicate & table.createdAt.isSmallerOrEqualValue(filter.to!);
        }
        return predicate;
      })
      ..orderBy([
        (table) => OrderingTerm.asc(table.createdAt),
        (table) => OrderingTerm.asc(table.id),
      ])
      ..limit(filter.limit);
    return (await query.get()).map(_versionFromRow).toList();
  }

  @override
  Future<List<AuditEvent>> auditHistory(HistoryFilter filter) async {
    final query = database.select(database.auditEventRows)
      ..where((table) {
        var predicate = table.projectId.equals(filter.projectId);
        if (filter.recordId != null) {
          predicate = predicate & table.recordId.equals(filter.recordId!);
        }
        if (filter.recordType != null) {
          predicate = predicate & table.recordType.equals(filter.recordType!);
        }
        if (filter.branchId != null) {
          predicate = predicate & table.branchId.equals(filter.branchId!);
        } else if (filter.recordId != null) {
          predicate = predicate & table.branchId.isNull();
        }
        if (filter.changeType != null) {
          predicate =
              predicate & table.changeType.equals(filter.changeType!.name);
        }
        if (filter.from != null) {
          predicate =
              predicate & table.createdAt.isBiggerOrEqualValue(filter.from!);
        }
        if (filter.to != null) {
          predicate =
              predicate & table.createdAt.isSmallerOrEqualValue(filter.to!);
        }
        return predicate;
      })
      ..orderBy([
        (table) => OrderingTerm.asc(table.createdAt),
        (table) => OrderingTerm.asc(table.id),
      ])
      ..limit(filter.limit);
    return (await query.get()).map(_auditFromRow).toList();
  }

  @override
  Future<RecordVersion?> latestVersion({
    required String projectId,
    required String entityId,
    String? branchId,
  }) async {
    final query = database.select(database.recordVersionRows)
      ..where((table) {
        var predicate =
            table.projectId.equals(projectId) & table.entityId.equals(entityId);
        predicate = branchId == null
            ? predicate & table.branchId.isNull()
            : predicate & table.branchId.equals(branchId);
        return predicate;
      })
      ..orderBy([
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _versionFromRow(row);
  }

  // --- Writing session history -------------------------------------------

  /// Appends one finished writing session.
  ///
  /// Insert-or-ignore, deliberately: a session is a historical fact, so a
  /// repeated write — a re-fired lifecycle event, a finalize that ran twice,
  /// a replayed id — leaves the original row untouched instead of rewriting
  /// what the author actually did.
  @override
  Future<void> putWritingSession(WritingSession session) async {
    await database.into(database.writingSessionRows).insert(
          _writingSessionCompanion(session),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Appends several sessions in one transaction, with the same
  /// insert-or-ignore semantics as [putWritingSession].
  @override
  Future<void> putWritingSessions(Iterable<WritingSession> sessions) async {
    final sessionList = sessions.toList();
    if (sessionList.isEmpty) return;
    await database.transaction(() async {
      for (final session in sessionList) {
        await database.into(database.writingSessionRows).insert(
              _writingSessionCompanion(session),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  /// Every session recorded for one project, oldest first.
  ///
  /// Project-scoped by the `where` clause, so one project's history can never
  /// surface in another's analytics. [from] and [to] bound the query by start
  /// instant for callers that only need a window; analytics loads the whole
  /// history once and derives its metrics in memory.
  @override
  Future<List<WritingSession>> writingSessionsForProject(
    String projectId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final query = database.select(database.writingSessionRows)
      ..where((table) {
        var predicate = table.projectId.equals(projectId);
        if (from != null) {
          predicate = predicate & table.startedAt.isBiggerOrEqualValue(from);
        }
        if (to != null) {
          predicate = predicate & table.startedAt.isSmallerOrEqualValue(to);
        }
        return predicate;
      })
      ..orderBy([
        (table) => OrderingTerm.asc(table.startedAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    if (limit != null) query.limit(limit);
    return (await query.get()).map(_writingSessionFromRow).toList();
  }

  /// Removes one project's writing history. Cleanup only — nothing in the
  /// recording or analytics path calls this.
  @override
  Future<int> deleteWritingSessionsForProject(String projectId) =>
      (database.delete(database.writingSessionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

  // --- Author decisions about findings ------------------------------------

  /// Writes one decision, replacing any earlier answer to the same subject.
  ///
  /// Insert-**or-replace**, where the session above it is insert-or-ignore, and
  /// the difference is the whole distinction between the two tables. A session
  /// is what happened and must not be rewritten; a decision is what the author
  /// currently thinks, so an author moving a finding from *consider* to
  /// *must-fix* is revising one decision rather than making a second. The id is
  /// derived from `(projectId, kind, subject)`, so the conflict this relies on
  /// is guaranteed rather than hoped for.
  @override
  Future<void> putRevisionDecision(RevisionDecision decision) async {
    await database.into(database.revisionDecisionRows).insert(
          _revisionDecisionCompanion(decision),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Writes several decisions in one transaction, with the same replace
  /// semantics as [putRevisionDecision].
  @override
  Future<void> putRevisionDecisions(
    Iterable<RevisionDecision> decisions,
  ) async {
    final decisionList = decisions.toList();
    if (decisionList.isEmpty) return;
    await database.transaction(() async {
      for (final decision in decisionList) {
        await database.into(database.revisionDecisionRows).insert(
              _revisionDecisionCompanion(decision),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  /// Every decision recorded for one project, oldest first.
  ///
  /// Project-scoped by the `where` clause, so one book's dismissals can never
  /// suppress a finding in another. [kind] narrows to a single kind for callers
  /// that only want one — the style sheet wants the voice pairs and nothing
  /// else, and reading all five to discard four is a table scan for nothing.
  @override
  Future<List<RevisionDecision>> revisionDecisionsForProject(
    String projectId, {
    RevisionDecisionKind? kind,
  }) async {
    final query = database.select(database.revisionDecisionRows)
      ..where((table) {
        final predicate = table.projectId.equals(projectId);
        if (kind == null) return predicate;
        return predicate & table.kind.equals(kind.name);
      })
      ..orderBy([
        (table) => OrderingTerm.asc(table.decidedAt),
        (table) => OrderingTerm.asc(table.id),
      ]);
    // A row whose kind this build does not know is dropped rather than
    // guessed at: an archive from a later version that added a sixth kind
    // restores its other five, and inventing a kind here would be inventing a
    // decision the author never made.
    return (await query.get())
        .map(_revisionDecisionFromRow)
        .whereType<RevisionDecision>()
        .toList();
  }

  /// Withdraws one decision — the author un-dismissing what they had silenced.
  ///
  /// A hard delete rather than a tombstone, because a withdrawn decision has
  /// nothing left to say: the finding simply comes back, which is exactly what
  /// the author asked for.
  @override
  Future<int> deleteRevisionDecision(String id) =>
      (database.delete(database.revisionDecisionRows)
            ..where((table) => table.id.equals(id)))
          .go();

  @override
  Future<int> deleteRevisionDecisionsForProject(String projectId) =>
      (database.delete(database.revisionDecisionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

  RevisionDecisionRowsCompanion _revisionDecisionCompanion(
    RevisionDecision decision,
  ) =>
      RevisionDecisionRowsCompanion.insert(
        id: decision.id,
        projectId: decision.projectId,
        kind: decision.kind.name,
        subject: decision.subject,
        value: decision.value,
        decidedAt: decision.decidedAt,
        sceneId: Value(decision.sceneId),
        chapterId: Value(decision.chapterId),
      );

  RevisionDecision? _revisionDecisionFromRow(RevisionDecisionRow row) {
    final kind = RevisionDecision.kindFromName(row.kind);
    if (kind == null) return null;
    return RevisionDecision(
      projectId: row.projectId,
      kind: kind,
      subject: row.subject,
      value: row.value,
      decidedAt: row.decidedAt,
      sceneId: row.sceneId,
      chapterId: row.chapterId,
    );
  }

  // --- Writing goals -------------------------------------------------------

  /// The goals stored for one project, or `null` when the author has never
  /// edited them.
  ///
  /// Returning `null` rather than the defaults is deliberate: exactly one
  /// place — [WritingGoalsStore] — decides what a default goal is, and the
  /// caller keeps the ability to tell "never customized" from "customized".
  /// Reading never writes a row.
  @override

  /// Records that a continuity finding was resolved.
  ///
  /// Insert-or-ignore, so a replayed call cannot count one resolution twice.
  /// Called only where a recheck has confirmed the warning is gone — see
  /// [ContinuityResolutionRows].
  Future<void> recordContinuityResolution({
    required String id,
    required String projectId,
    required String warningType,
    required String actionKind,
    required DateTime resolvedAt,
    String? recordId,
    String? linkId,
  }) async {
    await database.into(database.continuityResolutionRows).insert(
          ContinuityResolutionRowsCompanion.insert(
            id: id,
            projectId: projectId,
            warningType: warningType,
            actionKind: actionKind,
            resolvedAt: resolvedAt,
            recordId: Value(recordId),
            linkId: Value(linkId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Continuity findings resolved across every project on this device.
  ///
  /// Career-scoped, because progression asks how far this *author* has come.
  Future<int> continuityResolutionCount() async {
    final row = await database.customSelect(
      'SELECT COUNT(*) AS total FROM continuity_resolution_rows',
      readsFrom: {database.continuityResolutionRows},
    ).getSingle();
    return row.read<int>('total');
  }

  /// Scenes carrying at least one recorded revision, across every project.
  ///
  /// Counted in SQL rather than by folding [sceneRevisionSummaries], which is
  /// project-and-scene scoped and would need one query per scene. It also never
  /// touches the `content` column: that method's own doc warns a revised scene
  /// can be megabytes, and a count has no business loading a single body.
  Future<int> revisedSceneCount() async {
    final row = await database.customSelect(
      'SELECT COUNT(DISTINCT project_id || 0x1f || scene_id) AS total '
      'FROM scene_revision_rows',
      readsFrom: {database.sceneRevisionRows},
    ).getSingle();
    return row.read<int>('total');
  }

  /// The author's stored progression state, or [ProgressionState.empty] when
  /// nothing has been stored yet.
  ///
  /// Reading never writes. An install that has never evaluated progression
  /// stays that way, so "no ledger yet" and "a ledger holding nothing" are the
  /// same thing to every caller and neither is manufactured by a read.
  Future<ProgressionState> progressionState() async {
    final row = await (database.select(database.progressionStateRows)
          ..where((table) => table.id.equals(ProgressionStateRows.careerKey)))
        .getSingleOrNull();
    final unlockRows = await (database.select(database.progressionUnlockRows)
          ..orderBy([(table) => OrderingTerm.asc(table.achievementId)]))
        .get();

    final selection = <String>{};
    var loadout = RewardLoadout.empty;
    if (row != null) {
      final decoded = jsonDecode(row.rewardSelectionJson);
      if (decoded is List) {
        for (final id in decoded) {
          if (id is String && id.isNotEmpty) selection.add(id);
        }
      }
      final storedLoadout = row.rewardLoadoutJson;
      if (storedLoadout != null && storedLoadout.isNotEmpty) {
        // `fromJson` drops what it cannot address and never throws, so a
        // loadout written by a later build cannot stop this one loading.
        loadout = RewardLoadout.fromJson(jsonDecode(storedLoadout));
      }
    }

    return ProgressionState(
      unlocks: [
        for (final unlock in unlockRows)
          ProgressionUnlock(
            achievementId: unlock.achievementId,
            unlockedAt: unlock.unlockedAt,
          ),
      ],
      xpFloor: row?.xpFloor ?? 0,
      rewardSelection: selection,
      rewardLoadout: loadout,
    );
  }

  /// Stores the XP floor and the reward selection, replacing what was there.
  ///
  /// Upsert rather than insert-or-ignore, and unlike [appendProgressionUnlocks]
  /// below: the floor is a running maximum and the selection is the author's
  /// current choice, so both have to be overwritable. The floor is only ever
  /// raised, but that decision belongs to the engine — this layer stores what
  /// it is given.
  Future<void> putProgressionState({
    required int xpFloor,
    required Set<String> rewardSelection,
    RewardLoadout rewardLoadout = RewardLoadout.empty,
  }) async {
    await database.into(database.progressionStateRows).insertOnConflictUpdate(
          ProgressionStateRowsCompanion.insert(
            id: ProgressionStateRows.careerKey,
            xpFloor: xpFloor,
            // Sorted so the stored bytes are a function of the selection and
            // not of the order a Set happened to iterate in — two devices that
            // chose the same rewards write the same row.
            rewardSelectionJson: jsonEncode(rewardSelection.toList()..sort()),
            // `toJson` sorts its keys for the same reason the selection is
            // sorted above.
            rewardLoadoutJson: Value(jsonEncode(rewardLoadout.toJson())),
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Appends unlocks the ledger does not already hold.
  ///
  /// Insert-or-ignore, exactly as [putWritingSession] is and for the same
  /// reason: an unlock is the first instant a criterion held, and a replayed
  /// write must never move that date later. The engine folds duplicates with
  /// the same "earliest wins" rule; both layers enforce it because they fail
  /// differently — the engine against a duplicated in-memory list, this against
  /// a second evaluation on a later day.
  Future<void> appendProgressionUnlocks(
    Iterable<ProgressionUnlock> unlocks,
  ) async {
    if (unlocks.isEmpty) return;
    await database.batch((batch) {
      for (final unlock in unlocks) {
        batch.insert(
          database.progressionUnlockRows,
          ProgressionUnlockRowsCompanion.insert(
            achievementId: unlock.achievementId,
            unlockedAt: unlock.unlockedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<WritingGoals?> writingGoalsForProject(String projectId) async {
    final row = await (database.select(database.writingGoalRows)
          ..where((table) => table.projectId.equals(projectId)))
        .getSingleOrNull();
    return row == null ? null : _writingGoalsFromRow(row);
  }

  /// Stores one project's goals, replacing whatever was there.
  ///
  /// Upsert, deliberately, and the one place this table's write semantics
  /// differ from [putWritingSession]'s insert-or-ignore: a session is a
  /// historical fact that a repeated write must not disturb, while a goal is
  /// the target the author currently holds, so editing it has to overwrite.
  @override
  Future<void> putWritingGoals(WritingGoals goals) async {
    await database.into(database.writingGoalRows).insertOnConflictUpdate(
          _writingGoalsCompanion(goals),
        );
  }

  /// Clears one project's goals so the next read resolves to the defaults
  /// again. Removing the row rather than storing the default values keeps
  /// "never customized" honest.
  @override
  Future<int> deleteWritingGoalsForProject(String projectId) =>
      (database.delete(database.writingGoalRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

  // --- Series and the project roster ---------------------------------------

  /// Every series the author has created, newest first.
  @override
  Future<List<WritingSeries>> allSeries() async {
    final rows = await (database.select(database.seriesRows)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return rows.map(_seriesFromRow).toList();
  }

  @override
  Future<WritingSeries?> seriesById(String seriesId) async {
    final row = await (database.select(database.seriesRows)
          ..where((table) => table.id.equals(seriesId)))
        .getSingleOrNull();
    return row == null ? null : _seriesFromRow(row);
  }

  /// Stores one series, replacing whatever was there. Upsert, like writing
  /// goals: a series is a current setting, not a historical fact.
  @override
  Future<void> putSeries(WritingSeries series) async {
    await database.into(database.seriesRows).insertOnConflictUpdate(
          _seriesCompanion(series),
        );
  }

  /// Removes a series and releases its books.
  ///
  /// The projects survive: deleting a series must never delete a manuscript.
  /// Every book that belonged to it becomes standalone again.
  @override
  Future<int> deleteSeries(String seriesId) async {
    return database.transaction(() async {
      await (database.update(database.projectRows)
            ..where((table) => table.seriesId.equals(seriesId)))
          .write(
        const ProjectRowsCompanion(
          seriesId: Value(null),
          seriesPosition: Value(null),
        ),
      );
      return (database.delete(database.seriesRows)
            ..where((table) => table.id.equals(seriesId)))
          .go();
    });
  }

  /// Every project on the roster, newest first.
  @override
  Future<List<ProjectRosterEntry>> projectRoster() async {
    final rows = await (database.select(database.projectRows)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return rows.map(_rosterEntryFromRow).toList();
  }

  @override
  Future<ProjectRosterEntry?> projectRosterEntry(String projectId) async {
    final row = await (database.select(database.projectRows)
          ..where((table) => table.id.equals(projectId)))
        .getSingleOrNull();
    return row == null ? null : _rosterEntryFromRow(row);
  }

  /// Stores one roster entry, replacing whatever was there.
  @override
  Future<void> putProjectRosterEntry(ProjectRosterEntry entry) async {
    await database.into(database.projectRows).insertOnConflictUpdate(
          _rosterEntryCompanion(entry),
        );
  }

  /// Removes a project from the roster.
  ///
  /// Roster-only: the project's manuscript, records and writing history are
  /// not touched, so removing an entry can never destroy an author's writing.
  @override
  Future<int> deleteProjectRosterEntry(String projectId) =>
      (database.delete(database.projectRows)
            ..where((table) => table.id.equals(projectId)))
          .go();

  /// The books of one series, in the order the author put them in.
  ///
  /// Ordered by position with the id as a tiebreak, so the sequence is stable
  /// even if two rows ever shared a position.
  @override
  Future<List<ProjectRosterEntry>> booksInSeries(String seriesId) async {
    final rows = await (database.select(database.projectRows)
          ..where((table) => table.seriesId.equals(seriesId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.seriesPosition),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows.map(_rosterEntryFromRow).toList();
  }

  // --- Scene revision history ----------------------------------------------

  /// Appends one snapshot and prunes what [retention] says is no longer worth
  /// keeping, in a single transaction.
  ///
  /// Insert-or-ignore for the same reason as [putWritingSession]: a revision
  /// is a historical fact. Pruning inside the same transaction is what keeps
  /// the invariant "a scene's history obeys the retention policy" true at
  /// every point a reader could observe it, rather than only after a separate
  /// housekeeping pass that might never run.
  @override
  Future<void> putSceneRevision(
    SceneRevision revision, {
    SceneRevisionRetention retention = const SceneRevisionRetention(),
    DateTime? now,
  }) async {
    await database.transaction(() async {
      await database.into(database.sceneRevisionRows).insert(
            _sceneRevisionCompanion(revision),
            mode: InsertMode.insertOrIgnore,
          );
      final summaries = await sceneRevisionSummaries(
        revision.projectId,
        revision.sceneId,
      );
      final stale = retention.idsToPrune(summaries, now ?? DateTime.now());
      if (stale.isEmpty) return;
      await (database.delete(database.sceneRevisionRows)
            ..where((table) => table.id.isIn(stale)))
          .go();
    });
  }

  /// One scene's history, newest first, **without the prose**.
  ///
  /// The column list is the point. Selecting rows would load every stored copy
  /// of the scene to draw a list that shows none of them — on a heavily
  /// revised scene that is megabytes to render a few dozen lines. Bodies are
  /// read one at a time, by [sceneRevision], when the author opens one.
  @override
  Future<List<SceneRevisionSummary>> sceneRevisionSummaries(
    String projectId,
    String sceneId, {
    int? limit,
  }) async {
    final buffer = StringBuffer(
      'SELECT id, project_id, scene_id, chapter_id, title, content_digest, '
      'word_count, captured_at, trigger FROM scene_revision_rows '
      'WHERE project_id = ? AND scene_id = ? '
      'ORDER BY captured_at DESC, id DESC',
    );
    if (limit != null) buffer.write(' LIMIT $limit');
    final rows = await database.customSelect(
      buffer.toString(),
      variables: [Variable<String>(projectId), Variable<String>(sceneId)],
      readsFrom: {database.sceneRevisionRows},
    ).get();
    return [
      for (final row in rows)
        SceneRevisionSummary(
          id: row.read<String>('id'),
          projectId: row.read<String>('project_id'),
          sceneId: row.read<String>('scene_id'),
          chapterId: row.read<String>('chapter_id'),
          title: row.read<String>('title'),
          wordCount: row.read<int>('word_count'),
          capturedAt: row.read<DateTime>('captured_at'),
          trigger: SceneRevisionTriggerX.fromId(row.read<String>('trigger')),
          contentDigest: row.read<String>('content_digest'),
        ),
    ];
  }

  /// One stored revision, prose included.
  @override
  Future<SceneRevision?> sceneRevision(String revisionId) async {
    final row = await (database.select(database.sceneRevisionRows)
          ..where((table) => table.id.equals(revisionId)))
        .getSingleOrNull();
    return row == null ? null : _sceneRevisionFromRow(row);
  }

  /// The digest of the newest revision of every scene in [projectId].
  ///
  /// This is what lets the recorder decide, for a whole manuscript at once and
  /// without reading any prose, which scenes have actually changed since they
  /// were last snapshotted. One query per capture rather than one per scene.
  @override
  Future<Map<String, String>> newestSceneRevisionDigests(
    String projectId,
  ) async {
    final rows = await database.customSelect(
      'SELECT r.scene_id AS scene_id, r.content_digest AS content_digest '
      'FROM scene_revision_rows r '
      'JOIN (SELECT scene_id, MAX(captured_at) AS captured_at '
      '      FROM scene_revision_rows WHERE project_id = ? '
      '      GROUP BY scene_id) newest '
      '  ON newest.scene_id = r.scene_id '
      ' AND newest.captured_at = r.captured_at '
      'WHERE r.project_id = ?',
      variables: [Variable<String>(projectId), Variable<String>(projectId)],
      readsFrom: {database.sceneRevisionRows},
    ).get();
    return {
      for (final row in rows)
        row.read<String>('scene_id'): row.read<String>('content_digest'),
    };
  }

  /// Removes one project's prose history. Cleanup only — nothing in the
  /// capture or restore path calls this.
  @override
  Future<int> deleteSceneRevisionsForProject(String projectId) =>
      (database.delete(database.sceneRevisionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

  /// See [ConnectedDomainRepository.eraseProject].
  ///
  /// Written as an explicit sequence rather than a loop over table names,
  /// because the tables do not agree on how they name a project and pretending
  /// they do is how one gets missed. Three shapes appear here:
  ///
  ///  * **Named by `projectId`** — most of them. A direct predicate.
  ///  * **Named by an entity id** — `recordLinkRows`, `connectedEntities` and
  ///    the FTS index, which know entities rather than projects. They are
  ///    resolved through the ids gathered first.
  ///  * **Named by a branch** — the two overlay tables, which hang off
  ///    `storyBranchRows` and have to go before it or the foreign key refuses.
  ///
  /// The order below is the dependency order and is not arrangeable to taste.
  @override
  Future<int> eraseProject(String projectId) async {
    return database.transaction(() async {
      var removed = 0;

      // Gathered before anything is deleted. After the record rows go there is
      // no way left to ask which entities belonged to this project, and the
      // links and the search index are keyed by entity rather than by project.
      final recordIds = (await (database.select(database.authorRecordRows)
                ..where((table) => table.projectId.equals(projectId)))
              .get())
          .map((row) => row.id)
          .toList();
      final nodeIds = (await (database.select(database.manuscriptNodeRows)
                ..where((table) => table.projectId.equals(projectId)))
              .get())
          .map((row) => row.id)
          .toList();
      final entityIds = <String>{...recordIds, ...nodeIds}.toList();

      // Edges first. `recordLinkRows` references `connectedEntities`, so a
      // link left behind would refuse the entity delete outright — the exact
      // failure `removeManuscriptNodes` documents as "how a deleted scene
      // became a permanent ghost".
      //
      // Both predicates are needed and neither subsumes the other. The scope
      // clause catches a link filed under the project whose endpoints have
      // already gone; the endpoint clauses catch a link into this project from
      // a record the project does not own.
      if (entityIds.isNotEmpty) {
        removed += await (database.delete(database.recordLinkRows)
              ..where((table) =>
                  table.sourceId.isIn(entityIds) |
                  table.targetId.isIn(entityIds)))
            .go();
      }
      removed += await (database.delete(database.recordLinkRows)
            ..where((table) => table.scopeId.equals(projectId)))
          .go();

      // Branch overlays before branches, for the same foreign-key reason.
      final branchIds = (await (database.select(database.storyBranchRows)
                ..where((table) => table.projectId.equals(projectId)))
              .get())
          .map((row) => row.id)
          .toList();
      if (branchIds.isNotEmpty) {
        removed += await (database.delete(database.branchLinkOverlayRows)
              ..where((table) => table.branchId.isIn(branchIds)))
            .go();
        removed += await (database.delete(database.branchRecordOverlayRows)
              ..where((table) => table.branchId.isIn(branchIds)))
            .go();
      }
      removed += await (database.delete(database.storyBranchRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

      removed += await (database.delete(database.authorRecordRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.manuscriptNodeRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

      if (entityIds.isNotEmpty) {
        removed += await (database.delete(database.connectedEntities)
              ..where((table) => table.id.isIn(entityIds)))
            .go();
      }

      // History, sessions and decisions, each named by the project directly.
      removed += await (database.delete(database.recordVersionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.auditEventRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.writingSessionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.revisionDecisionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.writingGoalRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.sceneRevisionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.continuityResolutionRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

      // Binary assets. Covers and avatars are stored in the database rather
      // than on disk, so nothing else would ever collect them — and an author
      // who asked for their project's data to be gone did not mean "except the
      // photographs".
      removed += await (database.delete(database.bookAssetRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();
      removed += await (database.delete(database.recordAssetRows)
            ..where((table) => table.projectId.equals(projectId)))
          .go();

      // Record and connection type definitions scoped to this project. A
      // definition at a wider scope is shared and stays; `scopeId` is the only
      // thing that can tell them apart, so it is the predicate here even
      // though `projectId` is the predicate everywhere else.
      removed += await (database.delete(database.recordTypeDefinitionRows)
            ..where((table) => table.scopeId.equals(projectId)))
          .go();
      removed += await (database.delete(database.connectionTypeDefinitionRows)
            ..where((table) => table.scopeId.equals(projectId)))
          .go();

      // Prose has no entity row, so none of the deletes above touched it.
      // Without this the scenes would keep answering searches and their words
      // would attach themselves to whichever new scene reused an id — which is
      // the reasoning `replaceSnapshot` already carries, applying to one
      // project instead of all of them.
      await removeSceneProseForProject(projectId);

      // The FTS index last, keyed by entity. Dropped one id at a time rather
      // than with an `IN (...)`: `author_search` is a virtual table and the
      // statement is built by hand, so a bounded parameter list is worth more
      // than the round trips it costs.
      if (database.schemaVersion >= 2) {
        for (final id in entityIds) {
          await database.customStatement(
            'DELETE FROM author_search WHERE entity_id = ?',
            [id],
          );
        }
      }

      // `projectRows` is untouched on purpose: the roster entry is the project,
      // and this method empties a project rather than removing one. So is
      // everything under `progressionStateRows` and `progressionUnlockRows`,
      // which are career-scoped — see the interface doc.
      return removed;
    });
  }

  SceneRevisionRowsCompanion _sceneRevisionCompanion(SceneRevision revision) =>
      SceneRevisionRowsCompanion.insert(
        id: revision.id,
        projectId: revision.projectId,
        sceneId: revision.sceneId,
        chapterId: revision.chapterId,
        title: revision.title,
        content: revision.content,
        contentDigest: revision.contentDigest,
        wordCount: revision.wordCount,
        capturedAt: revision.capturedAt,
        trigger: revision.trigger.id,
      );

  SceneRevision _sceneRevisionFromRow(SceneRevisionRow row) => SceneRevision(
        id: row.id,
        projectId: row.projectId,
        sceneId: row.sceneId,
        chapterId: row.chapterId,
        title: row.title,
        content: row.content,
        contentDigest: row.contentDigest,
        wordCount: row.wordCount,
        capturedAt: row.capturedAt,
        trigger: SceneRevisionTriggerX.fromId(row.trigger),
      );

  SeriesRowsCompanion _seriesCompanion(WritingSeries series) =>
      SeriesRowsCompanion.insert(
        id: series.id,
        name: series.name,
        defaultTargetWords: series.defaultTargetWords,
        createdAt: series.createdAt ?? DateTime.now(),
        updatedAt: series.updatedAt ?? DateTime.now(),
      );

  WritingSeries _seriesFromRow(SeriesRow row) => WritingSeries(
        id: row.id,
        name: row.name,
        defaultTargetWords: row.defaultTargetWords,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ProjectRowsCompanion _rosterEntryCompanion(ProjectRosterEntry entry) =>
      ProjectRowsCompanion.insert(
        id: entry.project.id,
        payloadJson: jsonEncode(entry.project.toJson()),
        seriesId: Value(entry.seriesId),
        seriesPosition: Value(entry.seriesPosition),
        archivedAt: Value(entry.archivedAt),
        profileId: Value(entry.profileId),
        createdAt: entry.createdAt ?? DateTime.now(),
        updatedAt: entry.updatedAt ?? DateTime.now(),
      );

  ProjectRosterEntry _rosterEntryFromRow(ProjectRow row) => ProjectRosterEntry(
        project: StarterProject.fromJson(
          Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map),
        ),
        seriesId: row.seriesId,
        seriesPosition: row.seriesPosition,
        archivedAt: row.archivedAt,
        profileId: row.profileId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  WritingGoalRowsCompanion _writingGoalsCompanion(WritingGoals goals) =>
      WritingGoalRowsCompanion.insert(
        projectId: goals.projectId,
        dailyWords: goals.dailyWords,
        weeklyWords: goals.weeklyWords,
        monthlyWords: goals.monthlyWords,
        sessionWords: Value(goals.sessionWords),
        chapterWords: Value(goals.chapterWords),
        deadline: Value(goals.deadline),
        updatedAt: goals.updatedAt ?? DateTime.now(),
      );

  WritingGoals _writingGoalsFromRow(WritingGoalRow row) => WritingGoals(
        projectId: row.projectId,
        dailyWords: row.dailyWords,
        weeklyWords: row.weeklyWords,
        monthlyWords: row.monthlyWords,
        sessionWords: row.sessionWords,
        chapterWords: row.chapterWords,
        deadline: row.deadline,
        updatedAt: row.updatedAt,
      );

  WritingSessionRowsCompanion _writingSessionCompanion(
    WritingSession session,
  ) =>
      WritingSessionRowsCompanion.insert(
        id: session.id,
        projectId: session.projectId,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        durationSeconds: session.duration.inSeconds,
        startingWordCount: session.startingWordCount,
        endingWordCount: session.endingWordCount,
        wordsAdded: session.wordsAdded,
        wordsRemoved: session.wordsRemoved,
        chapterId: Value(session.chapterId),
        sceneId: Value(session.sceneId),
        pastedWords: Value(session.pastedWords),
        provocationFamily: Value(session.provocationFamily),
      );

  WritingSession _writingSessionFromRow(WritingSessionRow row) =>
      WritingSession(
        id: row.id,
        projectId: row.projectId,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        duration: Duration(seconds: row.durationSeconds),
        startingWordCount: row.startingWordCount,
        endingWordCount: row.endingWordCount,
        wordsAdded: row.wordsAdded,
        wordsRemoved: row.wordsRemoved,
        pastedWords: row.pastedWords,
        provocationFamily: row.provocationFamily,
        chapterId: row.chapterId,
        sceneId: row.sceneId,
      );

  @override
  Future<void> putRecordTypeDefinition(
    RecordTypeDefinition definition,
  ) async {
    RecordTypeRegistry([definition]);
    await database
        .into(database.recordTypeDefinitionRows)
        .insertOnConflictUpdate(
          RecordTypeDefinitionRowsCompanion.insert(
            id: definition.id,
            name: definition.name,
            categoryId: definition.categoryId,
            baseTypeId: Value(definition.baseTypeId),
            scopeType: definition.scopeType.name,
            scopeId: definition.scopeId,
            templateVersion: definition.templateVersion,
            builtIn: definition.builtIn,
            definitionJson: jsonEncode(definition.toJson()),
          ),
        );
  }

  @override
  Future<RecordTypeDefinition?> recordTypeDefinitionById(String id) async {
    final row = await (database.select(database.recordTypeDefinitionRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _definitionFromRow(row);
  }

  @override
  Future<void> putConnectionTypeDefinition(
    ConnectionTypeDefinition definition,
  ) async {
    ConnectionTypeRegistry([definition]);
    await database
        .into(database.connectionTypeDefinitionRows)
        .insertOnConflictUpdate(
          ConnectionTypeDefinitionRowsCompanion.insert(
            id: definition.id,
            displayName: definition.displayName,
            scopeId: definition.scopeId,
            builtIn: definition.builtIn,
            definitionJson: jsonEncode(definition.toJson()),
          ),
        );
  }

  @override
  Future<List<ConnectionTypeDefinition>> connectionTypeDefinitionsByScope(
    String scopeId,
  ) async {
    final rows = await (database.select(database.connectionTypeDefinitionRows)
          ..where((table) => table.scopeId.equals(scopeId))
          ..orderBy([(table) => OrderingTerm.asc(table.displayName)]))
        .get();
    return rows.map(_connectionDefinitionFromRow).toList();
  }

  @override
  Future<void> putBranch(StoryBranch branch) async {
    await database.into(database.storyBranchRows).insertOnConflictUpdate(
          StoryBranchRowsCompanion.insert(
            id: branch.id,
            projectId: branch.projectId,
            parentBranchId: Value(branch.parentBranchId),
            name: branch.name,
            kind: branch.kind.name,
            status: branch.status.name,
            branchJson: jsonEncode(branch.toJson()),
          ),
        );
  }

  @override
  Future<void> putBranchRecordOverlay(BranchRecordOverlay overlay) async {
    await database
        .into(database.branchRecordOverlayRows)
        .insertOnConflictUpdate(
          BranchRecordOverlayRowsCompanion.insert(
            branchId: overlay.branchId,
            recordId: overlay.recordId,
            state: overlay.state.name,
            overlayJson: jsonEncode(overlay.toJson()),
          ),
        );
    final branch = await (database.select(database.storyBranchRows)
          ..where((table) => table.id.equals(overlay.branchId)))
        .getSingle();
    await database._indexBranchOverlay(overlay, branch.projectId);
  }

  @override
  Future<void> putBranchLinkOverlay(BranchLinkOverlay overlay) async {
    await database.into(database.branchLinkOverlayRows).insertOnConflictUpdate(
          BranchLinkOverlayRowsCompanion.insert(
            branchId: overlay.branchId,
            linkId: overlay.linkId,
            state: overlay.state.name,
            overlayJson: jsonEncode(overlay.toJson()),
          ),
        );
  }

  @override
  Future<List<StoryBranch>> branchesByProject(String projectId) async {
    final rows = await (database.select(database.storyBranchRows)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
    return rows.map(_branchFromRow).toList();
  }

  @override
  Future<List<BranchRecordOverlay>> branchRecordOverlays(
    Iterable<String> branchIds,
  ) async {
    final ids = branchIds.toList();
    if (ids.isEmpty) return [];
    final rows = await (database.select(database.branchRecordOverlayRows)
          ..where((table) => table.branchId.isIn(ids)))
        .get();
    return rows.map(_branchRecordOverlayFromRow).toList();
  }

  @override
  Future<List<BranchLinkOverlay>> branchLinkOverlays(
    Iterable<String> branchIds,
  ) async {
    final ids = branchIds.toList();
    if (ids.isEmpty) return [];
    final rows = await (database.select(database.branchLinkOverlayRows)
          ..where((table) => table.branchId.isIn(ids)))
        .get();
    return rows.map(_branchLinkOverlayFromRow).toList();
  }

  @override
  Future<List<RecordTypeDefinition>> recordTypeDefinitionsByScope({
    required RecordScopeType scopeType,
    required String scopeId,
  }) async {
    final rows = await (database.select(database.recordTypeDefinitionRows)
          ..where(
            (table) =>
                table.scopeType.equals(scopeType.name) &
                table.scopeId.equals(scopeId),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
    return rows.map(_definitionFromRow).toList();
  }

  @override
  Future<List<AuthorRecord>> recordsByTypeAndScope({
    required String typeId,
    required String scopeId,
  }) async {
    final rows = await (database.select(database.authorRecordRows)
          ..where(
            (table) =>
                table.typeId.equals(typeId) & table.scopeId.equals(scopeId),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  @override
  Future<List<AuthorRecord>> recordsByScope(String scopeId) async {
    final rows = await (database.select(database.authorRecordRows)
          ..where((table) => table.scopeId.equals(scopeId))
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  @override
  Future<List<AuthorRecord>> recordsByProject(String projectId) async {
    final rows = await (database.select(database.authorRecordRows)
          ..where(
            (table) =>
                table.projectId.equals(projectId) |
                table.scopeId.equals(projectId),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  /// Every record of [typeId], in every scope.
  ///
  /// The scoped reads above cannot find a series: a series is owned by the
  /// series scope it defines, so no project's scope id matches it. This is a
  /// query — it adds no table, no column and no second store.
  @override
  Future<List<AuthorRecord>> recordsByType(String typeId) async {
    final rows = await (database.select(database.authorRecordRows)
          ..where((table) => table.typeId.equals(typeId))
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  /// The records owned by [seriesId]'s shared scope.
  ///
  /// Named for records rather than projects, and deliberately unlike the
  /// roster's `booksInSeries`: that one answers "which books are in this
  /// series?" from `project_rows`, this one answers "what canon does this
  /// series hold?" from `author_record_rows`. They take the same id and mean
  /// different things, so they must not share a name.
  ///
  /// Served by the existing `author_records_series_book` index, whose leading
  /// column is `series_id`.
  @override
  Future<List<AuthorRecord>> recordsInSeriesScope(String seriesId) async {
    final rows = await (database.select(database.authorRecordRows)
          ..where(
            (table) =>
                table.scopeId.equals(seriesId) &
                table.scopeType.isIn(_sharedScopeNames),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  /// The records a project may read: its own, plus anything owned by a scope
  /// the project inherits from.
  ///
  /// [inheritedScopeIds] carries the shared scope ids the caller resolved.
  /// Passing none is exactly [recordsByProject], so a project that belongs to
  /// no series reads precisely what it read before this method existed.
  @override
  Future<List<AuthorRecord>> recordsVisibleToProject(
    String projectId, {
    Iterable<String> inheritedScopeIds = const [],
  }) async {
    final inherited = inheritedScopeIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && id != projectId)
        .toSet();
    if (inherited.isEmpty) return recordsByProject(projectId);
    final rows = await (database.select(database.authorRecordRows)
          ..where(
            (table) =>
                table.projectId.equals(projectId) |
                table.scopeId.equals(projectId) |
                (table.scopeId.isIn(inherited) &
                    table.scopeType.isIn(_sharedScopeNames)),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.title)]))
        .get();
    return rows.map(_recordFromRow).toList();
  }

  @override
  Future<List<AuthorRecord>> recordsByTagAndScope({
    required String tagId,
    required String scopeId,
  }) async {
    final records = await recordsByScope(scopeId);
    return records.where((record) => record.tags.contains(tagId)).toList();
  }

  @override
  Future<void> replaceSnapshot(ConnectedDomainSnapshot snapshot) async {
    InMemoryConnectedDomainRepository(initial: snapshot);
    await database.transaction(() async {
      await database.delete(database.auditEventRows).go();
      await database.delete(database.recordVersionRows).go();
      await database.delete(database.recordLinkRows).go();
      await database.delete(database.branchLinkOverlayRows).go();
      await database.delete(database.branchRecordOverlayRows).go();
      await database.delete(database.storyBranchRows).go();
      await database.delete(database.connectionTypeDefinitionRows).go();
      await database.delete(database.recordTypeDefinitionRows).go();
      await database.delete(database.authorRecordRows).go();
      await database.delete(database.manuscriptNodeRows).go();
      await database.delete(database.connectedEntities).go();
      // A restore is a whole-snapshot replace, so session history goes with
      // it. Leaving it behind would leave totals and streaks describing a
      // manuscript that no longer exists.
      await database.delete(database.writingSessionRows).go();
      // And the decisions with them, for the same reason: a dismissal names a
      // finding in a manuscript that is being replaced, and keeping it would
      // suppress findings in a book it was never about.
      await database.delete(database.revisionDecisionRows).go();
      if (database.schemaVersion >= 2) {
        await database.customStatement('DELETE FROM author_search');
      }
      // Prose has no entity row, so the deletes above leave it untouched.
      // Without this the scenes of the replaced project would keep answering
      // searches, and their words would attach themselves to whichever new
      // scene happened to reuse an id.
      if (_supportsSceneProse) {
        await database.customStatement('DELETE FROM scene_prose_rows');
      }
      await _insertSnapshot(snapshot);
    });
  }

  @override
  Future<void> putConnectedSlice({
    required AuthorRecord record,
    required ManuscriptNodeReference manuscriptNode,
    required RecordLink link,
  }) async {
    final snapshot = ConnectedDomainSnapshot(
      records: [record],
      manuscriptNodes: [manuscriptNode],
      links: [link],
    );
    InMemoryConnectedDomainRepository(initial: snapshot);
    await database.transaction(() async {
      await _putEntity(record.id, 'record', record.scopeId);
      await _putRecord(record);
      await _putEntity(
        manuscriptNode.id,
        'manuscriptNode',
        manuscriptNode.projectId,
      );
      await _putManuscriptNode(manuscriptNode);
      await _putLink(link);
    });
  }

  @override
  Future<AuthorRecord?> recordById(String id) async {
    final row = await (database.select(database.authorRecordRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _recordFromRow(row);
  }

  /// Hydrates many records in one pass.
  ///
  /// A graph read resolves a whole neighbourhood at once, and doing that
  /// through [recordById] costs one query per edge. Missing ids are simply
  /// absent from the result: an id may name a manuscript node rather than a
  /// record, and asking for both kinds is normal.
  @override
  Future<List<AuthorRecord>> recordsByIds(Iterable<String> ids) async {
    final rows = await _rowsByIds(
      ids,
      (chunk) => (database.select(database.authorRecordRows)
            ..where((table) => table.id.isIn(chunk))
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get(),
    );
    return rows.map(_recordFromRow).toList();
  }

  /// The manuscript-node half of [recordsByIds].
  ///
  /// Scenes and chapters are a second node kind (decision D-3), so a graph read
  /// that hydrated only records would silently drop half the manuscript spine.
  @override
  Future<List<ManuscriptNodeReference>> manuscriptNodesByIds(
    Iterable<String> ids,
  ) async {
    final rows = await _rowsByIds(
      ids,
      (chunk) => (database.select(database.manuscriptNodeRows)
            ..where((table) => table.id.isIn(chunk))
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get(),
    );
    return rows.map(_nodeFromRow).toList();
  }

  /// Every link touching any of [ids], in either direction.
  ///
  /// [typeIds] filters in SQL rather than in the caller. That matters because
  /// `relatedTo` is suggested on every record type: excluding it here keeps the
  /// rows out of memory instead of discarding them after the fact.
  @override
  Future<List<RecordLink>> linksForEntities(
    Iterable<String> ids, {
    Set<String>? typeIds,
  }) async {
    if (typeIds != null && typeIds.isEmpty) return const [];
    final rows = await _rowsByIds(
      ids,
      (chunk) => (database.select(database.recordLinkRows)
            ..where((table) {
              final touches =
                  table.sourceId.isIn(chunk) | table.targetId.isIn(chunk);
              return typeIds == null
                  ? touches
                  : touches & table.typeId.isIn(typeIds.toList());
            })
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get(),
    );
    // A link between two ids in the same chunk is returned once, but a link
    // spanning two chunks comes back from both, so the id set is the authority.
    final seen = <String>{};
    return [
      for (final row in rows)
        if (seen.add(row.id)) _linkFromRow(row),
    ];
  }

  /// Runs [query] over [ids] in chunks, so a large neighbourhood cannot exceed
  /// SQLite's bound-variable limit.
  Future<List<T>> _rowsByIds<T>(
    Iterable<String> ids,
    Future<List<T>> Function(List<String> chunk) query,
  ) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const [];
    const chunkSize = 400;
    final rows = <T>[];
    for (var start = 0; start < unique.length; start += chunkSize) {
      final end =
          start + chunkSize < unique.length ? start + chunkSize : unique.length;
      rows.addAll(await query(unique.sublist(start, end)));
    }
    return rows;
  }

  /// Every manuscript node the project owns.
  ///
  /// A project's manuscript is authoritative for its own chapters and scenes,
  /// so saving one has to be able to see which nodes already exist in order to
  /// retire the ones the manuscript no longer contains.
  @override
  Future<List<ManuscriptNodeReference>> manuscriptNodesForProject(
    String projectId,
  ) async {
    final rows = await (database.select(database.manuscriptNodeRows)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_nodeFromRow).toList();
  }

  @override
  Future<ManuscriptNodeReference?> manuscriptNodeById(String id) async {
    final row = await (database.select(database.manuscriptNodeRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _nodeFromRow(row);
  }

  /// Every manuscript node in [projectId], read straight from the table.
  ///
  /// Read-only and side-effect free, which is the whole point: the obvious way
  /// to answer "which chapter is this scene in" is `ManuscriptStore.loadStudio`,
  /// but that seeds a starter manuscript on a project nobody has opened yet.
  /// Anything that only wants to *look* at manuscript structure reads here
  /// instead, so a read can never create a chapter.
  @override

  /// Every manuscript node belonging to [projectId], in identity order.
  ///
  /// The record side already had [recordsByProject]; the manuscript side had
  /// only a by-id read, which is why a graph reader could see records but not
  /// scenes and chapters. This closes that asymmetry using the existing
  /// `manuscript_nodes_project` index. It adds no table and no schema change.
  ///
  /// Ordering is by id rather than title so graph reads are deterministic:
  /// two manuscript nodes may share a title, ids never collide.
  Future<List<ManuscriptNodeReference>> manuscriptNodesByProject(
    String projectId,
  ) async {
    final rows = await (database.select(database.manuscriptNodeRows)
          ..where((table) => table.projectId.equals(projectId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_nodeFromRow).toList();
  }

  @override

  /// Counts records in [projectId] without materialising them.
  ///
  /// Soft-deleted records are excluded unless [includeDeleted] is set, so the
  /// count matches what a default graph or Studio read would actually show.
  Future<int> countRecordsByProject(
    String projectId, {
    bool includeDeleted = false,
  }) async {
    final table = database.authorRecordRows;
    final total = table.id.count();
    var predicate =
        table.projectId.equals(projectId) | table.scopeId.equals(projectId);
    if (!includeDeleted) {
      predicate = predicate &
          table.status.equals(AuthorRecordStatus.deleted.name).not();
    }
    final query = database.selectOnly(table)
      ..addColumns([total])
      ..where(predicate);
    return await query.map((row) => row.read(total) ?? 0).getSingle();
  }

  /// Counts manuscript nodes in [projectId] without materialising them.
  Future<int> countManuscriptNodesByProject(String projectId) async {
    final total = database.manuscriptNodeRows.id.count();
    final query = database.selectOnly(database.manuscriptNodeRows)
      ..addColumns([total])
      ..where(database.manuscriptNodeRows.projectId.equals(projectId));
    return await query.map((row) => row.read(total) ?? 0).getSingle();
  }

  /// Counts relationships scoped to [scopeId] without materialising them.
  Future<int> countLinksByScope(String scopeId) async {
    final total = database.recordLinkRows.id.count();
    final query = database.selectOnly(database.recordLinkRows)
      ..addColumns([total])
      ..where(database.recordLinkRows.scopeId.equals(scopeId));
    return await query.map((row) => row.read(total) ?? 0).getSingle();
  }

  Future<List<RecordLink>> backlinks(String entityId) async {
    final rows = await (database.select(database.recordLinkRows)
          ..where((table) =>
              table.sourceId.equals(entityId) | table.targetId.equals(entityId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_linkFromRow).toList();
  }

  @override
  Future<List<RecordLink>> outgoingLinks(String entityId) async {
    final rows = await (database.select(database.recordLinkRows)
          ..where((table) => table.sourceId.equals(entityId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_linkFromRow).toList();
  }

  @override
  Future<List<RecordLink>> incomingLinks(String entityId) async {
    final rows = await (database.select(database.recordLinkRows)
          ..where((table) => table.targetId.equals(entityId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_linkFromRow).toList();
  }

  @override
  Future<RecordLink?> linkById(String id) async {
    final row = await (database.select(database.recordLinkRows)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _linkFromRow(row);
  }

  @override
  Future<List<RecordLink>> linksByScope(String scopeId) async {
    final rows = await (database.select(database.recordLinkRows)
          ..where((table) => table.scopeId.equals(scopeId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return rows.map(_linkFromRow).toList();
  }

  @override
  Future<String?> entityScopeId(String entityId) async {
    final row = await (database.select(database.connectedEntities)
          ..where((table) => table.id.equals(entityId)))
        .getSingleOrNull();
    return row?.scopeId;
  }

  @override
  Future<String?> entityTypeId(String entityId) async {
    final record = await recordById(entityId);
    if (record != null) {
      return record.typeId;
    }
    return (await manuscriptNodeById(entityId))?.nodeType;
  }

  @override
  Future<String?> entityProjectId(String entityId) async {
    final record = await recordById(entityId);
    if (record != null) {
      return record.projectId ?? record.scopeId;
    }
    return (await manuscriptNodeById(entityId))?.projectId;
  }

  /// Resolves the endpoint facts a relationship validator needs for
  /// [entityId], without deciding whether the entity may be linked.
  @override
  Future<RelationshipEndpoint> relationshipEndpoint(String entityId) async {
    final record = await recordById(entityId);
    if (record != null) {
      return RelationshipEndpoint.fromRecord(record);
    }
    final node = await manuscriptNodeById(entityId);
    if (node != null) {
      return RelationshipEndpoint.fromManuscriptNode(node);
    }
    return RelationshipEndpoint.missing(entityId);
  }

  @override
  Future<void> deleteLink(String linkId) async {
    await (database.delete(database.recordLinkRows)
          ..where((table) => table.id.equals(linkId)))
        .go();
  }

  @override
  Future<List<SearchIndexHit>> searchIndex(
    String query, {
    required String exactQuery,
    required UniversalSearchFilter filter,
  }) async {
    if (database.schemaVersion < 2 || query.trim().isEmpty) {
      return [];
    }
    final conditions = <String>[
      'author_search MATCH ?',
      'project_id = ?',
      filter.branchId == null
          ? "entity_kind != 'branchRecord' AND branch_id IS NULL"
          : "(entity_kind = 'branchRecord' AND branch_id = ? OR "
              "entity_kind != 'branchRecord' AND branch_id IS NULL)",
    ];
    final variables = <Variable>[
      Variable<String>(query.trim()),
      Variable<String>(filter.projectId),
      if (filter.branchId != null) Variable<String>(filter.branchId!),
    ];
    void addFilter(String column, String? value) {
      if (value == null) return;
      conditions.add('$column = ?');
      variables.add(Variable<String>(value));
    }

    addFilter('type_id', filter.recordType);
    addFilter('series_id', filter.seriesId);
    addFilter('book_id', filter.bookId);
    if (filter.branchId == null) {
      addFilter('canon_status', filter.canonStatus?.name);
    }
    addFilter('lifecycle_status', filter.lifecycleStatus?.name);
    final rows = await database.customSelect('''
      SELECT entity_id, entity_kind, title,
        snippet(author_search, 11, '<b>', '</b>', '...', 20) AS snippet,
        CASE WHEN lower(title) = lower(?) THEN -1000.0
          ELSE bm25(author_search) END AS search_rank,
        CASE
          WHEN lower(title) = lower(?) THEN 'title'
          ELSE 'content'
        END AS matched_field
      FROM author_search
      WHERE ${conditions.join(' AND ')}
      ORDER BY CASE WHEN lower(title) = lower(?) THEN 0 ELSE 1 END,
        search_rank
      LIMIT ?
    ''', variables: [
      Variable<String>(exactQuery.trim()),
      Variable<String>(exactQuery.trim()),
      ...variables,
      Variable<String>(exactQuery.trim()),
      Variable<int>(
        filter.branchId != null && filter.canonStatus != null
            ? filter.limit * 5
            : filter.limit,
      ),
    ]).get();
    return rows.map((row) {
      final rawKind = row.read<String>('entity_kind');
      return SearchIndexHit(
        entityId: row.read<String>('entity_id'),
        kind: SearchEntityKind.values.firstWhere(
          (kind) => kind.name == rawKind,
        ),
        title: row.read<String>('title'),
        snippet: row.read<String>('snippet'),
        rank: row.read<double>('search_rank'),
        matchedField: row.read<String>('matched_field'),
      );
    }).toList();
  }

  @override
  Future<List<String>> searchEntityIds(String query) async {
    if (database.schemaVersion < 2 || query.trim().isEmpty) return [];
    final rows = await database.customSelect(
      "SELECT entity_id FROM author_search WHERE author_search MATCH ? "
      "AND entity_kind != 'branchRecord' ORDER BY rank",
      variables: [Variable<String>(query.trim())],
    ).get();
    return rows.map((row) => row.read<String>('entity_id')).toList();
  }

  @override
  Future<ConnectedDomainSnapshot> snapshot() async {
    final recordRows = await (database.select(database.authorRecordRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final nodeRows = await (database.select(database.manuscriptNodeRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final linkRows = await (database.select(database.recordLinkRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final definitionRows =
        await (database.select(database.recordTypeDefinitionRows)
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();
    final connectionDefinitionRows =
        await (database.select(database.connectionTypeDefinitionRows)
              ..orderBy([
                (table) => OrderingTerm.asc(table.scopeId),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    final branchRows = await (database.select(database.storyBranchRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final branchRecordRows =
        await database.select(database.branchRecordOverlayRows).get();
    final branchLinkRows =
        await database.select(database.branchLinkOverlayRows).get();
    final versionRows = await (database.select(database.recordVersionRows)
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
    final auditRows = await (database.select(database.auditEventRows)
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
    final sessionRows = await (database.select(database.writingSessionRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final decisionRows = await (database.select(database.revisionDecisionRows)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final proseRows = _supportsSceneProse
        ? await database
            .customSelect(
              'SELECT * FROM scene_prose_rows ORDER BY scene_id',
            )
            .get()
        : const <QueryRow>[];
    return ConnectedDomainSnapshot(
      records: recordRows.map(_recordFromRow).toList(),
      manuscriptNodes: nodeRows.map(_nodeFromRow).toList(),
      links: linkRows.map(_linkFromRow).toList(),
      recordTypeDefinitions: definitionRows.map(_definitionFromRow).toList(),
      connectionTypeDefinitions:
          connectionDefinitionRows.map(_connectionDefinitionFromRow).toList(),
      branches: branchRows.map(_branchFromRow).toList(),
      branchRecordOverlays:
          branchRecordRows.map(_branchRecordOverlayFromRow).toList(),
      branchLinkOverlays:
          branchLinkRows.map(_branchLinkOverlayFromRow).toList(),
      versions: versionRows.map(_versionFromRow).toList(),
      auditEvents: auditRows.map(_auditFromRow).toList(),
      writingSessions: sessionRows.map(_writingSessionFromRow).toList(),
      revisionDecisions: decisionRows
          .map(_revisionDecisionFromRow)
          .whereType<RevisionDecision>()
          .toList(),
      sceneProse: proseRows.map(_proseFromRow).toList(),
    );
  }

  Future<void> _insertSnapshot(ConnectedDomainSnapshot snapshot) async {
    for (final branch in snapshot.branches) {
      await putBranch(branch);
    }
    for (final record in snapshot.records) {
      await _putEntity(record.id, 'record', record.scopeId);
      await _putRecord(record);
    }
    // Before the nodes, not after: indexing a scene reads its prose, so prose
    // that arrived second would not be searchable until the next save.
    await putSceneProse(snapshot.sceneProse);
    for (final node in snapshot.manuscriptNodes) {
      await _putEntity(node.id, 'manuscriptNode', node.projectId);
      await _putManuscriptNode(node);
    }
    for (final link in snapshot.links) {
      await _putLink(link);
    }
    for (final definition in snapshot.recordTypeDefinitions) {
      await putRecordTypeDefinition(definition);
    }
    for (final definition in snapshot.connectionTypeDefinitions) {
      await putConnectionTypeDefinition(definition);
    }
    for (final overlay in snapshot.branchRecordOverlays) {
      await putBranchRecordOverlay(overlay);
    }
    for (final overlay in snapshot.branchLinkOverlays) {
      await putBranchLinkOverlay(overlay);
    }
    if (snapshot.writingSessions.isNotEmpty) {
      await putWritingSessions(snapshot.writingSessions);
    }
    if (snapshot.revisionDecisions.isNotEmpty) {
      await putRevisionDecisions(snapshot.revisionDecisions);
    }
    for (final version in snapshot.versions) {
      await _insertVersion(version);
    }
    for (final event in snapshot.auditEvents) {
      await _insertAuditEvent(event);
    }
  }

  Future<void> _appendHistory(
    RecordVersion version,
    AuditEvent auditEvent,
  ) async {
    if (auditEvent.versionId != version.id ||
        auditEvent.projectId != version.projectId ||
        auditEvent.entityId != version.entityId) {
      throw StateError('Audit event does not match its version.');
    }
    await _insertVersion(version);
    await _insertAuditEvent(auditEvent);
  }

  Future<void> _insertVersion(RecordVersion version) => database
      .into(database.recordVersionRows)
      .insert(RecordVersionRowsCompanion.insert(
        id: version.id,
        entityId: version.entityId,
        entityKind: version.entityKind.name,
        recordId: version.recordId,
        recordType: version.recordType,
        projectId: version.projectId,
        seriesId: Value(version.seriesId),
        bookId: Value(version.bookId),
        branchId: Value(version.branchId),
        changeType: version.changeType.name,
        createdAt: version.createdAt,
        previousVersionId: Value(version.previousVersionId),
        versionJson: jsonEncode(version.toJson()),
      ));

  Future<void> _insertAuditEvent(AuditEvent event) => database
      .into(database.auditEventRows)
      .insert(AuditEventRowsCompanion.insert(
        id: event.id,
        versionId: event.versionId,
        entityId: event.entityId,
        entityKind: event.entityKind.name,
        recordId: event.recordId,
        recordType: event.recordType,
        projectId: event.projectId,
        seriesId: Value(event.seriesId),
        bookId: Value(event.bookId),
        branchId: Value(event.branchId),
        changeType: event.changeType.name,
        createdAt: event.createdAt,
        eventJson: jsonEncode(event.toJson()),
      ));

  Future<void> _putEntity(String id, String kind, String scopeId) =>
      database.into(database.connectedEntities).insertOnConflictUpdate(
            ConnectedEntitiesCompanion.insert(
              id: id,
              kind: kind,
              scopeId: scopeId,
            ),
          );

  Future<void> _putRecord(AuthorRecord record) async {
    await database.into(database.authorRecordRows).insertOnConflictUpdate(
          AuthorRecordRowsCompanion.insert(
            id: record.id,
            typeId: record.typeId,
            scopeType: record.scopeType.name,
            scopeId: record.scopeId,
            projectId: Value(record.projectId),
            seriesId: Value(record.seriesId),
            bookId: Value(record.bookId),
            branchId: Value(record.branchId),
            canonStatus: Value(record.canonStatus.name),
            title: record.title,
            status: record.status.name,
            schemaVersion: record.schemaVersion,
            templateId: Value(record.templateId),
            templateVersion: Value(record.templateVersion),
            revision: record.revision,
            fieldsJson: jsonEncode(record.fields),
            tagsJson: jsonEncode(record.tags),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            extensionJson: jsonEncode(record.extensionData),
          ),
        );
    await _indexEntity(
      entityId: record.id,
      kind: SearchEntityKind.record,
      projectId: record.projectId ?? record.scopeId,
      seriesId: record.seriesId,
      bookId: record.bookId,
      branchId: record.branchId,
      canonStatus: record.canonStatus,
      lifecycleStatus: record.status,
      typeId: record.typeId,
      templateId: record.templateId,
      title: record.title,
      body: jsonEncode(_searchableFields(record)),
      tags: record.tags,
    );
    if (database.schemaVersion >= 7) {
      final overlays = await database.customSelect('''
        SELECT o.overlay_json, b.project_id
        FROM branch_record_overlay_rows o
        JOIN story_branch_rows b ON b.id = o.branch_id
        WHERE o.record_id = ?
      ''', variables: [Variable<String>(record.id)]).get();
      for (final row in overlays) {
        await database._indexBranchOverlay(
          BranchRecordOverlay.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(row.read<String>('overlay_json')) as Map,
            ),
          ),
          row.read<String>('project_id'),
        );
      }
    }
  }

  Future<void> _putManuscriptNode(ManuscriptNodeReference node) async {
    await database.into(database.manuscriptNodeRows).insertOnConflictUpdate(
          ManuscriptNodeRowsCompanion.insert(
            id: node.id,
            projectId: node.projectId,
            nodeType: node.nodeType,
            title: node.title,
            revision: node.revision,
            createdAt: node.createdAt,
            updatedAt: node.updatedAt,
            extensionJson: jsonEncode(node.extensionData),
          ),
        );
    // The manuscript root is stored and deliberately not indexed. It carries
    // the project-level fields -- the title, the cursor positions, the version
    // -- and its extension data is machine identifiers rather than anything an
    // author wrote. Indexing it puts `scene-a1` and `manuscript:project-1`
    // into the body every search reads, so a search for a scene's title
    // returns the manuscript as well as the scene.
    //
    // The literal rather than a shared constant because Lock 12 fixes the
    // dependency direction: persistence cannot import the service that owns
    // the name. `'scene'` below is hardcoded for the same reason.
    if (node.nodeType == 'manuscript') return;

    final metadata = jsonEncode(node.extensionData);
    // The stored plain-text projection, not the document: this runs once per
    // node on every manuscript save, and the index wants the words, not the
    // marks around them.
    final prose =
        node.nodeType == 'scene' ? await _sceneProsePlainText(node.id) : null;
    await _indexEntity(
      entityId: node.id,
      kind: SearchEntityKind.manuscriptNode,
      projectId: node.projectId,
      canonStatus: CanonStatus.canon,
      lifecycleStatus: AuthorRecordStatus.active,
      typeId: node.nodeType,
      title: node.title,
      body: prose == null || prose.isEmpty ? metadata : '$metadata\n$prose',
    );
  }

  Future<String?> _sceneProsePlainText(String sceneId) async {
    if (!_supportsSceneProse) return null;
    final row = await database.customSelect(
      'SELECT plain_text FROM scene_prose_rows WHERE scene_id = ?',
      variables: [Variable<String>(sceneId)],
    ).getSingleOrNull();
    return row?.read<String>('plain_text');
  }

  Future<void> _putLink(RecordLink link) =>
      database.into(database.recordLinkRows).insertOnConflictUpdate(
            RecordLinkRowsCompanion.insert(
              id: link.id,
              sourceId: link.sourceId,
              targetId: link.targetId,
              typeId: link.typeId,
              scopeId: link.scopeId,
              direction: link.direction.name,
              label: link.label,
              revision: link.revision,
              metadataJson: jsonEncode(link.metadata),
              createdAt: link.createdAt,
              updatedAt: link.updatedAt,
              extensionJson: jsonEncode(link.extensionData),
            ),
          );

  /// The built-in type vocabulary, for deciding what reaches the index.
  ///
  /// Built once and synchronously — `BuiltInRecordTypes.registry()` is a list
  /// and a map, with no I/O — so the write path pays nothing per record and
  /// needs no injection, no cache invalidation and no constructor change.
  static final RecordTypeRegistry _searchTypes = BuiltInRecordTypes.registry();

  /// [record]'s fields, minus the ones their definition marks unsearchable.
  ///
  /// Before S0a the index stored `jsonEncode(record.fields)` outright, so
  /// every field was searchable whether or not that made sense, and the
  /// `extensionData: {'searchable': true}` convention that was supposed to say
  /// otherwise was never read by anything. This is where the canonical
  /// property finally takes effect.
  ///
  /// [RecordFieldDefinition.searchable] defaults to true, so a record whose
  /// type says nothing indexes exactly as it did before. A type the built-in
  /// registry has never heard of — a custom type registered at runtime —
  /// indexes in full for the same reason: excluding a field needs a definition
  /// that asks for it, and absence is not an instruction.
  Map<String, Object?> _searchableFields(AuthorRecord record) =>
      searchableFieldsOf(record, _searchTypes);

  /// The filter itself, over any registry.
  ///
  /// Separated from the write path so the rule can be tested against a type
  /// that opts out. No built-in field does today — the property's whole point
  /// is that existing definitions keep indexing exactly as they did — so a
  /// test driven only through the built-in vocabulary would pass whether or
  /// not this filter ran at all.
  @visibleForTesting
  static Map<String, Object?> searchableFieldsOf(
    AuthorRecord record,
    RecordTypeRegistry types,
  ) {
    final RecordTypeDefinition definition;
    try {
      definition = types.resolve(record.templateId ?? record.typeId);
    } on StateError {
      return record.fields;
    }
    final excluded = {
      for (final field in definition.fields)
        if (!field.searchable) field.id,
    };
    if (excluded.isEmpty) return record.fields;
    return {
      for (final entry in record.fields.entries)
        if (!excluded.contains(entry.key)) entry.key: entry.value,
    };
  }

  Future<void> _indexEntity({
    required String entityId,
    required SearchEntityKind kind,
    required String projectId,
    required CanonStatus canonStatus,
    required AuthorRecordStatus lifecycleStatus,
    required String typeId,
    required String title,
    required String body,
    String? seriesId,
    String? bookId,
    String? branchId,
    String? templateId,
    List<String> tags = const [],
  }) async {
    if (database.schemaVersion < 2) {
      return;
    }
    await database.customStatement(
      'DELETE FROM author_search WHERE entity_id = ? AND entity_kind = ?',
      [entityId, kind.name],
    );
    await database.customStatement('''
      INSERT INTO author_search(
        entity_id, entity_kind, project_id, series_id, book_id, branch_id,
        canon_status, lifecycle_status, type_id, template_id, title, body, tags
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      entityId,
      kind.name,
      projectId,
      seriesId,
      bookId,
      branchId,
      canonStatus.name,
      lifecycleStatus.name,
      typeId,
      templateId,
      title,
      body,
      jsonEncode(tags),
    ]);
  }

  AuthorRecord _recordFromRow(AuthorRecordRow row) => AuthorRecord.fromJson({
        'id': row.id,
        'typeId': row.typeId,
        'scopeType': row.scopeType,
        'scopeId': row.scopeId,
        'projectId': row.projectId,
        'seriesId': row.seriesId,
        'bookId': row.bookId,
        'branchId': row.branchId,
        'canonStatus': row.canonStatus,
        'title': row.title,
        'status': row.status,
        'schemaVersion': row.schemaVersion,
        'templateId': row.templateId,
        'templateVersion': row.templateVersion,
        'revision': row.revision,
        'fields': jsonDecode(row.fieldsJson),
        'tags': jsonDecode(row.tagsJson),
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'extensionData': jsonDecode(row.extensionJson),
      });

  ManuscriptNodeReference _nodeFromRow(ManuscriptNodeRow row) =>
      ManuscriptNodeReference.fromJson({
        'id': row.id,
        'projectId': row.projectId,
        'nodeType': row.nodeType,
        'title': row.title,
        'revision': row.revision,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'extensionData': jsonDecode(row.extensionJson),
      });

  RecordLink _linkFromRow(RecordLinkRow row) => RecordLink.fromJson({
        'id': row.id,
        'sourceId': row.sourceId,
        'targetId': row.targetId,
        'typeId': row.typeId,
        'scopeId': row.scopeId,
        'direction': row.direction,
        'label': row.label,
        'revision': row.revision,
        'metadata': jsonDecode(row.metadataJson),
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'updatedAt': row.updatedAt.toUtc().toIso8601String(),
        'extensionData': jsonDecode(row.extensionJson),
      });

  RecordTypeDefinition _definitionFromRow(RecordTypeDefinitionRow row) =>
      RecordTypeDefinition.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.definitionJson) as Map),
      );

  ConnectionTypeDefinition _connectionDefinitionFromRow(
    ConnectionTypeDefinitionRow row,
  ) =>
      ConnectionTypeDefinition.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.definitionJson) as Map),
      );

  StoryBranch _branchFromRow(StoryBranchRow row) => StoryBranch.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.branchJson) as Map),
      );

  BranchRecordOverlay _branchRecordOverlayFromRow(
    BranchRecordOverlayRow row,
  ) =>
      BranchRecordOverlay.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.overlayJson) as Map),
      );

  BranchLinkOverlay _branchLinkOverlayFromRow(BranchLinkOverlayRow row) =>
      BranchLinkOverlay.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.overlayJson) as Map),
      );

  RecordVersion _versionFromRow(RecordVersionRow row) => RecordVersion.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.versionJson) as Map),
      );

  AuditEvent _auditFromRow(AuditEventRow row) => AuditEvent.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.eventJson) as Map),
      );
}

List<String> _decodeStringList(String? value) {
  if (value == null) return const [];
  final decoded = jsonDecode(value);
  return decoded is List
      ? decoded.map((item) => item.toString()).toList()
      : const [];
}
