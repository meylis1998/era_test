part of 'post_detail_bloc.dart';

sealed class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

class GetPostDetailEvent extends PostDetailEvent {
  const GetPostDetailEvent({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}