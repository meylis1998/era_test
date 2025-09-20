import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/posts_bloc.dart';
import '../widgets/post_list_item.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.05),
                colorScheme.surface,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: BlocProvider(
            create: (_) => sl<PostsBloc>()..add(GetPostsEvent()),
            child: const PostsBody(),
          ),
        ),
      ),
    );
  }
}

class PostsBody extends StatefulWidget {
  const PostsBody({super.key});

  @override
  State<PostsBody> createState() => _PostsBodyState();
}

class _PostsBodyState extends State<PostsBody> with TickerProviderStateMixin {
  late AnimationController _floating1Controller;
  late AnimationController _floating2Controller;
  late AnimationController _floating3Controller;
  late Animation<double> _floating1Animation;
  late Animation<double> _floating2Animation;
  late Animation<double> _floating3Animation;

  @override
  void initState() {
    super.initState();

    _floating1Controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _floating2Controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _floating3Controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _floating1Animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floating1Controller, curve: Curves.easeInOut),
    );

    _floating2Animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floating2Controller, curve: Curves.easeInOut),
    );

    _floating3Animation = Tween<double>(begin: 0, end: 25).animate(
      CurvedAnimation(parent: _floating3Controller, curve: Curves.easeInOut),
    );

    _floating1Controller.repeat(reverse: true);
    _floating2Controller.repeat(reverse: true);
    _floating3Controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floating1Controller.dispose();
    _floating2Controller.dispose();
    _floating3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Floating background elements with animations
        AnimatedBuilder(
          animation: _floating1Animation,
          builder: (context, child) {
            return Positioned(
              top: size.height * 0.1 + _floating1Animation.value,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _floating2Animation,
          builder: (context, child) {
            return Positioned(
              top: size.height * 0.3 - _floating2Animation.value,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _floating3Animation,
          builder: (context, child) {
            return Positioned(
              bottom: size.height * 0.2 + _floating3Animation.value,
              right: size.width * 0.1,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.tertiary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        // Main content
        BlocBuilder<PostsBloc, PostsState>(
          builder: (context, state) {
            if (state is PostsInitial || state is PostsLoading) {
              return _buildLoadingState(context);
            } else if (state is PostsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostsBloc>().add(RefreshPostsEvent());
                },
                color: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                child: CustomScrollView(
                  slivers: [
                    // Posts list
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return PostListItem(post: state.posts[index]);
                      }, childCount: state.posts.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              );
            } else if (state is PostsError) {
              return _buildErrorState(context, state.message);
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.article_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Posts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching the latest articles for you...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.read<PostsBloc>().add(GetPostsEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
