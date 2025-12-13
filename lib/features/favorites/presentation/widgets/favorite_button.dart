import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final MovieEntity movie;
  final double size;
  final Color? color;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.movie,
    this.size = 32.0,
    this.color,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserAndCheckStatus();
    });
  }

  void _syncUserAndCheckStatus() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    ref.read(favoritesProvider.notifier).setUserId(userId);
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (mounted) {
      setState(() => _isLoading = true);
      try {
        final isFavorite = await ref
            .read(favoritesProvider.notifier)
            .isFavorite(widget.movie.id);
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(
            AppLocalizations.of(context).failedToCheckFavoriteStatus,
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isFavorite) {
        final success = await ref
            .read(favoritesProvider.notifier)
            .removeFromFavorites(widget.movie.id);
        if (mounted) {
          if (success) {
            setState(() => _isFavorite = false);
            _showSnackBar(AppLocalizations.of(context).removedFromFavorites);
          } else {
            _showErrorSnackBar(
              AppLocalizations.of(context).failedToRemoveFromFavorites,
            );
          }
        }
      } else {
        final favoriteMovie = FavoriteMovieEntity(
          id: widget.movie.id,
          title: widget.movie.title,
          overview: widget.movie.overview,
          posterPath: widget.movie.posterPath,
          backdropPath: widget.movie.backdropPath,
          voteAverage: widget.movie.voteAverage,
          releaseDate: widget.movie.releaseDate,
          genreIds: widget.movie.genreIds,
          dateAdded: DateTime.now(),
        );
        
        final success = await ref
            .read(favoritesProvider.notifier)
            .addMovieToFavorites(favoriteMovie);
        if (mounted) {
          if (success) {
            setState(() => _isFavorite = true);
            _showSnackBar(AppLocalizations.of(context).addedToFavorites);
          } else {
            _showErrorSnackBar(
              AppLocalizations.of(context).failedToAddToFavorites,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          _isFavorite
              ? AppLocalizations.of(context).failedToRemoveFromFavorites
              : AppLocalizations.of(context).failedToAddToFavorites,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.onSurface;
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? color;

    return IconButton(
      icon: _isLoading
          ? SizedBox(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isFavorite ? activeColor : inactiveColor,
                ),
              ),
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? activeColor : inactiveColor,
              size: widget.size,
            ),
      onPressed: _toggleFavorite,
      splashRadius: widget.size * 0.8,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: widget.size * 1.5,
        minHeight: widget.size * 1.5,
      ),
    );
  }
}
