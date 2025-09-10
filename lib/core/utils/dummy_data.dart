import '../models/models.dart';

class DummyData {
  static List<Job> getAllJobs() {
    return [
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
            'We are looking for an experienced Flutter developer to join our growing team.',
        requirements: [
          '3+ years of Flutter development experience',
          'Strong knowledge of Dart programming language'
        ],
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        employerId: 'employer_1',
      ),
      Job(
        id: '2',
        title: 'DevOps Engineer',
        company: 'CloudTech Ltd',
        category: 'IT',
        locationCity: 'Lahore',
        locationCountry: 'Pakistan',
        salaryMin: 120000,
        salaryMax: 200000,
        type: 'Full-time',
        logoUrl: 'https://example.com/cloudtech.png',
        description:
            'Join our team as a DevOps Engineer and help us scale our infrastructure.',
        requirements: [
          '2+ years of DevOps experience',
          'Knowledge of AWS/Azure'
        ],
        skills: ['Docker', 'Kubernetes', 'AWS', 'CI/CD'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        employerId: 'employer_2',
      ),
      Job(
        id: '3',
        title: 'UI/UX Designer',
        company: 'DesignStudio Pro',
        category: 'Design',
        locationCity: 'Islamabad',
        locationCountry: 'Pakistan',
        salaryMin: 80000,
        salaryMax: 150000,
        type: 'Full-time',
        logoUrl: 'https://example.com/designstudio.png',
        description:
            'Create intuitive and beautiful user interfaces for web and mobile applications.',
        requirements: [
          '3+ years of UI/UX design experience',
          'Proficiency in Figma'
        ],
        skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        employerId: 'employer_3',
      ),
    ];
  }
}
