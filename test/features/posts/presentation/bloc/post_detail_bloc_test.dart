import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:era_test/features/posts/domain/entities/post.dart';
import 'package:era_test/features/posts/domain/usecases/get_post.dart';
import 'package:era_test/features/posts/presentation/bloc/post_detail_bloc.dart';
import 'package:era_test/core/errors/failures.dart';

class MockGetPost extends Mock implements GetPost {}

void main() {
  late PostDetailBloc bloc;
  late MockGetPost mockGetPost;

  setUp(() {
    mockGetPost = MockGetPost();
    bloc = PostDetailBloc(getPost: mockGetPost);
  });

  const tId = 1;
  const tPost = Post(
    userId: 1,
    id: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  group('PostDetailBloc', () {
    test('initial state should be PostDetailInitial', () {
      expect(bloc.state, equals(PostDetailInitial()));
    });

    group('GetPostDetailEvent', () {
      blocTest<PostDetailBloc, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailLoaded] when data is gotten successfully',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => const Right(tPost));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: tId)),
        expect: () => [
          PostDetailLoading(),
          const PostDetailLoaded(post: tPost),
        ],
        verify: (_) {
          verify(() => mockGetPost(tId));
        },
      );

      blocTest<PostDetailBloc, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailError] when getting data fails with ServerFailure',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: tId)),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(message: 'Server is temporarily unavailable.\\nPlease try again later.'),
        ],
        verify: (_) {
          verify(() => mockGetPost(tId));
        },
      );

      blocTest<PostDetailBloc, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailError] when getting data fails with NetworkFailure',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => Left(NetworkFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: tId)),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(message: 'No internet connection.\\nCheck your network and try again.'),
        ],
        verify: (_) {
          verify(() => mockGetPost(tId));
        },
      );

      blocTest<PostDetailBloc, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailError] when getting data fails with CacheFailure',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: tId)),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(message: 'Local storage error.\\nPlease try again.'),
        ],
        verify: (_) {
          verify(() => mockGetPost(tId));
        },
      );

      blocTest<PostDetailBloc, PostDetailState>(
        'should pass the correct id to the use case',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => const Right(tPost));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: 42)),
        verify: (_) {
          verify(() => mockGetPost(42));
        },
      );

      blocTest<PostDetailBloc, PostDetailState>(
        'should emit error with generic message for unknown failure',
        build: () {
          when(() => mockGetPost(any())).thenAnswer((_) async => Left(TestFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetPostDetailEvent(id: tId)),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(message: 'Something went wrong.\\nPlease try again.'),
        ],
      );
    });
  });
}

// Custom failure for testing unknown failure types
class TestFailure extends Failure {}