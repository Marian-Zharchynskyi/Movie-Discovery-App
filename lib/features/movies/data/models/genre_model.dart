class GenreModel {
  static const Map<int, String> genresEn = {
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

  static const Map<int, String> genres = genresEn;

  static const Map<int, String> genresUk = {
    28: 'Бойовик',
    12: 'Пригоди',
    16: 'Анімація',
    35: 'Комедія',
    80: 'Кримінал',
    18: 'Драма',
    10751: "Сімейний",
    14: 'Фентезі',
    36: 'Історія',
    27: 'Жахи',
    10402: 'Музика',
    9648: 'Детектив',
    10749: 'Романтика',
    878: 'Наукова фантастика',
    10770: 'Телефільм',
    53: 'Трилер',
    10752: 'Військовий',
    37: 'Вестерн',
  };

  static const Map<String, Map<int, String>> _genresByLanguageCode = {
    'en': genresEn,
    'uk': genresUk,
  };

  static Map<int, String> genresFor(String languageCode) {
    return _genresByLanguageCode[languageCode] ?? genresEn;
  }

  static String getGenreName(
    int genreId, {
    String languageCode = 'en',
    String unknownLabel = 'Unknown',
  }) {
    return genresFor(languageCode)[genreId] ?? unknownLabel;
  }

  static List<String> getGenreNames(
    List<int> genreIds, {
    String languageCode = 'en',
    String unknownLabel = 'Unknown',
  }) {
    final genres = genresFor(languageCode);
    return genreIds.map((id) => genres[id] ?? unknownLabel).toList();
  }
}
