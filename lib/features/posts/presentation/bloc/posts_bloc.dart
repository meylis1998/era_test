import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_posts.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc({required this.getPosts}) : super(PostsInitial()) {
    on<GetPostsEvent>(_onGetPosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
    on<SearchPostsEvent>(_onSearchPosts);
  }

  final GetPosts getPosts;
  List<Post>? _allPosts;

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    final failureOrPosts = await getPosts();
    failureOrPosts.fold(
      (failure) => emit(PostsError(message: _mapFailureToMessage(failure))),
      (posts) {
        _allPosts = posts;
        emit(PostsLoaded(posts: posts, allPosts: posts));
      },
    );
  }

  Future<void> _onRefreshPosts(RefreshPostsEvent event, Emitter<PostsState> emit) async {
    final failureOrPosts = await getPosts();
    failureOrPosts.fold(
      (failure) => emit(PostsError(message: _mapFailureToMessage(failure))),
      (posts) {
        _allPosts = posts;
        emit(PostsLoaded(posts: posts, allPosts: posts));
      },
    );
  }

  void _onSearchPosts(SearchPostsEvent event, Emitter<PostsState> emit) {
    if (_allPosts == null) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(PostsLoaded(posts: _allPosts!, allPosts: _allPosts!));
      return;
    }

    final filteredPosts = _allPosts!
        .where((post) => post.title.toLowerCase().contains(query))
        .toList();

    emit(PostsLoaded(
      posts: filteredPosts,
      allPosts: _allPosts!,
      searchQuery: query,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server is temporarily unavailable.\nPlease try again later.';
      case CacheFailure:
        return 'Local storage error.\nPlease try again.';
      case NetworkFailure:
        return 'No internet connection.\nCheck your network and try again.';
      default:
        return 'Something went wrong.\nPlease try again.';
    }
  }
}