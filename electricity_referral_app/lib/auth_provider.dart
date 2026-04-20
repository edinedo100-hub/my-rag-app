import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeGoogleSignIn();
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _fetchUserProfile(user.uid);
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        clientId: '802826645391-placeholder.apps.googleusercontent.com',
      );
    } catch (e) {
      debugPrint('Google Sign-In Init Error: $e');
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        UserProfile profile = UserProfile.fromFirestore(doc);

        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // 1. Check for Billing Reset
        final DateTime now = DateTime.now();
        final int currentMonth = now.month;
        if (now.day >= 10 && profile.lastResetMonth != currentMonth) {
          updates['balance'] = 0.0;
          updates['lastResetMonth'] = currentMonth;
          needsUpdate = true;
          if (profile.notificationsEnabled) {
            await _createNotification(
              uid,
              'Monthly Reset',
              'Your referral balance has been reset for the new cycle.',
            );
          }
        }

        // 2. Check for Missing Referral Code
        if (profile.referralCode.isEmpty) {
          String newCode = _generateReferralCode();
          updates['referralCode'] = newCode;
          needsUpdate = true;
        }

        // 3. BACKFILL WELCOME MESSAGE FOR EXISTING USERS
        if (!profile.welcomeSent) {
          await _createNotification(
            uid,
            'Welcome to WattWise! ⚡',
            'We are excited to have you! Share your referral code to start earning rewards today.',
          );
          updates['welcomeSent'] = true; // Mark as sent
          needsUpdate = true;
        }

        if (needsUpdate) {
          await _db.collection('users').doc(uid).update(updates);
          doc = await _db.collection('users').doc(uid).get();
          profile = UserProfile.fromFirestore(doc);
        }

        _userProfile = profile;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<void> _createNotification(
    String uid,
    String title,
    String message,
  ) async {
    try {
      await _db.collection('users').doc(uid).collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (_userProfile == null) return;
    try {
      await _db.collection('users').doc(_userProfile!.userId).update({
        'notificationsEnabled': enabled,
      });
      _userProfile = UserProfile(
        userId: _userProfile!.userId,
        email: _userProfile!.email,
        displayName: _userProfile!.displayName,
        referredBy: _userProfile!.referredBy,
        referralCode: _userProfile!.referralCode,
        createdAt: _userProfile!.createdAt,
        balance: _userProfile!.balance,
        lastResetMonth: _userProfile!.lastResetMonth,
        notificationsEnabled: enabled,
        welcomeSent: _userProfile!.welcomeSent,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
    }
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<String?> register({
    required String email,
    required String password,
    required String displayName,
    String? referralCodeInput,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Credit the referrer with €10 if a valid code was provided.
      if (referralCodeInput != null && referralCodeInput.isNotEmpty) {
        await _applyReferralReward(referralCodeInput);
      }

      String myNewCode = _generateReferralCode();

      // Send Welcome Message for NEW users immediately
      await _createNotification(
        userCredential.user!.uid,
        'Welcome to WattWise! ⚡',
        'Start saving and earning by sharing your referral code with friends and family.',
      );

      UserProfile newUser = UserProfile(
        userId: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        referredBy: referralCodeInput?.toUpperCase().trim(),
        referralCode: myNewCode,
        createdAt: DateTime.now(),
        lastResetMonth: DateTime.now().month,
        welcomeSent: true, // Already sent for new user
      );

      await _db.collection('users').doc(newUser.userId).set(newUser.toMap());
      _userProfile = newUser;

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  /// Credits the referrer with €10 when a valid referral code is provided.
  /// Returns true if the referral was successfully applied.
  Future<bool> _applyReferralReward(String referralCode) async {
    try {
      final String code = referralCode.toUpperCase().trim();
      if (code.isEmpty) return false;

      QuerySnapshot referrerSearch = await _db
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      if (referrerSearch.docs.isEmpty) return false;

      final String referrerId = referrerSearch.docs.first.id;
      final DocumentSnapshot refDoc = referrerSearch.docs.first;
      final bool refNotifications = refDoc.get('notificationsEnabled') ?? true;

      await _db.collection('users').doc(referrerId).update({
        'balance': FieldValue.increment(10.0),
      });

      if (refNotifications) {
        await _createNotification(
          referrerId,
          'Referral Success! 🎉',
          'Someone used your referral code! €10.00 has been added to your wallet.',
        );
      }
      return true;
    } catch (e) {
      debugPrint('Warning: Referral reward error: $e');
      return false;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "No active session.";

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "An unexpected error occurred.";
    }
  }

  Future<String?> signInWithGoogle({String? referralCode}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Check if user profile exists
        DocumentSnapshot doc = await _db
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          // New user from Google — apply referral reward if a code was provided.
          final String? appliedCode = referralCode?.toUpperCase().trim();
          if (appliedCode != null && appliedCode.isNotEmpty) {
            await _applyReferralReward(appliedCode);
          }

          String myNewCode = _generateReferralCode();

          await _createNotification(
            user.uid,
            'Welcome to WattWise! ⚡',
            'Start saving and earning by sharing your referral code with friends and family.',
          );

          UserProfile newUser = UserProfile(
            userId: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "User",
            referredBy: appliedCode,
            referralCode: myNewCode,
            createdAt: DateTime.now(),
            lastResetMonth: DateTime.now().month,
            welcomeSent: true,
          );

          await _db
              .collection('users')
              .doc(newUser.userId)
              .set(newUser.toMap());
          _userProfile = newUser;
        }
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Google sign-in failed.";
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth SignOut Error: $e');
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google SignOut Error: $e');
    }
  }
}
