// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:buildbucket/buildbucket_pb.dart' as bbv2;
import 'package:cocoon_server_test/test_logging.dart';
import 'package:cocoon_service/cocoon_service.dart';
import 'package:cocoon_service/src/model/appengine/task.dart';
import 'package:cocoon_service/src/model/firestore/commit.dart'
    as firestore_commit;
import 'package:cocoon_service/src/model/firestore/task.dart' as firestore;
import 'package:cocoon_service/src/service/datastore.dart';
import 'package:cocoon_service/src/service/luci_build_service/firestore_task_document_name.dart';
import 'package:cocoon_service/src/service/luci_build_service/user_data.dart';
import 'package:fixnum/fixnum.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../src/datastore/fake_config.dart';
import '../src/request_handling/fake_authentication.dart';
import '../src/request_handling/fake_http.dart';
import '../src/request_handling/subscription_tester.dart';
import '../src/service/fake_ci_yaml_fetcher.dart';
import '../src/service/fake_luci_build_service.dart';
import '../src/service/fake_scheduler.dart';
import '../src/utilities/build_bucket_messages.dart';
import '../src/utilities/entity_generators.dart';
import '../src/utilities/mocks.dart';

void main() {
  useTestLoggerPerTest();

  late PostsubmitLuciSubscription handler;
  late FakeConfig config;
  late FakeHttpRequest request;
  late MockFirestoreService mockFirestoreService;
  late SubscriptionTester tester;
  late MockGithubChecksService mockGithubChecksService;
  late MockGithubChecksUtil mockGithubChecksUtil;
  late FakeScheduler scheduler;
  late FakeCiYamlFetcher ciYamlFetcher;

  firestore.Task? firestoreTask;
  firestore_commit.Commit? firestoreCommit;
  late int attempt;

  setUp(() async {
    firestoreTask = null;
    attempt = 0;
    mockGithubChecksUtil = MockGithubChecksUtil();
    mockFirestoreService = MockFirestoreService();
    config = FakeConfig(
      maxLuciTaskRetriesValue: 3,
      firestoreService: mockFirestoreService,
    );
    mockGithubChecksService = MockGithubChecksService();
    when(
      mockGithubChecksService.githubChecksUtil,
    ).thenReturn(mockGithubChecksUtil);
    when(
      mockGithubChecksUtil.createCheckRun(
        any,
        any,
        any,
        any,
        output: anyNamed('output'),
      ),
    ).thenAnswer((_) async => generateCheckRun(1, name: 'Linux A'));
    when(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    ).thenAnswer((_) async => true);
    when(mockFirestoreService.getDocument(captureAny)).thenAnswer((
      Invocation invocation,
    ) {
      attempt++;
      if (attempt == 1) {
        return Future<Document>.value(firestoreTask);
      } else {
        return Future<Document>.value(firestoreCommit);
      }
    });
    when(
      mockFirestoreService.queryRecentCommits(
        limit: captureAnyNamed('limit'),
        slug: captureAnyNamed('slug'),
        branch: captureAnyNamed('branch'),
      ),
    ).thenAnswer((Invocation invocation) {
      return Future<List<firestore_commit.Commit>>.value(
        <firestore_commit.Commit>[firestoreCommit!],
      );
    });
    when(
      mockFirestoreService.batchWriteDocuments(captureAny, captureAny),
    ).thenAnswer((Invocation invocation) {
      return Future<BatchWriteResponse>.value(BatchWriteResponse());
    });
    final luciBuildService = FakeLuciBuildService(
      config: config,
      githubChecksUtil: mockGithubChecksUtil,
    );
    scheduler = FakeScheduler(
      config: config,
      luciBuildService: luciBuildService,
    );
    ciYamlFetcher = FakeCiYamlFetcher();
    handler = PostsubmitLuciSubscription(
      cache: CacheService(inMemory: true),
      config: config,
      authProvider: FakeAuthenticationProvider(),
      githubChecksService: mockGithubChecksService,
      datastoreProvider: (_) => DatastoreService(config.db, 5),
      scheduler: scheduler,
      ciYamlFetcher: ciYamlFetcher,
    );
    request = FakeHttpRequest();
    tester = SubscriptionTester(request: request);
  });

  test('updates task based on message', () async {
    firestoreTask = generateFirestoreTask(1, attempts: 2, name: 'Linux A');
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux A',
      parent: commit,
    );

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.SUCCESS,
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
      number: 63405,
    );

    config.db.values[commit.key] = commit;
    config.db.values[task.key] = task;

    expect(task.status, Task.statusNew);
    expect(task.endTimestamp, 0);

    // Firestore checks before API call.
    expect(firestoreTask!.status, Task.statusNew);
    expect(firestoreTask!.buildNumber, null);

    await tester.post(handler);

    expect(task.status, Task.statusSucceeded);
    expect(task.endTimestamp, 1717430718072);

    // Firestore checks after API call.
    final captured =
        verify(
          mockFirestoreService.batchWriteDocuments(captureAny, captureAny),
        ).captured;
    expect(captured.length, 2);
    final batchWriteRequest = captured[0] as BatchWriteRequest;
    expect(batchWriteRequest.writes!.length, 1);
    final updatedDocument = batchWriteRequest.writes![0].update!;
    expect(updatedDocument.name, firestoreTask!.name);
    expect(firestoreTask!.status, Task.statusSucceeded);
    expect(firestoreTask!.buildNumber, 63405);
  });

  test('skips task processing when build is with scheduled status', () async {
    firestoreTask = generateFirestoreTask(
      1,
      name: 'Linux A',
      status: firestore.Task.statusInProgress,
    );
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux A',
      parent: commit,
      status: Task.statusInProgress,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.SCHEDULED,
      builder: 'Linux A',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    expect(firestoreTask!.status, firestore.Task.statusInProgress);
    expect(firestoreTask!.attempts, 1);
    expect(await tester.post(handler), Body.empty);
    expect(firestoreTask!.status, firestore.Task.statusInProgress);
  });

  test('skips task processing when task has already finished', () async {
    firestoreTask = generateFirestoreTask(
      1,
      name: 'Linux A',
      status: firestore.Task.statusSucceeded,
    );
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux A',
      parent: commit,
      status: Task.statusSucceeded,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.STARTED,
      builder: 'Linux A',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    expect(task.status, Task.statusSucceeded);
    expect(task.attempts, 1);
    expect(await tester.post(handler), Body.empty);
    expect(task.status, Task.statusSucceeded);
  });

  test('skips task processing when target has been deleted', () async {
    firestoreTask = generateFirestoreTask(
      1,
      name: 'Linux B',
      status: firestore.Task.statusSucceeded,
    );
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux B',
      parent: commit,
      status: Task.statusSucceeded,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;

    final userData = PostsubmitUserData(
      checkRunId: null,
      taskKey: '${task.key.id}',
      commitKey: '${task.key.parent?.id}',
      firestoreTaskDocumentName: FirestoreTaskDocumentName(
        commitSha: commit.sha!,
        taskName: task.name!,
        currentAttempt: task.attempts!,
      ),
    );
    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.STARTED,
      builder: 'Linux B',
      userData: userData,
    );

    expect(task.status, Task.statusSucceeded);
    expect(task.attempts, 1);
    expect(await tester.post(handler), Body.empty);
  });

  test('on failed builds auto-rerun the build', () async {
    firestoreTask = generateFirestoreTask(
      1,
      name: 'Linux A',
      status: firestore.Task.statusFailed,
      commitSha: '87f88734747805589f2131753620d61b22922822',
    );
    firestoreCommit = generateFirestoreCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux A',
      parent: commit,
      status: Task.statusFailed,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.FAILURE,
      builder: 'Linux A',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    expect(firestoreTask!.status, firestore.Task.statusFailed);
    expect(firestoreTask!.attempts, 1);
    expect(await tester.post(handler), Body.empty);
    final captured =
        verify(
          mockFirestoreService.batchWriteDocuments(captureAny, captureAny),
        ).captured;
    expect(captured.length, 2);
    final batchWriteRequest = captured[0] as BatchWriteRequest;
    expect(batchWriteRequest.writes!.length, 1);
    final insertedTaskDocument = batchWriteRequest.writes![0].update!;
    final resultTask = firestore.Task.fromDocument(
      taskDocument: insertedTaskDocument,
    );
    expect(resultTask.status, firestore.Task.statusInProgress);
    expect(resultTask.attempts, 2);
  });

  test('on canceled builds auto-rerun the build if they timed out', () async {
    firestoreTask = generateFirestoreTask(
      1,
      name: 'Linux A',
      status: firestore.Task.statusInfraFailure,
      commitSha: '87f88734747805589f2131753620d61b22922822',
    );
    firestoreCommit = generateFirestoreCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux A',
      parent: commit,
      status: Task.statusInfraFailure,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.CANCELED,
      builder: 'Linux A',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    expect(firestoreTask!.status, firestore.Task.statusInfraFailure);
    expect(firestoreTask!.attempts, 1);
    expect(await tester.post(handler), Body.empty);
    final captured =
        verify(
          mockFirestoreService.batchWriteDocuments(captureAny, captureAny),
        ).captured;
    expect(captured.length, 2);
    final batchWriteRequest = captured[0] as BatchWriteRequest;
    expect(batchWriteRequest.writes!.length, 1);
    final insertedTaskDocument = batchWriteRequest.writes![0].update!;
    final resultTask = firestore.Task.fromDocument(
      taskDocument: insertedTaskDocument,
    );
    expect(resultTask.status, firestore.Task.statusInProgress);
    expect(resultTask.attempts, 2);
  });

  test(
    'on builds resulting in an infra failure auto-rerun the build if they timed out',
    () async {
      firestoreTask = generateFirestoreTask(
        1,
        name: 'Linux A',
        status: firestore.Task.statusInfraFailure,
        commitSha: '87f88734747805589f2131753620d61b22922822',
      );
      firestoreCommit = generateFirestoreCommit(
        1,
        sha: '87f88734747805589f2131753620d61b22922822',
      );
      final commit = generateCommit(
        1,
        sha: '87f88734747805589f2131753620d61b22922822',
      );
      final task = generateTask(
        4507531199512576,
        name: 'Linux A',
        parent: commit,
        status: Task.statusInfraFailure,
      );
      config.db.values[task.key] = task;
      config.db.values[commit.key] = commit;

      tester.message = createPushMessage(
        Int64(1),
        status: bbv2.Status.INFRA_FAILURE,
        builder: 'Linux A',
        userData: PostsubmitUserData(
          checkRunId: null,
          taskKey: '${task.key.id}',
          commitKey: '${task.key.parent?.id}',
          firestoreTaskDocumentName: FirestoreTaskDocumentName(
            commitSha: commit.sha!,
            taskName: task.name!,
            currentAttempt: task.attempts!,
          ),
        ),
      );

      expect(task.status, Task.statusInfraFailure);
      expect(task.attempts, 1);
      expect(await tester.post(handler), Body.empty);
      final captured =
          verify(
            mockFirestoreService.batchWriteDocuments(captureAny, captureAny),
          ).captured;
      expect(captured.length, 2);
      final batchWriteRequest = captured[0] as BatchWriteRequest;
      expect(batchWriteRequest.writes!.length, 1);
      final insertedTaskDocument = batchWriteRequest.writes![0].update!;
      final resultTask = firestore.Task.fromDocument(
        taskDocument: insertedTaskDocument,
      );
      expect(resultTask.status, firestore.Task.statusInProgress);
      expect(resultTask.attempts, 2);
    },
  );

  test('non-bringup target updates check run', () async {
    firestoreTask = generateFirestoreTask(1, name: 'Linux nonbringup');
    ciYamlFetcher.ciYaml = nonBringupPackagesConfig;
    when(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    ).thenAnswer((_) async => true);
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
      repo: 'packages',
      branch: Config.defaultBranch(Config.packagesSlug),
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux nonbringup',
      parent: commit,
    );
    config.db.values[commit.key] = commit;
    config.db.values[task.key] = task;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.SUCCESS,
      builder: 'Linux A',
      userData: PostsubmitUserData(
        checkRunId: 1,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    await tester.post(handler);
    verify(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    ).called(1);
  });

  test('bringup target does not update check run', () async {
    firestoreTask = generateFirestoreTask(1, name: 'Linux bringup');
    ciYamlFetcher.ciYaml = bringupPackagesConfig;
    when(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    ).thenAnswer((_) async => true);
    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux bringup',
      parent: commit,
    );
    config.db.values[commit.key] = commit;
    config.db.values[task.key] = task;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.SUCCESS,
      builder: 'Linux bringup',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    await tester.post(handler);
    verifyNever(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    );
  });

  test('unsupported repo target does not update check run', () async {
    ciYamlFetcher.ciYaml = unsupportedPostsubmitCheckrunConfig;
    when(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    ).thenAnswer((_) async => true);
    firestoreTask = generateFirestoreTask(
      1,
      attempts: 2,
      name: 'Linux flutter',
    );

    final commit = generateCommit(
      1,
      sha: '87f88734747805589f2131753620d61b22922822',
    );
    final task = generateTask(
      4507531199512576,
      name: 'Linux flutter',
      parent: commit,
    );
    config.db.values[commit.key] = commit;
    config.db.values[task.key] = task;

    tester.message = createPushMessage(
      Int64(1),
      status: bbv2.Status.SUCCESS,
      builder: 'Linux bringup',
      userData: PostsubmitUserData(
        checkRunId: null,
        taskKey: '${task.key.id}',
        commitKey: '${task.key.parent?.id}',
        firestoreTaskDocumentName: FirestoreTaskDocumentName(
          commitSha: commit.sha!,
          taskName: task.name!,
          currentAttempt: task.attempts!,
        ),
      ),
    );

    await tester.post(handler);
    verifyNever(
      mockGithubChecksService.updateCheckStatus(
        build: anyNamed('build'),
        checkRunId: anyNamed('checkRunId'),
        luciBuildService: anyNamed('luciBuildService'),
        slug: anyNamed('slug'),
      ),
    );
  });
}
