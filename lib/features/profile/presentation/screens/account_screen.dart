import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/core/injection_container.dart' as di;
import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:movie_discovery_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:movie_discovery_app/l10n/app_localizations.dart';

class AccountScreen extends ConsumerWidget {
  static bool _printedTokenOnce = false;
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (!_printedTokenOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final token = await di.sl<AuthLocalDataSource>().getStoredToken();
          print('JWT Token: $token');
        } catch (_) {}
      });
      _printedTokenOnce = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.account),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  _getInitials(user.displayName ?? user.email),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Display Name
                        Text(
                          user.displayName ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        // Email
                        Text(
                          user.email,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Information Section
                  _buildSection(
                    context,
                    l10n,
                    title: l10n.accountInformation,
                    children: [
                      _buildInfoTile(
                        context,
                        l10n,
                        icon: Icons.person,
                        title: l10n.displayName,
                        subtitle: user.displayName ?? l10n.notSet,
                      ),
                      _buildInfoTile(
                        context,
                        l10n,
                        icon: Icons.email,
                        title: l10n.email,
                        subtitle: user.email,
                      ),
                      _buildInfoTile(
                        context,
                        l10n,
                        icon: Icons.fingerprint,
                        title: l10n.userId,
                        subtitle: user.id,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Preferences Section
                  _buildSection(
                    context,
                    l10n,
                    title: l10n.preferences,
                    children: [
                      // Theme Toggle
                      ListTile(
                        leading: Icon(
                          settings.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : settings.themeMode == ThemeMode.light
                                  ? Icons.light_mode
                                  : Icons.brightness_auto,
                        ),
                        title: Text(l10n.theme),
                        subtitle: Text(
                          settings.themeMode == ThemeMode.dark
                              ? l10n.themeDark
                              : settings.themeMode == ThemeMode.light
                                  ? l10n.themeLight
                                  : l10n.themeSystem,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showThemeDialog(context, l10n, settingsNotifier, settings);
                        },
                      ),
                      // Language Toggle
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.language),
                        subtitle: Text(
                          settings.locale?.languageCode == 'uk'
                              ? l10n.languageUkrainian
                              : l10n.languageEnglish,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showLanguageDialog(context, l10n, settingsNotifier, settings);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Settings Section
                  _buildSection(
                    context,
                    l10n,
                    title: l10n.settings,
                    children: [
                      if (user.role == 'Admin')
                        ListTile(
                          leading: const Icon(Icons.supervisor_account),
                          title: Text(l10n.manageUsers),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.go('/admin/users');
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: Text(l10n.editProfile),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.editProfileComingSoon),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: Text(l10n.changePassword),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.changePasswordComingSoon),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(l10n.notifications),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.notificationsSettingsComingSoon),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Actions Section
                  _buildSection(
                    context,
                    l10n,
                    title: l10n.actions,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          l10n.signOut,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () async {
                          final shouldSignOut = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.signOut),
                              content: Text(l10n.signOutConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.signOut),
                                ),
                              ],
                            ),
                          );

                          if (shouldSignOut == true && context.mounted) {
                            await ref.read(authProvider.notifier).signOutUser();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  Text(
                    '${l10n.version} 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    AppLocalizations l10n,
    SettingsNotifier settingsNotifier,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeLight),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeDark),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeSystem),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    AppLocalizations l10n,
    SettingsNotifier settingsNotifier,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: settings.locale?.languageCode ?? 'en',
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageUkrainian),
              value: 'uk',
              groupValue: settings.locale?.languageCode ?? 'en',
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    AppLocalizations l10n, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
