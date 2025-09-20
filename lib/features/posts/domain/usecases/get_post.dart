import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPost {
  const GetPost(this.repository);

  final PostsRepository repository;

  Future<Either<Failure, Post>> call(int id) async {
    return await repository.getPost(id);
  }
}