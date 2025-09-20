import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:era_test/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:era_test/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:era_test/features/posts/data/models/post_model.dart';
import 'package:era_test/core/network/network_info.dart';
import 'package:era_test/core/errors/exceptions.dart';
import 'package:era_test/core/errors/failures.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late PostsRepositoryImpl repository;
  late MockPostsRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockPostsRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PostsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tPostModel = PostModel(
    userId: 1,
    id: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  const tPostsList = [tPostModel];

  group('PostsRepositoryImpl', () {
    group('getPosts', () {
      test('should check if the device is online', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getPosts())
            .thenAnswer((_) async => tPostsList);

        // Act
        repository.getPosts();

        // Assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return remote data when the call to remote data source is successful', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPosts())
              .thenAnswer((_) async => tPostsList);

          // Act
          final result = await repository.getPosts();

          // Assert
          verify(() => mockRemoteDataSource.getPosts());
          expect(result, equals(const Right(tPostsList)));
        });

        test('should return server failure when the call to remote data source throws ServerException', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPosts()).thenThrow(ServerException());

          // Act
          final result = await repository.getPosts();

          // Assert
          verify(() => mockRemoteDataSource.getPosts());
          expect(result, equals(Left(ServerFailure())));
        });

        test('should return network failure when the call to remote data source throws NetworkException', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPosts()).thenThrow(NetworkException());

          // Act
          final result = await repository.getPosts();

          // Assert
          verify(() => mockRemoteDataSource.getPosts());
          expect(result, equals(Left(NetworkFailure())));
        });

        test('should return server failure when the call to remote data source throws unexpected exception', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPosts()).thenThrow(Exception());

          // Act
          final result = await repository.getPosts();

          // Assert
          verify(() => mockRemoteDataSource.getPosts());
          expect(result, equals(Left(ServerFailure())));
        });
      });

      group('device is offline', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        test('should return network failure when the device is offline', () async {
          // Act
          final result = await repository.getPosts();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(NetworkFailure())));
        });
      });
    });

    group('getPost', () {
      const tId = 1;

      test('should check if the device is online', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getPost(any()))
            .thenAnswer((_) async => tPostModel);

        // Act
        repository.getPost(tId);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return remote data when the call to remote data source is successful', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPost(any()))
              .thenAnswer((_) async => tPostModel);

          // Act
          final result = await repository.getPost(tId);

          // Assert
          verify(() => mockRemoteDataSource.getPost(tId));
          expect(result, equals(const Right(tPostModel)));
        });

        test('should return server failure when the call to remote data source throws ServerException', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPost(any())).thenThrow(ServerException());

          // Act
          final result = await repository.getPost(tId);

          // Assert
          verify(() => mockRemoteDataSource.getPost(tId));
          expect(result, equals(Left(ServerFailure())));
        });

        test('should return network failure when the call to remote data source throws NetworkException', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPost(any())).thenThrow(NetworkException());

          // Act
          final result = await repository.getPost(tId);

          // Assert
          verify(() => mockRemoteDataSource.getPost(tId));
          expect(result, equals(Left(NetworkFailure())));
        });

        test('should return server failure when the call to remote data source throws unexpected exception', () async {
          // Arrange
          when(() => mockRemoteDataSource.getPost(any())).thenThrow(Exception());

          // Act
          final result = await repository.getPost(tId);

          // Assert
          verify(() => mockRemoteDataSource.getPost(tId));
          expect(result, equals(Left(ServerFailure())));
        });

        test('should pass the correct id to the data source', () async {
          // Arrange
          const testId = 42;
          when(() => mockRemoteDataSource.getPost(any()))
              .thenAnswer((_) async => tPostModel);

          // Act
          await repository.getPost(testId);

          // Assert
          verify(() => mockRemoteDataSource.getPost(testId));
        });
      });

      group('device is offline', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        test('should return network failure when the device is offline', () async {
          // Act
          final result = await repository.getPost(tId);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(NetworkFailure())));
        });
      });
    });
  });
}