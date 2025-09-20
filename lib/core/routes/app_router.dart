import 'package:go_router/go_router.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const PostsPage(),
    ),
    GoRoute(
      path: AppRoutes.posts,
      builder: (context, state) => const PostsPage(),
    ),
    GoRoute(
      path: AppRoutes.postDetail,
      builder: (context, state) {
        final postId = int.parse(state.pathParameters['id']!);
        return PostDetailPage(postId: postId);
      },
    ),
  ],
);
