import 'package:bookfinder/Blocs/book_details_bloc/book_details_bloc.dart';
import 'package:bookfinder/Blocs/book_details_bloc/book_details_event.dart';
import 'package:bookfinder/Blocs/book_details_bloc/book_details_state.dart';
import 'package:bookfinder/model/book.dart';
import 'package:bookfinder/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/animated_book_cover.dart';

class DetailsScreen extends StatelessWidget {
  final Book book;

  const DetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookDetailsBloc(
        repository: RepositoryProvider.of<BookRepository>(context),
      )..add(LoadBookDetails(book)),
      child: DetailsScreenContent(book: book),
    );
  }
}

class DetailsScreenContent extends StatelessWidget {
  final Book book;

  const DetailsScreenContent({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          BlocBuilder<BookDetailsBloc, BookDetailsState>(
            builder: (context, state) {
              if (state is BookDetailsLoaded) {
                return IconButton(
                  icon: Icon(
                    state.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: state.isSaved ? Colors.orange : null,
                  ),
                  onPressed: () {
                    if (state.isSaved) {
                      if (state.book.key != null) {
                        context
                            .read<BookDetailsBloc>()
                            .add(RemoveBook(state.book.key!));
                      }
                    } else {
                      context
                          .read<BookDetailsBloc>()
                          .add(SaveBook(state.book));
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<BookDetailsBloc, BookDetailsState>(
        listener: (context, state) {
          if (state is BookSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book saved to library'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BookRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Book removed from library'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is BookDetailsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover and Basic Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBookCover(
                        imageUrl: state.book.coverUrl,
                        size: 120,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (state.book.authors.isNotEmpty)
                              Text(
                                'By ${state.book.authorsString}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            const SizedBox(height: 8),
                            if (state.book.firstPublishYear != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Published: ${state.book.firstPublishYear}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: state.isSaved
                                    ? Colors.orange[100]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    state.isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 16,
                                    color: state.isSaved
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.isSaved
                                        ? 'Saved'
                                        : 'Not Saved',
                                    style: TextStyle(
                                      color: state.isSaved
                                          ? Colors.orange[700]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description Section
                  if (state.book.description != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.book.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  
                  // Additional Information
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    context,
                    'Authors',
                    state.book.authors.isNotEmpty
                        ? state.book.authorsString
                        : 'Not available',
                    Icons.person,
                  ),
                  
                  if (state.book.firstPublishYear != null)
                    _buildInfoCard(
                      context,
                      'First Published',
                      state.book.firstPublishYear.toString(),
                      Icons.calendar_today,
                    ),
                  
                  if (state.book.isbn != null && state.book.isbn!.isNotEmpty)
                    _buildInfoCard(
                      context,
                      'ISBN',
                      state.book.isbn!.first,
                      Icons.numbers,
                    ),
                  
                  if (state.book.key != null)
                    _buildInfoCard(
                      context,
                      'Open Library Key',
                      state.book.key!,
                      Icons.key,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (state.isSaved) {
                              if (state.book.key != null) {
                                context
                                    .read<BookDetailsBloc>()
                                    .add(RemoveBook(state.book.key!));
                              }
                            } else {
                              context
                                  .read<BookDetailsBloc>()
                                  .add(SaveBook(state.book));
                            }
                          },
                          icon: Icon(
                            state.isSaved
                                ? Icons.bookmark_remove
                                : Icons.bookmark_add,
                          ),
                          label: Text(
                            state.isSaved
                                ? 'Remove from Library'
                                : 'Save to Library',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.isSaved
                                ? Colors.orange
                                : Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is BookDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BookDetailsBloc>()
                          .add(LoadBookDetails(book));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}