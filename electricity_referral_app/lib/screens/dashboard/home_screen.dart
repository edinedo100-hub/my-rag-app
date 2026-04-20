import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_tab.dart';
import 'referrals_screen.dart';
import 'upload_bill_screen.dart';
import 'profile_screen.dart';
import '../../language_provider.dart';
import '../../auth_provider.dart';
import '../../notification_provider.dart';
import '../../referral_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const DashboardTab(),
    const ReferralsScreen(),
    const UploadBillScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).fetchNotifications(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LanguageProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final referralProvider = Provider.of<ReferralProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: referralProvider.currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: referralProvider.currentTabIndex,
          onDestinationSelected: (index) => referralProvider.setTabIndex(index),
          backgroundColor: Colors.white,
          indicatorColor: theme.primaryColor.withValues(alpha: 0.1),
          height: 72,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard_outlined,
                color: theme.colorScheme.secondary.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                Icons.dashboard_rounded,
                color: theme.primaryColor,
              ),
              label: lang.translate('home'),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.group_outlined,
                color: theme.colorScheme.secondary.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                Icons.group_rounded,
                color: theme.primaryColor,
              ),
              label: lang.translate('referrals'),
            ),
            NavigationDestination(
              icon: Icon(
                Icons.upload_file_outlined,
                color: theme.colorScheme.secondary.withValues(alpha: 0.6),
              ),
              selectedIcon: Icon(
                Icons.upload_file_rounded,
                color: theme.primaryColor,
              ),
              label: 'Upload',
            ),
            NavigationDestination(
              icon: Badge(
                label: notificationProvider.unreadCount > 0
                    ? Text('${notificationProvider.unreadCount}')
                    : null,
                isLabelVisible: notificationProvider.unreadCount > 0,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              selectedIcon: Badge(
                label: notificationProvider.unreadCount > 0
                    ? Text('${notificationProvider.unreadCount}')
                    : null,
                isLabelVisible: notificationProvider.unreadCount > 0,
                child: Icon(Icons.person_rounded, color: theme.primaryColor),
              ),
              label: lang.translate('profile_tab'),
            ),
          ],
        ),
      ),
    );
  }
}
