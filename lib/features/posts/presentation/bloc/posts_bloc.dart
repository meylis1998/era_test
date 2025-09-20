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
  }

  final GetPosts getPosts;

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<PostsState> emit) async {
    emit(PostsLoading());
    final failureOrPosts = await getPosts();
    failureOrPosts.fold(
      (failure) => emit(PostsError(message: _mapFailureToMessage(failure))),
      (posts) => emit(PostsLoaded(posts: posts)),
    );
  }

  Future<void> _onRefreshPosts(RefreshPostsEvent event, Emitter<PostsState> emit) async {
    final failureOrPosts = await getPosts();
    failureOrPosts.fold(
      (failure) => emit(PostsError(message: _mapFailureToMessage(failure))),
      (posts) => emit(PostsLoaded(posts: posts)),
    );
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