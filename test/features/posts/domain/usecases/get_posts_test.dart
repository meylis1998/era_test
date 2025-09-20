import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:era_test/features/posts/domain/entities/post.dart';
import 'package:era_test/features/posts/domain/repositories/posts_repository.dart';
import 'package:era_test/features/posts/domain/usecases/get_posts.dart';
import 'package:era_test/core/errors/failures.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late GetPosts usecase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    usecase = GetPosts(mockPostsRepository);
  });

  const tPost = Post(
    userId: 1,
    id: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  const tPostsList = [tPost];

  group('GetPosts UseCase', () {
    test('should get posts from the repository', () async {
      // Arrange
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => const Right(tPostsList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tPostsList));
      verify(() => mockPostsRepository.getPosts());
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return server failure when repository fails', () async {
      // Arrange
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(ServerFailure()));
      verify(() => mockPostsRepository.getPosts());
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return network failure when repository fails with network error', () async {
      // Arrange
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockPostsRepository.getPosts());
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return cache failure when repository fails with cache error', () async {
      // Arrange
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => Left(CacheFailure()));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(CacheFailure()));
      verify(() => mockPostsRepository.getPosts());
      verifyNoMoreInteractions(mockPostsRepository);
    });

    test('should return empty list when repository returns empty list', () async {
      // Arrange
      const List<Post> emptyList = [];
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => const Right(emptyList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(emptyList));
      verify(() => mockPostsRepository.getPosts());
      verifyNoMoreInteractions(mockPostsRepository);
    });
  });
}