part of 'posts_bloc.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class GetPostsEvent extends PostsEvent {}

class RefreshPostsEvent extends PostsEvent {}

class SearchPostsEvent extends PostsEvent {
  const SearchPostsEvent({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}