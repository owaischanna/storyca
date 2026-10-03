import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/core/network/models/pagination.dart';

class FollowRepository {
  FollowRepository(this._client);

  final ApiClient _client;

  Future<FollowStateApiModel> state(int userId, {String? token}) async {
    final data =
        await _client.get(
              '/follow/state',
              query: {'user_id': userId},
              token: token,
            )
            as Map<String, dynamic>;
    return FollowStateApiModel.fromJson(data);
  }

  Future<Paged<FollowUserApiModel>> followers(
    int userId, {
    int page = 1,
    int limit = 24,
    String? token,
  }) => _list('/follow/followers', userId, page: page, limit: limit, token: token);

  Future<Paged<FollowUserApiModel>> following(
    int userId, {
    int page = 1,
    int limit = 24,
    String? token,
  }) => _list('/follow/following', userId, page: page, limit: limit, token: token);

  Future<Paged<FollowUserApiModel>> _list(
    String path,
    int userId, {
    required int page,
    required int limit,
    String? token,
  }) async {
    final data =
        await _client.get(
              path,
              query: {'user_id': userId, 'page': page, 'limit': limit},
              token: token,
            )
            as Map<String, dynamic>;

    final items = (data['items'] as List? ?? [])
        .map((e) => FollowUserApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] != null
        ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>)
        : Pagination.empty();
    return Paged(items, pagination);
  }

  Future<FollowStateApiModel> follow(int userId, String token) async {
    final data =
        await _client.post(
              '/follow',
              body: {'user_id': userId},
              token: token,
            )
            as Map<String, dynamic>;
    return FollowStateApiModel.fromJson(data);
  }

  Future<FollowStateApiModel> unfollow(int userId, String token) async {
    final data =
        await _client.delete(
              '/follow',
              query: {'user_id': userId},
              token: token,
            )
            as Map<String, dynamic>;
    return FollowStateApiModel.fromJson(data);
  }
}
