import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/utils/back_button_handler.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler.createPopScope(
      context: context,
      child: Scaffold(
        appBar: BrandedAppBar(
          title: 'Privacy Policy',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                '1. Information We Collect',
                [
                  'Personal Information: We collect information you provide directly to us, such as when you create an account, apply for jobs, or post job listings. This may include your name, email address, phone number, resume, and professional information.',
                  'Usage Information: We automatically collect information about how you use our app, including job searches, applications submitted, and interactions with our platform.',
                  'Device Information: We collect information about your device, including device type, operating system, and unique device identifiers.',
                ],
              ),
              _buildSection(
                context,
                '2. How We Use Your Information',
                [
                  'To provide and maintain our job search and recruitment services',
                  'To match job seekers with relevant job opportunities',
                  'To enable employers to post jobs and review applications',
                  'To send you notifications about job opportunities and application updates',
                  'To improve our services and develop new features',
                  'To communicate with you about our services',
                ],
              ),
              _buildSection(
                context,
                '3. Information Sharing',
                [
                  'We share your information with employers when you apply for jobs through our platform',
                  'We may share aggregated, non-personal information with third parties for analytics and improvement purposes',
                  'We do not sell your personal information to third parties',
                  'We may share information if required by law or to protect our rights and safety',
                ],
              ),
              _buildSection(
                context,
                '4. Data Security',
                [
                  'We implement appropriate security measures to protect your personal information',
                  'We use encryption to secure data transmission',
                  'We regularly update our security practices to address new threats',
                  'However, no method of transmission over the internet is 100% secure',
                ],
              ),
              _buildSection(
                context,
                '5. Your Rights',
                [
                  'You can access and update your personal information at any time',
                  'You can delete your account and associated data',
                  'You can opt out of marketing communications',
                  'You can request a copy of your data',
                  'You can withdraw consent for data processing where applicable',
                ],
              ),
              _buildSection(
                context,
                '6. Data Retention',
                [
                  'We retain your information for as long as your account is active',
                  'We may retain certain information for legitimate business purposes',
                  'You can request deletion of your data at any time',
                  'Some information may be retained for legal compliance purposes',
                ],
              ),
              _buildSection(
                context,
                '7. Cookies and Tracking',
                [
                  'We use cookies and similar technologies to improve your experience',
                  'You can control cookie settings through your device preferences',
                  'We use analytics to understand app usage and improve our services',
                ],
              ),
              _buildSection(
                context,
                '8. Third-Party Services',
                [
                  'We may integrate with third-party services for authentication, payments, and analytics',
                  'These services have their own privacy policies',
                  'We are not responsible for the privacy practices of third-party services',
                ],
              ),
              _buildSection(
                context,
                '9. Children\'s Privacy',
                [
                  'Our service is not intended for children under 13 years of age',
                  'We do not knowingly collect personal information from children under 13',
                  'If we become aware that we have collected such information, we will delete it immediately',
                ],
              ),
              _buildSection(
                context,
                '10. Changes to This Policy',
                [
                  'We may update this privacy policy from time to time',
                  'We will notify you of significant changes through the app or email',
                  'Your continued use of the service constitutes acceptance of the updated policy',
                ],
              ),
              _buildSection(
                context,
                '11. Contact Us',
                [
                  'If you have questions about this privacy policy, please contact us at:',
                  'Email: privacy@jobhunt.com',
                  'Address: JobHunt Privacy Team, [Your Company Address]',
                  'We will respond to your inquiry within 30 days',
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy Matters',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We are committed to protecting your privacy and ensuring the security of your personal information. This privacy policy explains how we collect, use, and protect your data when you use JobHunt.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}
