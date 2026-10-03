import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/mappers.dart';
import 'package:storryca/src/core/network/models/author_api_model.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';

class AuthorsRepository {
  AuthorsRepository(this._client);

  final ApiClient _client;

  Future<Paged<AuthorTypes>> list({
    String? q,
    String sort = 'popular',
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.get(
      '/authors',
      query: {'q': q, 'sort': sort, 'page': page, 'limit': limit},
    ) as Map<String, dynamic>;

    final items = (data['items'] as List? ?? [])
        .map((e) => authorFromApi(AuthorApiModel.fromJson(e)))
        .toList();
    final pagination = data['pagination'] != null
        ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>)
        : Pagination.empty();
    return Paged(items, pagination);
  }

  Future<AuthorApiModel> byId(int id) async {
    final data = await _client.get('/authors/$id') as Map<String, dynamic>;
    return AuthorApiModel.fromJson(data);
  }

  Future<Paged<StoryItemTypes>> storiesByAuthor(
    int id, {
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _client.get(
      '/authors/$id/stories',
      query: {'page': page, 'limit': limit},
    ) as Map<String, dynamic>;

    final items = (data['items'] as List? ?? [])
        .map((e) => storyItemFromApi(StoryApiModel.fromJson(e)))
        .toList();
    final pagination = data['pagination'] != null
        ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>)
        : Pagination.empty();
    return Paged(items, pagination);
  }
}
