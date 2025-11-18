import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Help & FAQ',
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
            _buildSection(
              'Frequently Asked Questions',
              [
                _buildFAQItem(
                  'How do I report a power outage?',
                  'To report a power outage, tap the "Report Outage" button on the home screen. Fill in the required information including location, description, and optionally add photos. Submit the report and we will process it.',
                ),
                _buildFAQItem(
                  'How can I track my report status?',
                  'You can track your report status by going to Profile > My Reports. Each report shows its current status: Pending, Verified, or Resolved.',
                ),
                _buildFAQItem(
                  'What do the different status colors mean?',
                  'Red indicates active power outages, Amber shows scheduled maintenance, and Green means normal power service is restored.',
                ),
                _buildFAQItem(
                  'How do I enable notifications?',
                  'Go to Profile > Notification Settings to enable push notifications for power status updates and report status changes.',
                ),
                _buildFAQItem(
                  'Can I report anonymously?',
                  'No, you need to be logged in to submit reports. This helps us follow up if we need more information.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Troubleshooting',
              [
                _buildHelpItem(
                  'App not loading properly',
                  'Try these steps:\n1. Check your internet connection\n2. Force close and restart the app\n3. Clear app cache\n4. Update to the latest version',
                ),
                _buildHelpItem(
                  'Can\'t submit reports',
                  'Make sure:\n1. You\'re logged into your account\n2. Location permissions are enabled\n3. All required fields are filled\n4. You have stable internet connection',
                ),
                _buildHelpItem(
                  'Notifications not working',
                  'Check:\n1. App has notification permissions\n2. Do Not Disturb is off\n3. App notifications are enabled in phone settings\n4. App is updated to latest version',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Support',
              [
                _buildContactItem(
                  Icons.email,
                  'Email Support',
                  'support@powernotify.com',
                  () {
                    // Handle email tap
                  },
                ),
                _buildContactItem(
                  Icons.phone,
                  'Hotline',
                  '1-800-POWER-UP',
                  () {
                    // Handle phone tap
                  },
                ),
                _buildContactItem(
                  Icons.message,
                  'Live Chat',
                  'Available 24/7',
                  () {
                    // Handle chat tap
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'App Guide',
              [
                _buildGuideItem(
                  'Getting Started',
                  'Learn the basics of PowerNotify and how to make the most of its features.',
                ),
                _buildGuideItem(
                  'Reporting Guide',
                  'Step-by-step instructions for reporting power issues effectively.',
                ),
                _buildGuideItem(
                  'Map Features',
                  'How to use the interactive map to track outages in your area.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Bold',
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Medium',
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Regular',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(String title, String steps) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Medium',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            steps,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Regular',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Medium',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return InkWell(
      onTap: () {
        // Handle guide item tap
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.book_outlined,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Medium',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
