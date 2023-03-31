import 'dart:io';

import 'package:api/api.dart';
import 'package:conduit/conduit.dart';

void main(List<String> arguments) async {
  final port = int.parse(Platform.environment["PORT"] ?? '8888');

  final service = Application<AppService>()..options.port = port;
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
