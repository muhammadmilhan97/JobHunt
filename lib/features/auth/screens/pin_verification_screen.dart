import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/pin_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/widgets/app_logo.dart';

class PinVerificationScreen extends ConsumerStatefulWidget {
  final String? nextRoute;

  const PinVerificationScreen({super.key, this.nextRoute});

  @override
  ConsumerState<PinVerificationScreen> createState() =>
      _PinVerificationScreenState();
}

class _PinVerificationScreenState extends ConsumerState<PinVerificationScreen> {
  final List<String> _pin = ['', '', '', ''];
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _showPin = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: Scaffold(
        appBar: BrandedAppBar(
          title: 'Enter PIN',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showExitConfirmation(context),
          ),
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  24.0,
                  24.0,
                  24.0 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Logo
                      const Center(child: AppLogo.large()),

                      const SizedBox(height: 40),

                      // Welcome message
                      Text(
                        'Welcome Back!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Enter your 4-digit PIN to access your account',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // PIN input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: TextFormField(
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              obscureText: !_showPin,
                              maxLength: 1,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: pinState.error != null
                                        ? Colors.red
                                        : theme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: pinState.error != null
                                        ? Colors.red
                                        : theme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                              ),
                              onChanged: (value) => _onPinChanged(index, value),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Show/Hide PIN toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _showPin,
                            onChanged: (value) {
                              setState(() {
                                _showPin = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Show PIN',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Error message and attempts
                      if (pinState.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pinState.error!,
                                      style:
                                          TextStyle(color: Colors.red.shade600),
                                    ),
                                  ),
                                ],
                              ),
                              if (pinState.remainingAttempts > 0) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: pinState.remainingAttempts / 5,
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    pinState.remainingAttempts > 2
                                        ? Colors.green
                                        : pinState.remainingAttempts > 1
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPinComplete() &&
                                  !pinState.isLoading &&
                                  pinState.remainingAttempts > 0
                              ? _verifyPin
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: pinState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Verify PIN'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot PIN option
                      TextButton(
                        onPressed: pinState.remainingAttempts <= 0
                            ? null
                            : _showForgotPinDialog,
                        child: const Text('Forgot PIN?'),
                      ),

                      const SizedBox(height: 20),

                      // Security info
                      if (pinState.remainingAttempts <= 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.lock,
                                  color: Colors.red.shade600, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Account Locked',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Too many failed attempts. Please sign out and sign in again to reset your PIN attempts.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: theme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Enter your PIN to access your JobHunt account securely.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ); // End PopScope
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text(
          'You need to enter your PIN to access your account. '
          'Do you want to sign out instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _onPinChanged(int index, String value) {
    // Clear error when user starts typing
    if (value.isNotEmpty) {
      ref.read(pinProvider.notifier).clearError();
    }

    setState(() {
      _pin[index] = value;
    });

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when PIN is complete
    if (_isPinComplete()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isPinComplete()) {
          _verifyPin();
        }
      });
    }
  }

  bool _isPinComplete() {
    return _pin.every((digit) => digit.isNotEmpty);
  }

  Future<void> _verifyPin() async {
    final pinString = _pin.join();
    final success = await ref.read(pinProvider.notifier).verifyPin(pinString);

    if (success && mounted) {
      // Navigate to appropriate route
      final nextRoute = widget.nextRoute;
      if (nextRoute != null) {
        context.go(nextRoute);
      } else {
        // Default navigation based on user role could be implemented here
        context.go('/seeker/home');
      }
    } else {
      // Clear PIN fields on failure
      setState(() {
        _pin.fillRange(0, 4, '');
      });
      _focusNodes[0].requestFocus();
    }
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'If you forgot your PIN, you need to sign out and sign in again. '
          'You will then be prompted to set up a new PIN.\n\n'
          'This is a security measure to protect your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
