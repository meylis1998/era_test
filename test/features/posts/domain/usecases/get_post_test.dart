import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:era_test/features/posts/domain/entities/post.dart';
import 'package:era_test/features/posts/domain/repositories/posts_repository.dart';
import 'package:era_test/features/posts/domain/usecases/get_post.dart';
import 'package:era_test/core/errors/failures.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late GetPost usecase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    usecase = GetPost(mockPostsRepository);
  });

  const tId = 1;
  const tPost = Post(
    userId: 1,
    id: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  group('GetPost UseCase', () {
    test('should get post from the repository', () async {
      // Arrange
      when(() => mockPostsRepository.getPost(any()))
          .thenAnswer((_) async => const Right(tPost));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, const Right(tPost));
      verify(() => mockPostsRepository.getPost(tId));
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return server failure when repository fails', () async {
      // Arrange
      when(() => mockPostsRepository.getPost(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, Left(ServerFailure()));
      verify(() => mockPostsRepository.getPost(tId));
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return network failure when repository fails with network error', () async {
      // Arrange
      when(() => mockPostsRepository.getPost(any()))
          .thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockPostsRepository.getPost(tId));
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return cache failure when repository fails with cache error', () async {
      // Arrange
      when(() => mockPostsRepository.getPost(any()))
          .thenAnswer((_) async => Left(CacheFailure()));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, Left(CacheFailure()));
      verify(() => mockPostsRepository.getPost(tId));
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should pass the correct id to the repository', () async {
      // Arrange
      const testId = 42;
      when(() => mockPostsRepository.getPost(any()))
          .thenAnswer((_) async => const Right(tPost));

      // Act
      await usecase(testId);

      // Assert
      verify(() => mockPostsRepository.getPost(testId));
    });
  });
}