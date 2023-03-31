import 'dart:io';
import 'package:api/controllers/app_post_controller.dart';
import 'package:api/controllers/app_token_controller.dart';
import 'package:api/controllers/app_user_controller.dart';
import 'package:conduit/conduit.dart';
import 'model/user.dart';
import 'model/post.dart';

import 'controllers/app_auth_controller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext))
    ..route('post/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppPostController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '111';
    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'postgres';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
