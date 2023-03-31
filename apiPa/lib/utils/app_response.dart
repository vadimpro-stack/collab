import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import '../model/model_response.dart';

class AppResponse extends Response {

  AppResponse.ok({dynamic body, String? message})
      : super.ok(ModelResponse(data: body, message: message));

  AppResponse.badrequest({dynamic body, String? message})
      : super.badRequest(body: ModelResponse(message: message ?? 'Ошибка запроса'));

  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static ModelResponse _getResponseModel(error, String? messgae) {
    if (error is QueryException) {
      return ModelResponse(
          error: error.toString(), message: messgae ?? error.message);
    }
    if (error is JwtException) {
      return ModelResponse(
          error: error.toString(), message: messgae ?? error.message);
    }
    return ModelResponse(
        error: error.toString(), message: messgae ?? "Неизвестная ошибка");
  }

  
}
