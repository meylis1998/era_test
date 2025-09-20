part of 'post_detail_bloc.dart';

sealed class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object> get props => [];
}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  const PostDetailLoaded({required this.post});

  final Post post;

  @override
  List<Object> get props => [post];
}

class PostDetailError extends PostDetailState {
  const PostDetailError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}