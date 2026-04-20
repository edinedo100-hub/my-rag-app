import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../upload_provider.dart';
import '../../referral_provider.dart';
import 'package:intl/intl.dart';

class UploadBillScreen extends StatefulWidget {
  const UploadBillScreen({super.key});

  @override
  State<UploadBillScreen> createState() => _UploadBillScreenState();
}

class _UploadBillScreenState extends State<UploadBillScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<UploadProvider>(
          context,
          listen: false,
        ).fetchUserUploads(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final uploadProvider = Provider.of<UploadProvider>(context);
    final user = authProvider.userProfile;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Provider.of<ReferralProvider>(
              context,
              listen: false,
            ).setTabIndex(0);
          },
        ),
        title: const Text('Electricity Bill Center'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUploadBox(context, uploadProvider, user.userId, theme),
            const SizedBox(height: 48),
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload History',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildUploadList(uploadProvider, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(
    BuildContext context,
    UploadProvider provider,
    String userId,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_rounded,
              size: 48,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Submit Monthly Bill',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PDF, JPG, or PNG formats only.\nMaximum file size: 10MB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: provider.isUploading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      String? error = await provider.pickAndUploadBill(userId);
                      if (!mounted) return;

                      if (error != null) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(error),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Bill uploaded successfully!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: provider.isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: Text(
                provider.isUploading
                    ? 'Transferring File...'
                    : 'Choose and Upload',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadList(UploadProvider provider, ThemeData theme) {
    if (provider.uploads.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              const Text(
                'No documents submitted yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.uploads.length,
      itemBuilder: (context, index) {
        final upload = provider.uploads[index];
        final bool isPdf = upload.extension.toLowerCase() == 'pdf';

        // Colour-code the status badge
        Color statusColor;
        IconData statusIcon;
        switch (upload.status.toLowerCase()) {
          case 'approved':
            statusColor = const Color(0xFF4CAF50);
            statusIcon = Icons.check_circle_outline_rounded;
            break;
          case 'rejected':
            statusColor = Colors.redAccent;
            statusIcon = Icons.cancel_outlined;
            break;
          default: // pending
            statusColor = Colors.orange;
            statusIcon = Icons.hourglass_top_rounded;
        }

        final displayName = upload.fileName.isNotEmpty
            ? upload.fileName
            : 'Document #${upload.uploadId.substring(0, 5)}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isPdf ? Colors.redAccent : Colors.blueAccent)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                color: isPdf ? Colors.redAccent : Colors.blueAccent,
                size: 24,
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateFormat('MMM d, yyyy • HH:mm').format(upload.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    upload.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
