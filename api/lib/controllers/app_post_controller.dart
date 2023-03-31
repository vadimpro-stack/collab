import 'dart:io';

import 'package:api/model/model_response.dart';
import 'package:api/utils/app_response.dart';
import 'package:api/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../model/post.dart';
import '../model/user.dart';

class AppPostController extends ResourceController {
  AppPostController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Post post) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final user = await managedContext.fetchObjectWithID<User>(id);

      if (user == null) {
        final qCreateAuthor = Query<User>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      final qCreatePost = Query<Post>(managedContext)
        ..values.user!.id = id
        ..values.theme = post.theme
        ..values.content = post.content;

      await qCreatePost.insert();

      return AppResponse.ok(message: 'Успешное создание поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания поста');
    }
  }

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qCreatePost = Query<Post>(managedContext)
        ..where((x) => x.user!.id).equalTo(id);

      final List<Post> list = await qCreatePost.fetch();

      if (list.isEmpty)
        return Response.notFound(
            body: ModelResponse(data: [], message: "Нет ни одного поста"));
      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.get("id")
  Future<Response> getPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.user?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      post.backing.removeProperty("author");
      return AppResponse.ok(
          body: post.backing.contents, message: "Успешное создание поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания поста");
    }
  }

  @Operation.put('id')
  Future<Response> updatePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPost) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.user?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qUpdatePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.theme = bodyPost.theme
        ..values.content = bodyPost.content;

      await qUpdatePost.update();

      return AppResponse.ok(message: 'Пост успешно обновлен');
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.user?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qDeletePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeletePost.delete();
      return AppResponse.ok(message: "Успешное удаление поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления поста");
    }
  }
}
