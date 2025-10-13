import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('uk'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_title': 'Movie Discovery',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      
      // Account Screen
      'account': 'Account',
      'account_information': 'Account Information',
      'display_name': 'Display Name',
      'email': 'Email',
      'user_id': 'User ID',
      'not_set': 'Not set',
      
      // Settings
      'settings': 'Settings',
      'preferences': 'Preferences',
      'theme': 'Theme',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'language': 'Language',
      'language_english': 'English',
      'language_ukrainian': 'Українська',
      'manage_users': 'Manage Users',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'notifications': 'Notifications',
      'edit_profile_coming_soon': 'Edit profile coming soon',
      'change_password_coming_soon': 'Change password coming soon',
      'notifications_settings_coming_soon': 'Notifications settings coming soon',
      
      // Actions
      'actions': 'Actions',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      
      // Version
      'version': 'Version',
      
      // Auth
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'sign_in_to_continue': 'Sign in to continue',
      'create_account': 'Create Account',
      'sign_up_to_get_started': 'Sign up to get started',
      'full_name': 'Full Name',
      'confirm_password': 'Confirm Password',
      'please_enter_name': 'Please enter your name',
      'please_enter_email': 'Please enter your email',
      'please_enter_valid_email': 'Please enter a valid email',
      'please_enter_password': 'Please enter your password',
      'password_min_length': 'Password must be at least 6 characters',
      'please_confirm_password': 'Please confirm your password',
      'passwords_do_not_match': 'Passwords do not match',
      
      // Movies
      'popular': 'Popular',
      'popular_movies': 'Popular Movies',
      'top_rated': 'Top Rated',
      'home': 'Home',
      'favorites': 'Favorites',
      'search': 'Search',
      'search_movies_hint': 'Search movies...',
      'search_for_movies': 'Search for movies',
      'no_movies_found': 'No movies found',
      'discover': 'Discover',
      'movie_details': 'Movie Details',
      'overview': 'Overview',
      'trailers': 'Trailers',
      'cast': 'Cast',
      'reviews': 'Reviews',
      'videos': 'Videos',
      'add_to_favorites': 'Add to Favorites',
      'remove_from_favorites': 'Remove from Favorites',
      'release_label': 'Release',
      
      // Profile
      'profile': 'Profile',
      'my_favorites': 'My Favorites',
      'watchlist': 'Watchlist',
      'ratings': 'Ratings',
      'error_loading_favorites': 'Error loading favorites',
      'no_favorites_yet': 'No favorites yet',
      'tap_heart_to_add_favorites': 'Tap the heart icon on any movie to add it to your favorites',
      'removed_from_favorites': 'Removed from favorites',
      'failed_to_remove': 'Failed to remove',
      'failed_to_load_details': 'Failed to load details',
    },
    'uk': {
      // General
      'app_title': 'Пошук Фільмів',
      'loading': 'Завантаження...',
      'error': 'Помилка',
      'retry': 'Повторити',
      'cancel': 'Скасувати',
      'save': 'Зберегти',
      'delete': 'Видалити',
      'confirm': 'Підтвердити',
      'yes': 'Так',
      'no': 'Ні',
      
      // Account Screen
      'account': 'Обліковий запис',
      'account_information': 'Інформація про обліковий запис',
      'display_name': "Ім'я користувача",
      'email': 'Електронна пошта',
      'user_id': 'ID користувача',
      'not_set': 'Не встановлено',
      
      // Settings
      'settings': 'Налаштування',
      'preferences': 'Параметри',
      'theme': 'Тема',
      'theme_light': 'Світла',
      'theme_dark': 'Темна',
      'theme_system': 'Системна',
      'language': 'Мова',
      'language_english': 'English',
      'language_ukrainian': 'Українська',
      'manage_users': 'Керування користувачами',
      'edit_profile': 'Редагувати профіль',
      'change_password': 'Змінити пароль',
      'notifications': 'Сповіщення',
      'edit_profile_coming_soon': 'Редагування профілю незабаром',
      'change_password_coming_soon': 'Зміна пароля незабаром',
      'notifications_settings_coming_soon': 'Налаштування сповіщень незабаром',
      
      // Actions
      'actions': 'Дії',
      'sign_out': 'Вийти',
      'sign_out_confirm': 'Ви впевнені, що хочете вийти?',
      
      // Version
      'version': 'Версія',
      
      // Auth
      'sign_in': 'Увійти',
      'sign_up': 'Зареєструватися',
      'password': 'Пароль',
      'forgot_password': 'Забули пароль?',
      'dont_have_account': 'Немає облікового запису?',
      'already_have_account': 'Вже є обліковий запис?',
      'sign_in_to_continue': 'Увійдіть, щоб продовжити',
      'create_account': 'Створити обліковий запис',
      'sign_up_to_get_started': 'Зареєструйтесь, щоб почати',
      'full_name': "Повне ім'я",
      'confirm_password': 'Підтвердьте пароль',
      'please_enter_name': "Будь ласка, введіть ім'я",
      'please_enter_email': 'Будь ласка, введіть електронну пошту',
      'please_enter_valid_email': 'Будь ласка, введіть коректну електронну пошту',
      'please_enter_password': 'Будь ласка, введіть пароль',
      'password_min_length': 'Пароль має містити щонайменше 6 символів',
      'please_confirm_password': 'Будь ласка, підтвердьте пароль',
      'passwords_do_not_match': 'Паролі не співпадають',
      
      // Movies
      'popular': 'Популярні',
      'popular_movies': 'Популярні фільми',
      'top_rated': 'Найкращі',
      'home': 'Головна',
      'favorites': 'Улюблені',
      'search': 'Пошук',
      'search_movies_hint': 'Пошук фільмів...',
      'search_for_movies': 'Пошук фільмів',
      'no_movies_found': 'Фільми не знайдені',
      'discover': 'Відкрити',
      'movie_details': 'Деталі фільму',
      'overview': 'Огляд',
      'trailers': 'Трейлери',
      'cast': 'Акторський склад',
      'reviews': 'Відгуки',
      'videos': 'Відео',
      'add_to_favorites': 'Додати до улюблених',
      'remove_from_favorites': 'Видалити з улюблених',
      'release_label': 'Рік випуску',
      
      // Profile
      'profile': 'Профіль',
      'my_favorites': 'Мої улюблені',
      'watchlist': 'Список перегляду',
      'ratings': 'Оцінки',
      'error_loading_favorites': 'Помилка завантаження улюблених',
      'no_favorites_yet': 'Немає улюблених',
      'tap_heart_to_add_favorites': 'Натисніть на іконку серця на будь-якому фільмі, щоб додати його в улюблені',
      'removed_from_favorites': 'Видалено з улюблених',
      'failed_to_remove': 'Не вдалося видалити',
      'failed_to_load_details': 'Не вдалося завантажити деталі',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get appTitle => translate('app_title');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  
  // Account Screen
  String get account => translate('account');
  String get accountInformation => translate('account_information');
  String get displayName => translate('display_name');
  String get email => translate('email');
  String get userId => translate('user_id');
  String get notSet => translate('not_set');
  
  // Settings
  String get settings => translate('settings');
  String get preferences => translate('preferences');
  String get theme => translate('theme');
  String get themeLight => translate('theme_light');
  String get themeDark => translate('theme_dark');
  String get themeSystem => translate('theme_system');
  String get language => translate('language');
  String get languageEnglish => translate('language_english');
  String get languageUkrainian => translate('language_ukrainian');
  String get manageUsers => translate('manage_users');
  String get editProfile => translate('edit_profile');
  String get changePassword => translate('change_password');
  String get notifications => translate('notifications');
  String get editProfileComingSoon => translate('edit_profile_coming_soon');
  String get changePasswordComingSoon => translate('change_password_coming_soon');
  String get notificationsSettingsComingSoon => translate('notifications_settings_coming_soon');
  
  // Actions
  String get actions => translate('actions');
  String get signOut => translate('sign_out');
  String get signOutConfirm => translate('sign_out_confirm');
  
  // Version
  String get version => translate('version');
  
  // Auth
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get signInToContinue => translate('sign_in_to_continue');
  String get createAccount => translate('create_account');
  String get signUpToGetStarted => translate('sign_up_to_get_started');
  String get fullName => translate('full_name');
  String get confirmPassword => translate('confirm_password');
  String get pleaseEnterName => translate('please_enter_name');
  String get pleaseEnterEmail => translate('please_enter_email');
  String get pleaseEnterValidEmail => translate('please_enter_valid_email');
  String get pleaseEnterPassword => translate('please_enter_password');
  String get passwordMinLength => translate('password_min_length');
  String get pleaseConfirmPassword => translate('please_confirm_password');
  String get passwordsDoNotMatch => translate('passwords_do_not_match');
  
  // Movies
  String get popular => translate('popular');
  String get popularMovies => translate('popular_movies');
  String get topRated => translate('top_rated');
  String get favorites => translate('favorites');
  String get home => translate('home');
  String get search => translate('search');
  String get searchMoviesHint => translate('search_movies_hint');
  String get searchForMovies => translate('search_for_movies');
  String get noMoviesFound => translate('no_movies_found');
  String get discover => translate('discover');
  String get movieDetails => translate('movie_details');
  String get overview => translate('overview');
  String get trailers => translate('trailers');
  String get cast => translate('cast');
  String get reviews => translate('reviews');
  String get videos => translate('videos');
  String get addToFavorites => translate('add_to_favorites');
  String get removeFromFavorites => translate('remove_from_favorites');
  String get releaseLabel => translate('release_label');
  
  // Profile
  String get profile => translate('profile');
  String get myFavorites => translate('my_favorites');
  String get watchlist => translate('watchlist');
  String get ratings => translate('ratings');
  String get errorLoadingFavorites => translate('error_loading_favorites');
  String get noFavoritesYet => translate('no_favorites_yet');
  String get tapHeartToAddFavorites => translate('tap_heart_to_add_favorites');
  String get removedFromFavorites => translate('removed_from_favorites');
  String get failedToRemove => translate('failed_to_remove');
  String get failedToLoadDetails => translate('failed_to_load_details');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
