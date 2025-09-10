import '../models/models.dart';
import '../services/firebase_service.dart';

/// Utility to migrate dummy data to Firestore
/// This is a one-time migration script for development
class MigrateDummyData {
  static Future<void> migrateDummyJobs() async {
    final jobs = _getDummyJobs();

    for (final job in jobs) {
      try {
        await FirebaseService.jobsCollection.doc(job.id).set(job.toFirestore());
        print('Migrated job: ${job.title}');
      } catch (e) {
        print('Failed to migrate job ${job.id}: $e');
      }
    }

    print('Migration completed: ${jobs.length} jobs migrated');
  }

  static List<Job> _getDummyJobs() {
    return [
      // IT Category - 4 jobs
      Job(
        id: '1',
        title: 'Senior Flutter Developer',
        company: 'TechCorp Solutions',
        category: 'IT',
        locationCity: 'Karachi',
        locationCountry: 'Pakistan',
        salaryMin: 150000,
        salaryMax: 250000,
        type: 'Full-time',
        logoUrl: 'https://example.com/techcorp.png',
        description:
            'We are looking for an experienced Flutter developer to join our growing team. You will be responsible for developing cross-platform mobile applications using Flutter framework.',
        requirements: [
          '3+ years of Flutter development experience',
          'Strong knowledge of Dart programming language',
          'Experience with state management (Riverpod, Provider, BLoC)',
          'Familiarity with REST APIs and Firebase',
          'Knowledge of Git version control'
        ],
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git', 'Riverpod'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        employerId: 'employer_1',
        isActive: true,
      ),
      Job(
        id: '2',
        title: 'Full Stack Developer',
        company: 'InnovateTech',
        category: 'IT',
        locationCity: 'Lahore',
        locationCountry: 'Pakistan',
        salaryMin: 120000,
        salaryMax: 200000,
        type: 'Full-time',
        logoUrl: 'https://example.com/innovatetech.png',
        description:
            'Join our dynamic team as a Full Stack Developer. You will work on both frontend and backend technologies to build scalable web applications.',
        requirements: [
          '2+ years of full stack development experience',
          'Proficiency in React.js and Node.js',
          'Experience with databases (MongoDB, PostgreSQL)',
          'Knowledge of cloud platforms (AWS, Google Cloud)',
          'Understanding of DevOps practices'
        ],
        skills: [
          'React.js',
          'Node.js',
          'MongoDB',
          'PostgreSQL',
          'AWS',
          'Docker'
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        employerId: 'employer_2',
        isActive: true,
      ),
      Job(
        id: '3',
        title: 'React Native Developer',
        company: 'MobileTech Labs',
        category: 'IT',
        locationCity: 'Islamabad',
        locationCountry: 'Pakistan',
        salaryMin: 100000,
        salaryMax: 180000,
        type: 'Full-time',
        logoUrl: 'https://example.com/mobiletech.png',
        description:
            'We are seeking a talented React Native developer to create amazing mobile experiences for our users across iOS and Android platforms.',
        requirements: [
          '2+ years of React Native development',
          'Strong JavaScript/TypeScript skills',
          'Experience with Redux or Context API',
          'Knowledge of native iOS/Android development is a plus',
          'Familiarity with mobile app deployment processes'
        ],
        skills: [
          'React Native',
          'JavaScript',
          'TypeScript',
          'Redux',
          'iOS',
          'Android'
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        employerId: 'employer_3',
        isActive: true,
      ),
      Job(
        id: '4',
        title: 'UI/UX Designer',
        company: 'DesignStudio Pro',
        category: 'Design',
        locationCity: 'Karachi',
        locationCountry: 'Pakistan',
        salaryMin: 80000,
        salaryMax: 150000,
        type: 'Full-time',
        logoUrl: 'https://example.com/designstudio.png',
        description:
            'Create intuitive and beautiful user interfaces for web and mobile applications. Work closely with development teams to bring designs to life.',
        requirements: [
          '3+ years of UI/UX design experience',
          'Proficiency in Figma, Adobe XD, or Sketch',
          'Strong portfolio demonstrating design skills',
          'Understanding of user-centered design principles',
          'Experience with prototyping and wireframing'
        ],
        skills: [
          'Figma',
          'Adobe XD',
          'Sketch',
          'Prototyping',
          'User Research',
          'Wireframing'
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        employerId: 'employer_4',
        isActive: true,
      ),
      Job(
        id: '5',
        title: 'Digital Marketing Specialist',
        company: 'GrowthMarketing Inc',
        category: 'Marketing',
        locationCity: 'Lahore',
        locationCountry: 'Pakistan',
        salaryMin: 60000,
        salaryMax: 120000,
        type: 'Full-time',
        logoUrl: 'https://example.com/growthmarketing.png',
        description:
            'Drive digital marketing campaigns across multiple channels to increase brand awareness and generate qualified leads for our business.',
        requirements: [
          '2+ years of digital marketing experience',
          'Experience with Google Ads and Facebook Ads',
          'Knowledge of SEO and content marketing',
          'Analytics skills (Google Analytics, etc.)',
          'Strong communication and creativity skills'
        ],
        skills: [
          'Google Ads',
          'Facebook Ads',
          'SEO',
          'Content Marketing',
          'Analytics',
          'Social Media'
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        employerId: 'employer_5',
        isActive: true,
      ),
    ];
  }
}
