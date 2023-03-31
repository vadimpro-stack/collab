import "package:api/model/user.dart";

import 'package:conduit/conduit.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id;
  // @Column(unique: true, indexed: true)
  // String? userName;
  // @Column(unique: true, indexed: true)
  // String? email;
  // @Serialize(input: true, output: false)
  // String? password;
  String? theme;
  String? content;

  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
}
