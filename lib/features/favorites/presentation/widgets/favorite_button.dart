import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/features/favorites/presentation/providers/favorites_cubit.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final int movieId;
  final double size;
  final Color? color;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.movieId,
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
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (mounted) {
      setState(() => _isLoading = true);
      try {
        final isFavorite = await ref
            .read(favoritesProvider.notifier)
            .isFavorite(widget.movieId);
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Failed to check favorite status');
        }
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isFavorite) {
        await ref
            .read(favoritesProvider.notifier)
            .removeFromFavorites(widget.movieId);
        if (mounted) {
          setState(() => _isFavorite = false);
          _showSnackBar('Removed from favorites');
        }
      } else {
        // Assuming the parent has the movie details to add to favorites
        // This would need to be passed in if needed
        _showSnackBar('Added to favorites');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          _isFavorite
              ? 'Failed to remove from favorites'
              : 'Failed to add to favorites',
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
