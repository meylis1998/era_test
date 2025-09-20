part of 'posts_bloc.dart';

sealed class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  const PostsLoaded({
    required this.posts,
    this.allPosts,
    this.searchQuery = '',
  });

  final List<Post> posts;
  final List<Post>? allPosts;
  final String searchQuery;

  bool get isSearching => searchQuery.isNotEmpty;

  @override
  List<Object> get props => [posts, allPosts ?? [], searchQuery];
}

class PostsError extends PostsState {
  const PostsError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}