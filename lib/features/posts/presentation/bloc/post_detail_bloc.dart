import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_post.dart';

part 'post_detail_event.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({required this.getPost}) : super(PostDetailInitial()) {
    on<GetPostDetailEvent>(_onGetPostDetail);
  }

  final GetPost getPost;

  Future<void> _onGetPostDetail(GetPostDetailEvent event, Emitter<PostDetailState> emit) async {
    emit(PostDetailLoading());
    final failureOrPost = await getPost(event.id);
    failureOrPost.fold(
      (failure) => emit(PostDetailError(message: _mapFailureToMessage(failure))),
      (post) => emit(PostDetailLoaded(post: post)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server is temporarily unavailable.\\nPlease try again later.';
      case CacheFailure:
        return 'Local storage error.\\nPlease try again.';
      case NetworkFailure:
        return 'No internet connection.\\nCheck your network and try again.';
      default:
        return 'Something went wrong.\\nPlease try again.';
    }
  }
}