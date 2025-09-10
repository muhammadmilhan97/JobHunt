import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the role the user intends to continue as before authentication
/// Possible values: 'job_seeker' | 'employer' | 'admin'
final intendedRoleProvider = StateProvider<String?>((ref) => null);
