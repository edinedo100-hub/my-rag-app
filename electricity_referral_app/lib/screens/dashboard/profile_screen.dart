import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../language_provider.dart';
import '../../notification_provider.dart';
import 'change_password_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final user = authProvider.userProfile;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bolt_rounded, color: theme.primaryColor, size: 28),
            const SizedBox(width: 8),
            Text(
              lang.translate('app_name'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              lang.setLanguage(
                lang.currentLanguage == AppLanguage.de
                    ? AppLanguage.en
                    : AppLanguage.de,
              );
            },
            child: Text(
              lang.currentLanguage == AppLanguage.de ? 'EN' : 'DE',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 32,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.displayName,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              '${lang.translate('member_since')} ${user.createdAt.year}',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            _buildSection(theme, lang.translate('account_settings'), [
              _buildTile(
                theme,
                Icons.lock_open_rounded,
                lang.translate('change_password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildTile(
                theme,
                Icons.notifications_none_rounded,
                lang.translate('notifications'),
                trailing: notificationProvider.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ]),

            _buildSection(theme, lang.translate('support_info'), [
              _buildTile(
                theme,
                Icons.info_outline_rounded,
                lang.translate('about_us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              _buildTile(
                theme,
                Icons.help_outline_rounded,
                lang.translate('contact_us'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => authProvider.signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: Text(lang.translate('logout')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red[400],
                  side: BorderSide(color: Colors.red[100]!),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTile(
    ThemeData theme,
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.primaryColor, size: 22),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
    );
  }
}
