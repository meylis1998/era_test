import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../features/posts/data/datasources/posts_remote_data_source.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/get_posts.dart';
import '../../features/posts/domain/usecases/get_post.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/bloc/post_detail_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Posts
  // Bloc
  sl.registerFactory(
    () => PostsBloc(
      getPosts: sl(),
    ),
  );
  sl.registerFactory(
    () => PostDetailBloc(
      getPost: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPosts(sl()));
  sl.registerLazySingleton(() => GetPost(sl()));

  // Repository
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(dio: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl(), sl()));

  // External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"macOS"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site',
      },
    ));
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
    return dio;
  });
}