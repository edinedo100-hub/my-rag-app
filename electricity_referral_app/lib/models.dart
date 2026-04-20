import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String? referredBy;
  final String referralCode;
  final DateTime createdAt;
  final double balance;
  final int lastResetMonth;
  final bool notificationsEnabled;
  final bool welcomeSent; // New field to track welcome message

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    this.referredBy,
    required this.referralCode,
    required this.createdAt,
    this.balance = 0.0,
    this.lastResetMonth = 0,
    this.notificationsEnabled = true,
    this.welcomeSent = false, // Default to false
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
        (doc.data() as Map<String, dynamic>?) ?? {};

    String email = data['email']?.toString() ?? '';
    String dName =
        data['displayName']?.toString() ??
        (email.isNotEmpty ? email.split('@')[0] : 'User');

    DateTime created;
    try {
      final dynamic rawDate = data['createdAt'];
      if (rawDate != null && rawDate is Timestamp) {
        created = rawDate.toDate();
      } else {
        created = DateTime.now();
      }
    } catch (_) {
      created = DateTime.now();
    }

    return UserProfile(
      userId: doc.id,
      email: email,
      displayName: dName,
      referredBy: data['referredBy']?.toString(),
      referralCode: data['referralCode']?.toString() ?? '',
      createdAt: created,
      balance: (data['balance'] ?? 0.0).toDouble(),
      lastResetMonth: data['lastResetMonth'] ?? 0,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      welcomeSent: data['welcomeSent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'referredBy': referredBy,
      'referralCode': referralCode,
      'createdAt': FieldValue.serverTimestamp(),
      'balance': balance,
      'lastResetMonth': lastResetMonth,
      'notificationsEnabled': notificationsEnabled,
      'welcomeSent': welcomeSent,
    };
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
        (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime time;
    try {
      final dynamic rawDate = data['timestamp'];
      if (rawDate != null && rawDate is Timestamp) {
        time = rawDate.toDate();
      } else {
        time = DateTime.now();
      }
    } catch (_) {
      time = DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      timestamp: time,
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class BillUpload {
  final String uploadId;
  final String userId;
  final String fileUrl;
  final String status;
  final DateTime timestamp;
  final String fileName;
  final String extension;

  BillUpload({
    required this.uploadId,
    required this.userId,
    required this.fileUrl,
    required this.status,
    required this.timestamp,
    this.fileName = '',
    this.extension = '',
  });

  factory BillUpload.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
        (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime time;
    try {
      final dynamic rawDate = data['timestamp'];
      if (rawDate != null && rawDate is Timestamp) {
        time = rawDate.toDate();
      } else {
        time = DateTime.now();
      }
    } catch (_) {
      time = DateTime.now();
    }

    return BillUpload(
      uploadId: doc.id,
      userId: data['userId']?.toString() ?? '',
      fileUrl: data['fileUrl']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Pending',
      timestamp: time,
      fileName: data['fileName']?.toString() ?? '',
      extension: data['extension']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileUrl': fileUrl,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'fileName': fileName,
      'extension': extension,
    };
  }
}
