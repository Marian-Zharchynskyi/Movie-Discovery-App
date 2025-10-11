import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_discovery_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_discovery_app/core/injection_container.dart' as di;
import 'package:movie_discovery_app/features/auth/data/datasources/auth_local_data_source.dart';

class AccountScreen extends ConsumerWidget {
  static bool _printedTokenOnce = false;
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
        title: const Text('Account'),
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
                    title: 'Account Information',
                    children: [
                      _buildInfoTile(
                        context,
                        icon: Icons.person,
                        title: 'Display Name',
                        subtitle: user.displayName ?? 'Not set',
                      ),
                      _buildInfoTile(
                        context,
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      _buildInfoTile(
                        context,
                        icon: Icons.fingerprint,
                        title: 'User ID',
                        subtitle: user.id,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Settings Section
                  _buildSection(
                    context,
                    title: 'Settings',
                    children: [
                      if (user.role == 'Admin')
                        ListTile(
                          leading: const Icon(Icons.supervisor_account),
                          title: const Text('Manage Users'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.go('/admin/users');
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to edit profile screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile coming soon'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to change password screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Change password coming soon'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to notifications settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications settings coming soon'),
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
                    title: 'Actions',
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () async {
                          final shouldSignOut = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                'Are you sure you want to sign out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sign Out'),
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
                    'Version 1.0.0',
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

  Widget _buildSection(
    BuildContext context, {
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
    BuildContext context, {
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
