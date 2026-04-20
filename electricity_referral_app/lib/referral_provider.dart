import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models.dart';

class ReferralProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<UserProfile> _referrals = [];
  bool _isLoading = false;
  int _currentTabIndex = 0; // Added tab tracking

  List<UserProfile> get referrals => _referrals;
  bool get isLoading => _isLoading;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchReferralsByCode(String referralCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find all users who were invited using this specific 5-char code
      QuerySnapshot snapshot = await _db
          .collection('users')
          .where('referredBy', isEqualTo: referralCode.toUpperCase().trim())
          .get();

      _referrals = snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching referrals: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String getReferralLink(String referralCode) {
    const String baseUrl = 'https://powerreferral-3bbe6.web.app/register';
    return '$baseUrl?ref=${referralCode.toUpperCase()}';
  }
}
