import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:era_test/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:era_test/features/posts/data/models/post_model.dart';
import 'package:era_test/core/errors/exceptions.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late PostsRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = PostsRemoteDataSourceImpl(dio: mockDio);
  });

  group('PostsRemoteDataSource', () {
    group('getPosts', () {
      final tPostsList = [
        const PostModel(userId: 1, id: 1, title: 'Test Title 1', body: 'Test Body 1'),
        const PostModel(userId: 1, id: 2, title: 'Test Title 2', body: 'Test Body 2'),
      ];

      test('should perform a GET request on /posts endpoint', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: [
              {'userId': 1, 'id': 1, 'title': 'Test Title 1', 'body': 'Test Body 1'},
              {'userId': 1, 'id': 2, 'title': 'Test Title 2', 'body': 'Test Body 2'},
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        await dataSource.getPosts();

        // Assert
        verify(() => mockDio.get('https://jsonplaceholder.typicode.com/posts'));
      });

      test('should return List of PostModel when the response code is 200 (success)', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: [
              {'userId': 1, 'id': 1, 'title': 'Test Title 1', 'body': 'Test Body 1'},
              {'userId': 1, 'id': 2, 'title': 'Test Title 2', 'body': 'Test Body 2'},
            ],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.getPosts();

        // Assert
        expect(result, equals(tPostsList));
      });

      test('should throw a ServerException when the response code is not 200', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = dataSource.getPosts;

        // Assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });

      test('should throw a NetworkException when DioException with connection timeout occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = dataSource.getPosts;

        // Assert
        expect(() => call(), throwsA(isA<NetworkException>()));
      });

      test('should throw a NetworkException when DioException with receive timeout occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = dataSource.getPosts;

        // Assert
        expect(() => call(), throwsA(isA<NetworkException>()));
      });

      test('should throw a ServerException when DioException with 500 status code occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = dataSource.getPosts;

        // Assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });

      test('should throw a ServerException when any other exception occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception());

        // Act
        final call = dataSource.getPosts;

        // Assert
        expect(() => call(), throwsA(isA<ServerException>()));
      });
    });

    group('getPost', () {
      const tId = 1;
      const tPostModel = PostModel(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      test('should perform a GET request on /posts/id endpoint', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {'userId': 1, 'id': 1, 'title': 'Test Title', 'body': 'Test Body'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        await dataSource.getPost(tId);

        // Assert
        verify(() => mockDio.get('https://jsonplaceholder.typicode.com/posts/$tId'));
      });

      test('should return PostModel when the response code is 200 (success)', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {'userId': 1, 'id': 1, 'title': 'Test Title', 'body': 'Test Body'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.getPost(tId);

        // Assert
        expect(result, equals(tPostModel));
      });

      test('should throw a ServerException when the response code is not 200', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Something went wrong',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = () => dataSource.getPost(tId);

        // Assert
        expect(call, throwsA(isA<ServerException>()));
      });

      test('should pass the correct id in the URL', () async {
        // Arrange
        const testId = 42;
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {'userId': 1, 'id': testId, 'title': 'Test Title', 'body': 'Test Body'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        await dataSource.getPost(testId);

        // Assert
        verify(() => mockDio.get('https://jsonplaceholder.typicode.com/posts/$testId'));
      });

      test('should throw a NetworkException when DioException with connection timeout occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = () => dataSource.getPost(tId);

        // Assert
        expect(call, throwsA(isA<NetworkException>()));
      });

      test('should throw a ServerException when DioException with 500 status code occurs', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final call = () => dataSource.getPost(tId);

        // Assert
        expect(call, throwsA(isA<ServerException>()));
      });
    });
  });
}