part of 'posts_bloc.dart';

sealed class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  const PostsLoaded({required this.posts});

  final List<Post> posts;

  @override
  List<Object> get props => [posts];
}

class PostsError extends PostsState {
  const PostsError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}