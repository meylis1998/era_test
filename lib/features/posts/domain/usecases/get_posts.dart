import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPosts {
  const GetPosts(this.repository);

  final PostsRepository repository;

  Future<Either<Failure, List<Post>>> call() async {
    return await repository.getPosts();
  }
}