import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Bold',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'PowerNotify is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              '• **Personal Information**: Name, email address, phone number\n• **Location Data**: GPS coordinates, address information\n• **Device Information**: Device type, operating system, unique device identifiers\n• **Usage Data**: Features used, time spent, interaction patterns\n• **Report Data**: Power outage reports, photos, descriptions\n• **Communications**: Support requests, feedback, and correspondence',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'How We Collect Information',
              '• **Direct Collection**: Information you provide when registering, reporting outages, or contacting support\n• **Automatic Collection**: Data collected automatically through app usage\n• **Third-Party Sources**: Information from integrated services (maps, weather, etc.)\n• **Cookies and Tracking**: Technologies that enhance your app experience',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'How We Use Your Information',
              '• **Service Provision**: To provide and maintain our power outage tracking service\n• **Communication**: To send notifications, updates, and respond to inquiries\n• **Improvement**: To analyze usage patterns and improve our services\n• **Safety**: To ensure the safety and security of our users and community\n• **Legal Compliance**: To comply with legal obligations and protect our rights',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information Sharing',
              'We may share your information with:\n• **Service Providers**: Third parties who help operate our service\n• **Utility Companies**: To coordinate power restoration efforts\n• **Government Agencies**: When required by law or for public safety\n• **Aggregated Data**: Anonymized data for research and analytics\n\nWe never sell your personal information to third parties for marketing purposes.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your information:\n• **Encryption**: Data is encrypted in transit and at rest\n• **Access Controls**: Limited access to authorized personnel only\n• **Regular Audits**: Security assessments and vulnerability testing\n• **Secure Infrastructure**: Use of industry-standard security practices',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Retention',
              'We retain your information only as long as necessary:\n• **Account Information**: Until you delete your account\n• **Report Data**: For historical analysis and service improvement\n• **Legal Requirements**: As required by applicable laws\n• **User Requests**: When you request data deletion, subject to legal obligations',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Your Rights',
              'You have the right to:\n• **Access**: Request a copy of your personal information\n• **Correction**: Update or correct inaccurate information\n• **Deletion**: Request deletion of your personal information\n• **Portability**: Request transfer of your data to another service\n• **Objection**: Object to certain uses of your information\n• **Restriction**: Limit how we process your information',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Location Data',
              'PowerNotify uses location data to:\n• **Provide Accurate Reports**: Pinpoint outage locations\n• **Show Relevant Information**: Display local power status\n• **Improve Service**: Analyze geographic patterns\n\nLocation data is collected only with your explicit consent and can be disabled in app settings.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Children\'s Privacy',
              'Our service is not intended for children under 13. We do not knowingly collect personal information from children under 13. If we become aware of such collection, we will take immediate steps to delete the information.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Third-Party Services',
              'PowerNotify integrates with third-party services:\n• **Firebase**: For data storage and authentication\n• **Map Services**: For location visualization\n• **Notification Services**: For push notifications\n\nThese services have their own privacy policies and data handling practices.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'International Data Transfers',
              'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your information in accordance with applicable data protection laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by:\n• Posting the new policy in the app\n• Sending email notifications\n• In-app notifications\n\nYour continued use of the service after any changes constitutes acceptance of the updated policy.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy or our data practices, please contact us:\n\n**Email**: privacy@powernotify.com\n**Phone**: 1-800-POWER-UP\n**Address**: 123 Power Street, Energy City, EC 12345\n\nWe will respond to your inquiry within 30 days.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Effective Date',
              'This Privacy Policy is effective as of November 18, 2024, and will remain in effect except as amended in accordance with this policy.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'Last Updated: November 18, 2024',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Medium',
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bold',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Regular',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
