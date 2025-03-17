// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cocoon_service/cocoon_service.dart';
import 'package:cocoon_service/src/model/appengine/commit.dart';
import 'package:cocoon_service/src/model/appengine/task.dart';
import 'package:cocoon_service/src/model/firestore/task.dart' as firestore;
import 'package:cocoon_service/src/request_handling/exceptions.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../src/datastore/fake_config.dart';
import '../src/datastore/fake_datastore.dart';
import '../src/request_handling/api_request_handler_tester.dart';
import '../src/request_handling/fake_authentication.dart';
import '../src/service/fake_ci_yaml_fetcher.dart';
import '../src/service/fake_scheduler.dart';
import '../src/utilities/entity_generators.dart';
import '../src/utilities/mocks.dart';

void main() {
  FakeClientContext clientContext;
  late RerunProdTask handler;
  late FakeConfig config;
  FakeKeyHelper keyHelper;
  late MockLuciBuildService mockLuciBuildService;
  late MockFirestoreService mockFirestoreService;
  late ApiRequestHandlerTester tester;
  late Commit commit;
  late Task task;
  late FakeCiYamlFetcher ciYamlFetcher;

  final firestoreTask = generateFirestoreTask(1, attempts: 1);

  setUp(() {
    final datastoreDB = FakeDatastoreDB();
    clientContext = FakeClientContext();
    mockFirestoreService = MockFirestoreService();
    clientContext.isDevelopmentEnvironment = false;
    keyHelper = FakeKeyHelper(
      applicationContext: clientContext.applicationContext,
    );
    config = FakeConfig(
      dbValue: datastoreDB,
      keyHelperValue: keyHelper,
      supportedBranchesValue: <String>[
        Config.defaultBranch(Config.flutterSlug),
      ],
      firestoreService: mockFirestoreService,
    );
    final authContext = FakeAuthenticatedContext(clientContext: clientContext);
    tester = ApiRequestHandlerTester(context: authContext);
    mockLuciBuildService = MockLuciBuildService();
    ciYamlFetcher = FakeCiYamlFetcher(ciYaml: exampleConfig);
    handler = RerunProdTask(
      config: config,
      authenticationProvider: FakeAuthenticationProvider(
        clientContext: clientContext,
      ),
      luciBuildService: mockLuciBuildService,
      scheduler: FakeScheduler(config: config),
      ciYamlFetcher: ciYamlFetcher,
    );
    commit = generateCommit(1);
    task = generateTask(
      1,
      name: 'Linux A',
      parent: commit,
      status: Task.statusFailed,
    );
    tester.requestData = {
      'branch': commit.branch,
      'repo': commit.slug.name,
      'commit': commit.sha,
      'task': task.name,
    };

    when(mockFirestoreService.getDocument(captureAny)).thenAnswer((
      Invocation invocation,
    ) {
      return Future<Document>.value(firestoreTask);
    });

    when(
      mockLuciBuildService.checkRerunBuilder(
        commit: anyNamed('commit'),
        datastore: anyNamed('datastore'),
        task: anyNamed('task'),
        target: anyNamed('target'),
        tags: anyNamed('tags'),
        ignoreChecks: anyNamed('ignoreChecks'),
        firestoreService: mockFirestoreService,
        taskDocument: anyNamed('taskDocument'),
      ),
    ).thenAnswer((_) async => true);
  });
  test('Schedule new task', () async {
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;
    expect(await tester.post(handler), Body.empty);

    final captured =
        verify(mockFirestoreService.getDocument(captureAny)).captured;
    expect(captured.length, 1);
    final documentName = captured[0] as String;
    expect(
      documentName,
      '$kDatabase/documents/${firestore.kTaskCollectionId}/${commit.sha}_${task.name}_${task.attempts}',
    );
  });

  test('Re-schedule passing all the parameters', () async {
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;
    expect(await tester.post(handler), Body.empty);
    verify(
      mockLuciBuildService.checkRerunBuilder(
        commit: anyNamed('commit'),
        datastore: anyNamed('datastore'),
        task: anyNamed('task'),
        target: anyNamed('target'),
        tags: anyNamed('tags'),
        ignoreChecks: true,
        firestoreService: mockFirestoreService,
        taskDocument: anyNamed('taskDocument'),
      ),
    ).called(1);
  });

  test('Rerun all failed tasks when task name is all', () async {
    final taskA = generateTask(
      2,
      name: 'Linux A',
      parent: commit,
      status: Task.statusFailed,
    );
    final taskB = generateTask(
      3,
      name: 'Mac A',
      parent: commit,
      status: Task.statusFailed,
    );
    config.db.values[taskA.key] = taskA;
    config.db.values[taskB.key] = taskB;
    config.db.values[commit.key] = commit;
    tester.requestData = {...tester.requestData, 'task': 'all'};
    expect(await tester.post(handler), Body.empty);
    verify(
      mockLuciBuildService.checkRerunBuilder(
        commit: anyNamed('commit'),
        datastore: anyNamed('datastore'),
        task: anyNamed('task'),
        target: anyNamed('target'),
        tags: anyNamed('tags'),
        ignoreChecks: false,
        firestoreService: mockFirestoreService,
        taskDocument: anyNamed('taskDocument'),
      ),
    ).called(2);
  });

  test('Rerun all runs nothing when everything is passed', () async {
    final task = generateTask(
      2,
      name: 'Windows A',
      parent: commit,
      status: Task.statusSucceeded,
    );
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;
    tester.requestData = {...tester.requestData, 'task': 'all'};
    expect(await tester.post(handler), Body.empty);
    verifyNever(
      mockLuciBuildService.checkRerunBuilder(
        commit: anyNamed('commit'),
        datastore: anyNamed('datastore'),
        task: anyNamed('task'),
        target: anyNamed('target'),
        tags: anyNamed('tags'),
        firestoreService: anyNamed('firestoreService'),
        taskDocument: anyNamed('taskDocument'),
        ignoreChecks: false,
      ),
    );
  });

  test('Re-schedule without any parameters raises exception', () async {
    tester.requestData = <String, dynamic>{};
    expect(() => tester.post(handler), throwsA(isA<BadRequestException>()));
  });

  test(
    'Re-schedule existing task even though taskName is missing in the task',
    () async {
      config.db.values[task.key] = task;
      config.db.values[commit.key] = commit;
      expect(await tester.post(handler), Body.empty);
    },
  );

  test('Fails if task is not rerun', () async {
    when(
      mockLuciBuildService.checkRerunBuilder(
        commit: anyNamed('commit'),
        datastore: anyNamed('datastore'),
        task: anyNamed('task'),
        target: anyNamed('target'),
        tags: anyNamed('tags'),
        ignoreChecks: true,
        firestoreService: mockFirestoreService,
        taskDocument: anyNamed('taskDocument'),
      ),
    ).thenAnswer((_) async => false);
    config.db.values[task.key] = task;
    config.db.values[commit.key] = commit;
    expect(() => tester.post(handler), throwsA(isA<InternalServerError>()));
  });

  test('Fails if commit does not exist', () async {
    config.db.values[task.key] = task;
    expect(() => tester.post(handler), throwsA(isA<StateError>()));
  });
}
