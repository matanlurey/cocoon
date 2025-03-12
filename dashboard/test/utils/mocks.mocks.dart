// Mocks generated by Mockito 5.4.4 from annotations
// in flutter_dashboard/test/utils/mocks.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:convert' as _i7;
import 'dart:typed_data' as _i9;
import 'dart:ui' as _i15;

import 'package:flutter_dashboard/logic/brooks.dart' as _i5;
import 'package:flutter_dashboard/model/branch.pb.dart' as _i13;
import 'package:flutter_dashboard/model/build_status_response.pb.dart' as _i12;
import 'package:flutter_dashboard/model/commit.pb.dart' as _i17;
import 'package:flutter_dashboard/model/commit_status.pb.dart' as _i10;
import 'package:flutter_dashboard/model/commit_tasks_status.pb.dart' as _i11;
import 'package:flutter_dashboard/model/task.pb.dart' as _i16;
import 'package:flutter_dashboard/service/cocoon.dart' as _i3;
import 'package:flutter_dashboard/service/google_authentication.dart' as _i4;
import 'package:flutter_dashboard/state/build.dart' as _i14;
import 'package:google_sign_in/google_sign_in.dart' as _i18;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as _i19;
import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_1 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCocoonResponse_2<T> extends _i1.SmartFake
    implements _i3.CocoonResponse<T> {
  _FakeCocoonResponse_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCocoonService_3 extends _i1.SmartFake implements _i3.CocoonService {
  _FakeCocoonService_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleSignInService_4 extends _i1.SmartFake
    implements _i4.GoogleSignInService {
  _FakeGoogleSignInService_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBrook_5<T> extends _i1.SmartFake implements _i5.Brook<T> {
  _FakeBrook_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<String>);

  @override
  _i6.Future<_i9.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i9.Uint8List>.value(_i9.Uint8List(0)),
      ) as _i6.Future<_i9.Uint8List>);

  @override
  _i6.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i6.Future<_i2.StreamedResponse>.value(_FakeStreamedResponse_1(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i6.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [CocoonService].
///
/// See the documentation for Mockito's code generation for more information.
class MockCocoonService extends _i1.Mock implements _i3.CocoonService {
  MockCocoonService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i3.CocoonResponse<List<_i10.CommitStatus>>> fetchCommitStatuses({
    _i10.CommitStatus? lastCommitStatus,
    String? branch,
    required String? repo,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchCommitStatuses,
          [],
          {
            #lastCommitStatus: lastCommitStatus,
            #branch: branch,
            #repo: repo,
          },
        ),
        returnValue:
            _i6.Future<_i3.CocoonResponse<List<_i10.CommitStatus>>>.value(
                _FakeCocoonResponse_2<List<_i10.CommitStatus>>(
          this,
          Invocation.method(
            #fetchCommitStatuses,
            [],
            {
              #lastCommitStatus: lastCommitStatus,
              #branch: branch,
              #repo: repo,
            },
          ),
        )),
      ) as _i6.Future<_i3.CocoonResponse<List<_i10.CommitStatus>>>);

  @override
  _i6.Future<_i3.CocoonResponse<List<_i11.CommitTasksStatus>>>
      fetchCommitStatusesFirestore({
    _i10.CommitStatus? lastCommitStatus,
    String? branch,
    required String? repo,
  }) =>
          (super.noSuchMethod(
            Invocation.method(
              #fetchCommitStatusesFirestore,
              [],
              {
                #lastCommitStatus: lastCommitStatus,
                #branch: branch,
                #repo: repo,
              },
            ),
            returnValue: _i6
                .Future<_i3.CocoonResponse<List<_i11.CommitTasksStatus>>>.value(
                _FakeCocoonResponse_2<List<_i11.CommitTasksStatus>>(
              this,
              Invocation.method(
                #fetchCommitStatusesFirestore,
                [],
                {
                  #lastCommitStatus: lastCommitStatus,
                  #branch: branch,
                  #repo: repo,
                },
              ),
            )),
          ) as _i6.Future<_i3.CocoonResponse<List<_i11.CommitTasksStatus>>>);

  @override
  _i6.Future<_i3.CocoonResponse<_i12.BuildStatusResponse>>
      fetchTreeBuildStatus({
    String? branch,
    required String? repo,
  }) =>
          (super.noSuchMethod(
            Invocation.method(
              #fetchTreeBuildStatus,
              [],
              {
                #branch: branch,
                #repo: repo,
              },
            ),
            returnValue:
                _i6.Future<_i3.CocoonResponse<_i12.BuildStatusResponse>>.value(
                    _FakeCocoonResponse_2<_i12.BuildStatusResponse>(
              this,
              Invocation.method(
                #fetchTreeBuildStatus,
                [],
                {
                  #branch: branch,
                  #repo: repo,
                },
              ),
            )),
          ) as _i6.Future<_i3.CocoonResponse<_i12.BuildStatusResponse>>);

  @override
  _i6.Future<_i3.CocoonResponse<List<_i13.Branch>>> fetchFlutterBranches() =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchFlutterBranches,
          [],
        ),
        returnValue: _i6.Future<_i3.CocoonResponse<List<_i13.Branch>>>.value(
            _FakeCocoonResponse_2<List<_i13.Branch>>(
          this,
          Invocation.method(
            #fetchFlutterBranches,
            [],
          ),
        )),
      ) as _i6.Future<_i3.CocoonResponse<List<_i13.Branch>>>);

  @override
  _i6.Future<_i3.CocoonResponse<List<String>>> fetchRepos() =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchRepos,
          [],
        ),
        returnValue: _i6.Future<_i3.CocoonResponse<List<String>>>.value(
            _FakeCocoonResponse_2<List<String>>(
          this,
          Invocation.method(
            #fetchRepos,
            [],
          ),
        )),
      ) as _i6.Future<_i3.CocoonResponse<List<String>>>);

  @override
  _i6.Future<_i3.CocoonResponse<bool>> rerunTask({
    required String? idToken,
    required String? taskName,
    required String? commitSha,
    required String? repo,
    required String? branch,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #rerunTask,
          [],
          {
            #idToken: idToken,
            #taskName: taskName,
            #commitSha: commitSha,
            #repo: repo,
            #branch: branch,
          },
        ),
        returnValue: _i6.Future<_i3.CocoonResponse<bool>>.value(
            _FakeCocoonResponse_2<bool>(
          this,
          Invocation.method(
            #rerunTask,
            [],
            {
              #idToken: idToken,
              #taskName: taskName,
              #commitSha: commitSha,
              #repo: repo,
              #branch: branch,
            },
          ),
        )),
      ) as _i6.Future<_i3.CocoonResponse<bool>>);

  @override
  _i6.Future<_i3.CocoonResponse<void>> rerunCommit({
    required String? idToken,
    required String? commitSha,
    required String? repo,
    required String? branch,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #rerunCommit,
          [],
          {
            #idToken: idToken,
            #commitSha: commitSha,
            #repo: repo,
            #branch: branch,
          },
        ),
        returnValue: _i6.Future<_i3.CocoonResponse<void>>.value(
            _FakeCocoonResponse_2<void>(
          this,
          Invocation.method(
            #rerunCommit,
            [],
            {
              #idToken: idToken,
              #commitSha: commitSha,
              #repo: repo,
              #branch: branch,
            },
          ),
        )),
      ) as _i6.Future<_i3.CocoonResponse<void>>);

  @override
  _i6.Future<bool> vacuumGitHubCommits(String? idToken) => (super.noSuchMethod(
        Invocation.method(
          #vacuumGitHubCommits,
          [idToken],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);
}

/// A class which mocks [BuildState].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildState extends _i1.Mock implements _i14.BuildState {
  MockBuildState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CocoonService get cocoonService => (super.noSuchMethod(
        Invocation.getter(#cocoonService),
        returnValue: _FakeCocoonService_3(
          this,
          Invocation.getter(#cocoonService),
        ),
      ) as _i3.CocoonService);

  @override
  _i4.GoogleSignInService get authService => (super.noSuchMethod(
        Invocation.getter(#authService),
        returnValue: _FakeGoogleSignInService_4(
          this,
          Invocation.getter(#authService),
        ),
      ) as _i4.GoogleSignInService);

  @override
  set authService(_i4.GoogleSignInService? _authService) => super.noSuchMethod(
        Invocation.setter(
          #authService,
          _authService,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set refreshTimer(_i6.Timer? _refreshTimer) => super.noSuchMethod(
        Invocation.setter(
          #refreshTimer,
          _refreshTimer,
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i13.Branch> get branches => (super.noSuchMethod(
        Invocation.getter(#branches),
        returnValue: <_i13.Branch>[],
      ) as List<_i13.Branch>);

  @override
  String get currentBranch => (super.noSuchMethod(
        Invocation.getter(#currentBranch),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.getter(#currentBranch),
        ),
      ) as String);

  @override
  String get currentRepo => (super.noSuchMethod(
        Invocation.getter(#currentRepo),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.getter(#currentRepo),
        ),
      ) as String);

  @override
  List<String> get repos => (super.noSuchMethod(
        Invocation.getter(#repos),
        returnValue: <String>[],
      ) as List<String>);

  @override
  List<_i10.CommitStatus> get statuses => (super.noSuchMethod(
        Invocation.getter(#statuses),
        returnValue: <_i10.CommitStatus>[],
      ) as List<_i10.CommitStatus>);

  @override
  List<String> get failingTasks => (super.noSuchMethod(
        Invocation.getter(#failingTasks),
        returnValue: <String>[],
      ) as List<String>);

  @override
  bool get moreStatusesExist => (super.noSuchMethod(
        Invocation.getter(#moreStatusesExist),
        returnValue: false,
      ) as bool);

  @override
  _i5.Brook<String> get errors => (super.noSuchMethod(
        Invocation.getter(#errors),
        returnValue: _FakeBrook_5<String>(
          this,
          Invocation.getter(#errors),
        ),
      ) as _i5.Brook<String>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void addListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void updateCurrentRepoBranch(
    String? repo,
    String? branch,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #updateCurrentRepoBranch,
          [
            repo,
            branch,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Future<void>? fetchMoreCommitStatuses() => (super.noSuchMethod(
        Invocation.method(
          #fetchMoreCommitStatuses,
          [],
        ),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>?);

  @override
  _i6.Future<bool> refreshGitHubCommits() => (super.noSuchMethod(
        Invocation.method(
          #refreshGitHubCommits,
          [],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<bool> rerunTask(
    _i16.Task? task,
    _i17.Commit? commit,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #rerunTask,
          [
            task,
            commit,
          ],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [GoogleSignIn].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignIn extends _i1.Mock implements _i18.GoogleSignIn {
  MockGoogleSignIn() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i19.SignInOption get signInOption => (super.noSuchMethod(
        Invocation.getter(#signInOption),
        returnValue: _i19.SignInOption.standard,
      ) as _i19.SignInOption);

  @override
  List<String> get scopes => (super.noSuchMethod(
        Invocation.getter(#scopes),
        returnValue: <String>[],
      ) as List<String>);

  @override
  bool get forceCodeForRefreshToken => (super.noSuchMethod(
        Invocation.getter(#forceCodeForRefreshToken),
        returnValue: false,
      ) as bool);

  @override
  _i6.Stream<_i18.GoogleSignInAccount?> get onCurrentUserChanged =>
      (super.noSuchMethod(
        Invocation.getter(#onCurrentUserChanged),
        returnValue: _i6.Stream<_i18.GoogleSignInAccount?>.empty(),
      ) as _i6.Stream<_i18.GoogleSignInAccount?>);

  @override
  _i6.Future<_i18.GoogleSignInAccount?> signInSilently({
    bool? suppressErrors = true,
    bool? reAuthenticate = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInSilently,
          [],
          {
            #suppressErrors: suppressErrors,
            #reAuthenticate: reAuthenticate,
          },
        ),
        returnValue: _i6.Future<_i18.GoogleSignInAccount?>.value(),
      ) as _i6.Future<_i18.GoogleSignInAccount?>);

  @override
  _i6.Future<bool> isSignedIn() => (super.noSuchMethod(
        Invocation.method(
          #isSignedIn,
          [],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<_i18.GoogleSignInAccount?> signIn() => (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
        ),
        returnValue: _i6.Future<_i18.GoogleSignInAccount?>.value(),
      ) as _i6.Future<_i18.GoogleSignInAccount?>);

  @override
  _i6.Future<_i18.GoogleSignInAccount?> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i6.Future<_i18.GoogleSignInAccount?>.value(),
      ) as _i6.Future<_i18.GoogleSignInAccount?>);

  @override
  _i6.Future<_i18.GoogleSignInAccount?> disconnect() => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
        ),
        returnValue: _i6.Future<_i18.GoogleSignInAccount?>.value(),
      ) as _i6.Future<_i18.GoogleSignInAccount?>);

  @override
  _i6.Future<bool> requestScopes(List<String>? scopes) => (super.noSuchMethod(
        Invocation.method(
          #requestScopes,
          [scopes],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<bool> canAccessScopes(
    List<String>? scopes, {
    String? accessToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #canAccessScopes,
          [scopes],
          {#accessToken: accessToken},
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);
}

/// A class which mocks [GoogleSignInService].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignInService extends _i1.Mock
    implements _i4.GoogleSignInService {
  MockGoogleSignInService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set user(_i18.GoogleSignInAccount? _user) => super.noSuchMethod(
        Invocation.setter(
          #user,
          _user,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isAuthenticated => (super.noSuchMethod(
        Invocation.getter(#isAuthenticated),
        returnValue: false,
      ) as bool);

  @override
  _i6.Future<String> get idToken => (super.noSuchMethod(
        Invocation.getter(#idToken),
        returnValue: _i6.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.getter(#idToken),
        )),
      ) as _i6.Future<String>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i6.Future<void> signIn() => (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> clearUser() => (super.noSuchMethod(
        Invocation.method(
          #clearUser,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void addListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
