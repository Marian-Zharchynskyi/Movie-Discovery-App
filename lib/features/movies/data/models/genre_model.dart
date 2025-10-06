class GenreModel {
  static const Map<int, String> genres = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static String getGenreName(int genreId) {
    return genres[genreId] ?? 'Unknown';
  }

  static List<String> getGenreNames(List<int> genreIds) {
    return genreIds.map((id) => genres[id] ?? 'Unknown').toList();
  }
}
