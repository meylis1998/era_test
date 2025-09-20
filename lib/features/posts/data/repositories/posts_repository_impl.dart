import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/retry_helper.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  const PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final PostsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    if (await networkInfo.isConnected) {
      try {
        final remotePosts = await RetryHelper.retry(
          () => remoteDataSource.getPosts(),
          maxAttempts: 3,
          baseDelay: const Duration(seconds: 1),
        );
        return Right(remotePosts);
      } on ServerException {
        return Left(ServerFailure());
      } on NetworkException {
        return Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}