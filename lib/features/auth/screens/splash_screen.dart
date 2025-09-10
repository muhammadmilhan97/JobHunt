import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/providers/pin_providers.dart';
import '../../../core/services/firebase_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is already authenticated
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Not authenticated, go to auth
      context.go('/auth');
      return;
    }

    try {
      // User is authenticated, check their role and PIN status
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist, go to role selection
        context.go('/role');
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String?;

      if (role == null) {
        // No role set, go to role selection
        context.go('/role');
        return;
      }

      // Initialize PIN state
      await ref.read(pinProvider.notifier).initialize();
      final pinState = ref.read(pinProvider);

      // Determine target route based on role
      String targetRoute;
      switch (role) {
        case 'job_seeker':
          targetRoute = '/seeker/home';
          break;
        case 'employer':
          targetRoute = '/employer/dashboard';
          break;
        case 'admin':
          targetRoute = '/admin/panel';
          break;
        default:
          targetRoute = '/seeker/home';
      }

      // Navigate based on PIN status
      if (!pinState.isSet) {
        // PIN not set, go to PIN setup
        context.go('/auth/pin-setup?next=${Uri.encodeComponent(targetRoute)}');
      } else if (!pinState.isVerified) {
        // PIN set but not verified, go to PIN verification
        context.go(
            '/auth/pin-verification?next=${Uri.encodeComponent(targetRoute)}');
      } else {
        // PIN verified, go to target route
        context.go(targetRoute);
      }
    } catch (e) {
      // Error occurred, go to auth
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: LogoSplashWidget(
        subtitle: 'Find Your Dream Job',
      ),
    );
  }
}
