import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:era_test/features/posts/domain/entities/post.dart';
import 'package:era_test/features/posts/domain/usecases/get_posts.dart';
import 'package:era_test/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:era_test/core/errors/failures.dart';

class MockGetPosts extends Mock implements GetPosts {}

void main() {
  late PostsBloc bloc;
  late MockGetPosts mockGetPosts;

  setUp(() {
    mockGetPosts = MockGetPosts();
    bloc = PostsBloc(getPosts: mockGetPosts);
  });

  const tPost = Post(
    userId: 1,
    id: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  const tPostsList = [tPost];

  group('PostsBloc', () {
    test('initial state should be PostsInitial', () {
      expect(bloc.state, equals(PostsInitial()));
    });

    group('GetPostsEvent', () {
      blocTest<PostsBloc, PostsState>(
        'should emit [PostsLoading, PostsLoaded] when data is gotten successfully',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => const Right(tPostsList));
          return bloc;
        },
        act: (bloc) => bloc.add(GetPostsEvent()),
        expect: () => [
          PostsLoading(),
          const PostsLoaded(posts: tPostsList, allPosts: tPostsList),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );

      blocTest<PostsBloc, PostsState>(
        'should emit [PostsLoading, PostsError] when getting data fails with ServerFailure',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetPostsEvent()),
        expect: () => [
          PostsLoading(),
          const PostsError(message: 'Server is temporarily unavailable.\\nPlease try again later.'),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );

      blocTest<PostsBloc, PostsState>(
        'should emit [PostsLoading, PostsError] when getting data fails with NetworkFailure',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => Left(NetworkFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetPostsEvent()),
        expect: () => [
          PostsLoading(),
          const PostsError(message: 'No internet connection.\\nCheck your network and try again.'),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );

      blocTest<PostsBloc, PostsState>(
        'should emit [PostsLoading, PostsError] when getting data fails with CacheFailure',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => Left(CacheFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(GetPostsEvent()),
        expect: () => [
          PostsLoading(),
          const PostsError(message: 'Local storage error.\\nPlease try again.'),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );
    });

    group('RefreshPostsEvent', () {
      blocTest<PostsBloc, PostsState>(
        'should emit [PostsLoaded] when refresh is successful',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => const Right(tPostsList));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshPostsEvent()),
        expect: () => [
          const PostsLoaded(posts: tPostsList, allPosts: tPostsList),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );

      blocTest<PostsBloc, PostsState>(
        'should emit [PostsError] when refresh fails',
        build: () {
          when(() => mockGetPosts()).thenAnswer((_) async => Left(ServerFailure()));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshPostsEvent()),
        expect: () => [
          const PostsError(message: 'Server is temporarily unavailable.\\nPlease try again later.'),
        ],
        verify: (_) {
          verify(() => mockGetPosts());
        },
      );
    });

    group('SearchPostsEvent', () {
      const tPost1 = Post(userId: 1, id: 1, title: 'Flutter Tutorial', body: 'Learn Flutter');
      const tPost2 = Post(userId: 2, id: 2, title: 'Dart Guide', body: 'Learn Dart');
      const tPost3 = Post(userId: 3, id: 3, title: 'React Tutorial', body: 'Learn React');
      const tAllPosts = [tPost1, tPost2, tPost3];

      blocTest<PostsBloc, PostsState>(
        'should filter posts by title when search query is provided',
        build: () => bloc,
        seed: () => const PostsLoaded(posts: tAllPosts, allPosts: tAllPosts),
        act: (bloc) => bloc.add(const SearchPostsEvent(query: 'Flutter')),
        expect: () => [
          const PostsLoaded(
            posts: [tPost1],
            allPosts: tAllPosts,
            searchQuery: 'flutter',
          ),
        ],
      );

      blocTest<PostsBloc, PostsState>(
        'should return all posts when search query is empty',
        build: () => bloc,
        seed: () => const PostsLoaded(
          posts: [tPost1],
          allPosts: tAllPosts,
          searchQuery: 'flutter',
        ),
        act: (bloc) => bloc.add(const SearchPostsEvent(query: '')),
        expect: () => [
          const PostsLoaded(posts: tAllPosts, allPosts: tAllPosts),
        ],
      );

      blocTest<PostsBloc, PostsState>(
        'should return empty list when no posts match search query',
        build: () => bloc,
        seed: () => const PostsLoaded(posts: tAllPosts, allPosts: tAllPosts),
        act: (bloc) => bloc.add(const SearchPostsEvent(query: 'nonexistent')),
        expect: () => [
          const PostsLoaded(
            posts: [],
            allPosts: tAllPosts,
            searchQuery: 'nonexistent',
          ),
        ],
      );

      blocTest<PostsBloc, PostsState>(
        'should be case insensitive when searching',
        build: () => bloc,
        seed: () => const PostsLoaded(posts: tAllPosts, allPosts: tAllPosts),
        act: (bloc) => bloc.add(const SearchPostsEvent(query: 'FLUTTER')),
        expect: () => [
          const PostsLoaded(
            posts: [tPost1],
            allPosts: tAllPosts,
            searchQuery: 'flutter',
          ),
        ],
      );

      blocTest<PostsBloc, PostsState>(
        'should do nothing when allPosts is null',
        build: () => bloc,
        act: (bloc) => bloc.add(const SearchPostsEvent(query: 'Flutter')),
        expect: () => [],
      );
    });
  });
}