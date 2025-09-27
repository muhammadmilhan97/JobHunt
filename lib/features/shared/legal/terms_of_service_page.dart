import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/utils/back_button_handler.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler.createPopScope(
      context: context,
      child: Scaffold(
        appBar: BrandedAppBar(
          title: 'Terms of Service',
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
                'Terms of Service',
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
                '1. Acceptance of Terms',
                [
                  'By accessing and using JobHunt, you accept and agree to be bound by the terms and provision of this agreement.',
                  'If you do not agree to abide by the above, please do not use this service.',
                  'These terms apply to all users of the service, including job seekers, employers, and administrators.',
                ],
              ),
              _buildSection(
                context,
                '2. Description of Service',
                [
                  'JobHunt is a job search and recruitment platform that connects job seekers with employers.',
                  'We provide tools for job posting, application management, and candidate screening.',
                  'Our service includes mobile applications, web platforms, and related services.',
                  'We reserve the right to modify or discontinue the service at any time.',
                ],
              ),
              _buildSection(
                context,
                '3. User Accounts',
                [
                  'You must create an account to use certain features of our service.',
                  'You are responsible for maintaining the confidentiality of your account credentials.',
                  'You must provide accurate and complete information when creating your account.',
                  'You are responsible for all activities that occur under your account.',
                  'You must notify us immediately of any unauthorized use of your account.',
                ],
              ),
              _buildSection(
                context,
                '4. User Responsibilities',
                [
                  'You must be at least 18 years old to use our service.',
                  'You agree to use the service only for lawful purposes.',
                  'You will not post false, misleading, or fraudulent information.',
                  'You will not harass, abuse, or harm other users.',
                  'You will not attempt to gain unauthorized access to our systems.',
                  'You will not use the service to violate any applicable laws or regulations.',
                ],
              ),
              _buildSection(
                context,
                '5. Job Postings and Applications',
                [
                  'Employers are responsible for the accuracy of job postings.',
                  'Job seekers are responsible for the accuracy of their applications and resumes.',
                  'We do not guarantee the availability of any job or the hiring of any candidate.',
                  'We are not responsible for the hiring decisions of employers.',
                  'All job postings must comply with applicable employment laws.',
                ],
              ),
              _buildSection(
                context,
                '6. Content and Intellectual Property',
                [
                  'You retain ownership of content you post on our platform.',
                  'By posting content, you grant us a license to use, display, and distribute it.',
                  'You represent that you have the right to post any content you submit.',
                  'We respect intellectual property rights and expect users to do the same.',
                  'We may remove content that violates these terms or applicable laws.',
                ],
              ),
              _buildSection(
                context,
                '7. Privacy and Data Protection',
                [
                  'Your privacy is important to us. Please review our Privacy Policy.',
                  'We collect and process personal data in accordance with applicable laws.',
                  'You have certain rights regarding your personal data.',
                  'We implement appropriate security measures to protect your information.',
                ],
              ),
              _buildSection(
                context,
                '8. Prohibited Activities',
                [
                  'Posting discriminatory job advertisements',
                  'Sharing false or misleading information',
                  'Spamming or sending unsolicited communications',
                  'Attempting to circumvent our security measures',
                  'Using automated tools to access our service without permission',
                  'Violating any applicable laws or regulations',
                ],
              ),
              _buildSection(
                context,
                '9. Termination',
                [
                  'We may terminate or suspend your account at any time for violations of these terms.',
                  'You may terminate your account at any time.',
                  'Upon termination, your right to use the service will cease immediately.',
                  'We may retain certain information as required by law or for legitimate business purposes.',
                ],
              ),
              _buildSection(
                context,
                '10. Disclaimers and Limitations',
                [
                  'Our service is provided "as is" without warranties of any kind.',
                  'We do not guarantee the accuracy, completeness, or reliability of any information.',
                  'We are not liable for any damages arising from your use of the service.',
                  'Our liability is limited to the maximum extent permitted by law.',
                ],
              ),
              _buildSection(
                context,
                '11. Indemnification',
                [
                  'You agree to indemnify and hold us harmless from any claims arising from your use of the service.',
                  'This includes claims related to your content, violations of these terms, or infringement of third-party rights.',
                ],
              ),
              _buildSection(
                context,
                '12. Dispute Resolution',
                [
                  'Any disputes arising from these terms will be resolved through binding arbitration.',
                  'You waive your right to participate in class action lawsuits.',
                  'These terms are governed by the laws of [Your Jurisdiction].',
                ],
              ),
              _buildSection(
                context,
                '13. Changes to Terms',
                [
                  'We may update these terms from time to time.',
                  'We will notify users of significant changes through the app or email.',
                  'Your continued use of the service constitutes acceptance of the updated terms.',
                ],
              ),
              _buildSection(
                context,
                '14. Contact Information',
                [
                  'If you have questions about these terms, please contact us at:',
                  'Email: legal@jobhunt.com',
                  'Address: JobHunt Legal Team, [Your Company Address]',
                  'We will respond to your inquiry within 30 days.',
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
                        'Important Notice',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By using JobHunt, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
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
