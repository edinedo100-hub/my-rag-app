import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../language_provider.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  final String _email = 'office@fiberquant.at';
  final String _phone = '+43 650 3019250';

  Future<void> _launchEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'WattWise Support Inquiry'},
    );
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch mail app');
    }
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri(scheme: 'tel', path: _phone.replaceAll(' ', ''));
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch phone app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(lang.translate('contact_us'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              lang.translate('contact_support'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            _buildContactCard(
              theme,
              Icons.email_outlined,
              lang.translate('email'),
              _email,
              onTap: _launchEmail,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              theme,
              Icons.phone_outlined,
              lang.translate('phone'),
              _phone,
              onTap: _launchPhone,
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: theme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Mo - Fr: 09:00 - 17:00',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    ThemeData theme,
    IconData icon,
    String label,
    String content, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
