import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';
import 'posts_mock_data_source.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPost(int id);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  const PostsRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      if (kDebugMode && e.response?.statusCode == 403) {
        await Future.delayed(const Duration(milliseconds: 500));
        return PostsMockDataSource.getMockPosts();
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException();
      } else if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 500) {
        throw ServerException();
      } else {
        throw NetworkException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PostModel> getPost(int id) async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts/$id',
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      if (kDebugMode && e.response?.statusCode == 403) {
        await Future.delayed(const Duration(milliseconds: 500));
        final mockPosts = PostsMockDataSource.getMockPosts();
        final mockPost = mockPosts.firstWhere(
          (post) => post.id == id,
          orElse: () => mockPosts.first,
        );
        return mockPost;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException();
      } else if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 500) {
        throw ServerException();
      } else {
        throw NetworkException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
