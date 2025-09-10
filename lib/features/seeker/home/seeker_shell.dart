import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeekerShell extends StatefulWidget {
  final Widget child;
  const SeekerShell({super.key, required this.child});

  @override
  State<SeekerShell> createState() => _SeekerShellState();
}

class _SeekerShellState extends State<SeekerShell> {
  int _index = 0;

  void _onTap(int i) {
    setState(() => _index = i);
    switch (i) {
      case 0:
        context.go('/seeker/home');
        break;
      case 1:
        context.go('/seeker/favorites');
        break;
      case 2:
        context.go('/seeker/applications');
        break;
      case 3:
        context.go('/seeker/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined), 
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border), 
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined), 
            selectedIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline), 
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
