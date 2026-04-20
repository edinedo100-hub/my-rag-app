import 'package:flutter/material.dart';

enum AppLanguage { en, de }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage =
      AppLanguage.de; // Default to German based on user context

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    if (_currentLanguage == AppLanguage.de) {
      return _german[key] ?? key;
    }
    return _english[key] ?? key;
  }

  static const Map<String, String> _english = {
    'app_name': 'WattWise',
    'slogan': 'Save on energy costs and\nshare the savings.',
    'login': 'Login',
    'register': 'Register',
    'full_name': 'Full Name',
    'email_hint': 'Email Address',
    'password_hint': 'Password',
    'no_account': "Don't have an account? ",
    'has_account': "Already have an account? ",
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'dashboard': 'Dashboard',
    'welcome': 'Hello,',
    'savings_title': 'Your Savings & Rewards',
    'status': 'Status',
    'active': 'Active',
    'invitations': 'Invitations',
    'actions': 'Actions',
    'upload_bill': 'Upload Bill',
    'analyze_bill': 'Analyze your electricity bill',
    'my_referrals': 'My Referrals',
    'manage_referrals': 'Manage your referrals',
    'copy_link': 'Copy Link',
    'share_link': 'Share your referral link',
    'consultation_title': 'Next Step: Consultation',
    'consultation_text':
        'Once you upload a bill, our experts review it manually and contact you for a detailed consultation.',
    'profile': 'Profile',
    'member_since': 'Member since',
    'account_settings': 'Account Settings',
    'change_password': 'Change Password',
    'notifications': 'Notifications',
    'support_info': 'Support & Info',
    'about': 'About WattWise',
    'faq': 'FAQ & Support',
    'logout': 'Logout',
    'link_copied': 'Referral link copied!',
    'secure_confidential': 'Secure & Confidential',
    'home': 'Home',
    'referrals': 'Referrals',
    'notifications_page': 'Notifications',
    'no_notifications': 'No notifications yet.',
    'enable_notifications': 'Enable Notifications',
    'receive_updates': 'Receive updates about your balance and rewards.',
    'about_us': 'About Us',
    'about_content':
        'WattWise is your partner for energy cost optimization. We combine professional consultation with a reward system that values your recommendations.',
    'contact_us': 'Contact Us',
    'contact_support': 'Need help? Contact our support team.',
    'email': 'Email',
    'phone': 'Phone',
    'about_description':
        'Individual energy consultation and rewards through referrals.',
    'old_password': 'Current Password',
    'new_password': 'New Password',
    'confirm_password': 'Confirm New Password',
    'update_password_btn': 'Update Password',
    'passwords_not_match': 'Passwords do not match',
    'password_changed_success': 'Password updated successfully!',
    'or': 'OR',
    'sign_in_google': 'Sign in with Google',
    'sign_up_google': 'Sign up with Google',
  };

  static const Map<String, String> _german = {
    'app_name': 'WattWise',
    'slogan': 'Spare Stromkosten und\nteile die Ersparnis.',
    'login': 'Anmelden',
    'register': 'Registrieren',
    'full_name': 'Vollständiger Name',
    'email_hint': 'E-Mail-Adresse',
    'password_hint': 'Passwort',
    'no_account': "Noch kein Konto? ",
    'has_account': "Schon ein Konto? ",
    'sign_in': 'Login',
    'sign_up': 'Registrieren',
    'dashboard': 'Dashboard',
    'welcome': 'Hallo,',
    'savings_title': 'Deine Ersparnisse & Rewards',
    'status': 'Status',
    'active': 'Aktiv',
    'invitations': 'Einladungen',
    'actions': 'Aktionen',
    'upload_bill': 'Rechnung hochladen',
    'analyze_bill': 'Stromrechnung analysieren lassen',
    'my_referrals': 'Meine Einladungen',
    'manage_referrals': 'Verwalte deine Empfehlungen',
    'copy_link': 'Link kopieren',
    'share_link': 'Teile deinen Empfehlungslink',
    'consultation_title': 'Nächster Schritt: Beratung',
    'consultation_text':
        'Sobald du eine Rechnung hochlädst, prüfen unsere Experten diese manuell und kontaktieren dich für eine detaillierte Beratung.',
    'profile': 'Profil',
    'member_since': 'Mitglied seit',
    'account_settings': 'Kontoeinstellungen',
    'change_password': 'Passwort ändern',
    'notifications': 'Benachrichtigungen',
    'support_info': 'Support & Info',
    'about': 'Über WattWise',
    'faq': 'Häufige Fragen (FAQ)',
    'logout': 'Abmelden',
    'link_copied': 'Empfehlungslink kopiert!',
    'secure_confidential': 'Sicher & Vertraulich',
    'home': 'Home',
    'referrals': 'Einladungen',
    'notifications_page': 'Benachrichtigungen',
    'no_notifications': 'Noch keine Benachrichtigungen.',
    'enable_notifications': 'Benachrichtigungen aktivieren',
    'receive_updates': 'Erhalte Updates zu deinem Guthaben und Belohnungen.',
    'about_us': 'Über uns',
    'about_content':
        'WattWise ist dein Partner für die Optimierung von Energiekosten. Wir kombinieren professionelle Beratung mit einem Belohnungssystem, das deine Empfehlungen wertschätzt.',
    'contact_us': 'Kontakt',
    'contact_support': 'Benötigst du Hilfe? Kontaktiere unser Team.',
    'email': 'E-Mail',
    'phone': 'Telefon',
    'profile_tab': 'Profil',
    'about_description':
        'Individuelle Energieberatung und Belohnungen durch Empfehlungen.',
    'old_password': 'Aktuelles Passwort',
    'new_password': 'Neues Passwort',
    'confirm_password': 'Neues Passwort bestätigen',
    'update_password_btn': 'Passwort aktualisieren',
    'passwords_not_match': 'Passwörter stimmen nicht überein',
    'password_changed_success': 'Passwort erfolgreich aktualisiert!',
    'or': 'ODER',
    'sign_in_google': 'Mit Google anmelden',
    'sign_up_google': 'Mit Google registrieren',
  };

}
