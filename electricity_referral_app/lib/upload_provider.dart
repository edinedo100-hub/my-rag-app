import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class UploadProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Initialize storage without passing bucket manually, but with careful instantiation
  late final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isUploading = false;
  List<BillUpload> _uploads = [];

  bool get isUploading => _isUploading;
  List<BillUpload> get uploads => _uploads;

  Future<String?> pickAndUploadBill(String userId) async {
    _isUploading = true;
    notifyListeners();

    try {
      debugPrint('WATTWISE INFO: Preparing for file selection...');

      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true, // Crucial for Web
      ).timeout(const Duration(seconds: 45));

      if (result == null || result.files.isEmpty) {
        debugPrint('WATTWISE INFO: Selection cancelled.');
        _isUploading = false;
        notifyListeners();
        return 'Selection cancelled';
      }

      final file = result.files.first;
      String extension = file.extension?.toLowerCase() ?? '';

      if (!['pdf', 'jpg', 'png', 'jpeg'].contains(extension)) {
        _isUploading = false;
        notifyListeners();
        return 'Error: Only PDF, JPG, and PNG formats are allowed.';
      }

      Uint8List? bytes = file.bytes;
      if (bytes == null) {
        _isUploading = false;
        notifyListeners();
        return 'Error: Could not read file data. Try another file.';
      }

      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId.substring(0, 5)}.$extension';
      Reference ref = _storage.ref().child('bills/$userId/$fileName');

      String contentType = 'application/octet-stream';
      if (extension == 'pdf') {
        contentType = 'application/pdf';
      } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
        contentType = 'image/$extension';
      }

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'userId': userId,
          'originalName': file.name,
          'uploadDate': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
        'WATTWISE INFO: Uploading ${file.name} (${(file.size / 1024).toStringAsFixed(2)} KB)',
      );

      // Start the task
      final uploadTask = ref.putData(bytes, metadata);

      // Monitor completion with a clear timeout and error handling
      final snapshot = await uploadTask
          .then((snapshot) {
            debugPrint('WATTWISE INFO: Network transfer complete.');
            return snapshot;
          })
          .catchError((error) {
            debugPrint('WATTWISE NETWORK ERROR: $error');
            throw error;
          })
          .timeout(const Duration(minutes: 3));

      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('WATTWISE INFO: Storage URL secured.');

      // Persist to database
      await _db
          .collection('uploads')
          .add({
            'uploadId': snapshot.ref.name,
            'userId': userId,
            'fileUrl': downloadUrl,
            'status': 'Pending',
            'timestamp': FieldValue.serverTimestamp(),
            'fileName': file.name,
            'extension': extension,
            'storagePath': ref.fullPath,
            'processed': false,
          })
          .timeout(const Duration(seconds: 20));

      debugPrint('WATTWISE SUCCESS: Transaction recorded in database.');

      _isUploading = false;
      await fetchUserUploads(userId);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('WATTWISE CRITICAL FAILURE: $e');
      _isUploading = false;
      notifyListeners();

      if (e.toString().contains('storage/unauthorized')) {
        return 'Permission Denied: Please check your storage settings.';
      } else if (e.toString().contains('timeout')) {
        return 'The connection timed out. Please try a smaller file or a faster network.';
      } else if (e.toString().contains('storage/canceled')) {
        return 'The upload was cancelled.';
      }
      return 'Upload failed: ${e.toString()}';
    } finally {
      if (_isUploading) {
        _isUploading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchUserUploads(String userId) async {
    try {
      final snapshot = await _db
          .collection('uploads')
          .where('userId', isEqualTo: userId)
          .get();

      _uploads = snapshot.docs
          .map((doc) => BillUpload.fromFirestore(doc))
          .toList();
      _uploads.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      debugPrint('WATTWISE ERROR (Fetch): $e');
    }
  }
}
