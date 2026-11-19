// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/main.dart
// Layer   : App (composition root)
// Purpose : Entry point and the ONLY place where concrete classes are wired
//           together (manual dependency injection):
//
//     LocalStorage ─► AuthRepositoryImpl ─► (as AuthRepository) ─► AuthBloc
//     LocalStorage ┐
//     MediaRepositoryImpl ─► PostRepositoryImpl ─► (as PostRepository) ─► FeedBloc
//     MediaRepositoryImpl ─► (as MediaRepository) ─► ReelPlayer / CreateReelPage
//     LocalStorage ─► ThemeRepositoryImpl ─► (as ThemeRepository) ─► ThemeCubit
//
//     Everything else depends on the abstract interfaces in lib/domain.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'data/datasources/local_storage.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/media_repository_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/theme_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/theme_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/feed/feed_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await LocalStorage.create();
  final MediaRepository mediaRepository = MediaRepositoryImpl();
  final AuthRepository authRepository = AuthRepositoryImpl(storage);
  final ThemeRepository themeRepository = ThemeRepositoryImpl(storage);
  final PostRepository postRepository =
      PostRepositoryImpl(storage, mediaRepository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MediaRepository>.value(value: mediaRepository),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<PostRepository>.value(value: postRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  AuthBloc(authRepository)..add(const AuthStarted())),
          BlocProvider(
              create: (_) =>
                  FeedBloc(postRepository)..add(const FeedStarted())),
          BlocProvider(create: (_) => ThemeCubit(themeRepository)),
        ],
        child: const App(),
      ),
    ),
  );
}
