import '../models/models.dart';

class SampleData {
  static List<Job> getSampleJobs() {
    return [
      Job(
        id: '1',
        title: 'Senior Flutter Developer',
        company: 'TechCorp Solutions',
        category: 'Software Development',
        locationCity: 'Karachi',
        locationCountry: 'Pakistan',
        salaryMin: 120000,
        salaryMax: 180000,
        type: 'Full-time',
        logoUrl: 'https://example.com/logo1.png',
        description:
            'We are looking for an experienced Flutter developer to join our growing team.',
        requirements: [
          '3+ years of Flutter development experience',
          'Strong knowledge of Dart programming language',
          'Experience with state management (Riverpod, Provider, BLoC)',
          'Familiarity with REST APIs and Firebase',
        ],
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        employerId: 'employer_1',
      ),
      Job(
        id: '2',
        title: 'Mobile App Developer',
        company: 'InnovateLab',
        category: 'Mobile Development',
        locationCity: 'Lahore',
        locationCountry: 'Pakistan',
        salaryMin: 80000,
        salaryMax: 120000,
        type: 'Full-time',
        description: 'Join our team to build cutting-edge mobile applications.',
        requirements: [
          '2+ years of mobile development experience',
          'Experience with Flutter or React Native',
          'Knowledge of mobile UI/UX principles',
        ],
        skills: ['Flutter', 'React Native', 'Mobile UI/UX', 'JavaScript'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        employerId: 'employer_2',
      ),
    ];
  }

  static List<UserProfile> getSampleUserProfiles() {
    return [
      UserProfile(
        id: '1',
        role: 'job_seeker',
        name: 'Ahmed Hassan',
        email: 'ahmed.hassan@example.com',
        cnic: '42101-1234567-8',
        city: 'Karachi',
        country: 'Pakistan',
        address: 'Block 15, Gulshan-e-Iqbal',
        experienceYears: 3,
        skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        expectedSalary: 150000,
      ),
      UserProfile(
        id: '2',
        role: 'employer',
        name: 'Sarah Khan',
        email: 'sarah.khan@techcorp.com',
        city: 'Lahore',
        country: 'Pakistan',
        skills: [],
        companyName: 'TechCorp Solutions',
      ),
    ];
  }

  static List<Application> getSampleApplications() {
    return [
      Application(
        id: '1',
        jobId: '1',
        jobSeekerId: '1',
        employerId: 'employer_1',
        status: 'pending',
        cvUrl:
            'https://res.cloudinary.com/dd09znqy6/raw/upload/v1234567890/jobhunt-dev/cv/sample_cv_1.pdf',
        coverLetter:
            'I am very interested in this position and believe my skills align well with your requirements.',
        expectedSalary: 150000,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Application(
        id: '2',
        jobId: '2',
        jobSeekerId: '1',
        employerId: 'employer_2',
        status: 'reviewed',
        cvUrl:
            'https://res.cloudinary.com/dd09znqy6/raw/upload/v1234567890/jobhunt-dev/cv/sample_cv_2.pdf',
        expectedSalary: 120000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Demonstrate JSON serialization
  static void demonstrateJsonSerialization() {
    final job = getSampleJobs().first;

    // Convert to JSON
    final jobJson = job.toJson();
    print('Job as JSON: $jobJson');

    // Convert back from JSON
    final jobFromJson = Job.fromJson(jobJson);
    print('Job from JSON: $jobFromJson');

    // They should be equal
    print('Are equal: ${job == jobFromJson}');
  }
}
