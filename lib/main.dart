import 'package:bookfinder/Blocs/book_search_bloc/book_search_bloc.dart';
import 'package:bookfinder/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BookRepository>(
          create: (context) => BookRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookSearchBloc>(
            create: (context) => BookSearchBloc(
              repository: RepositoryProvider.of<BookRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Book Search App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SearchScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}