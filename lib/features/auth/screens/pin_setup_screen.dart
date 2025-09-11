import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/pin_providers.dart';
import '../../../core/widgets/app_logo.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  final String? nextRoute;

  const PinSetupScreen({super.key, this.nextRoute});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<String> _pin = ['', '', '', ''];
  final List<String> _confirmPin = ['', '', '', ''];
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<FocusNode> _confirmFocusNodes =
      List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _pinControllers =
      List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmControllers =
      List.generate(4, (index) => TextEditingController());

  bool _isConfirmMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final node in _confirmFocusNodes) {
      node.dispose();
    }
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final c in _confirmControllers) {
      c.dispose();
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
        _handleBackButton(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Up PIN'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackButton(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24.0,
              24.0,
              24.0,
              24.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                const Center(child: AppLogo.large()),

                const SizedBox(height: 40),

                // Title and description
                Text(
                  _isConfirmMode ? 'Confirm Your PIN' : 'Create Your PIN',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  _isConfirmMode
                      ? 'Please re-enter your 4-digit PIN to confirm'
                      : 'Create a 4-digit PIN to secure your account',
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
                        key: ValueKey(
                            '${_isConfirmMode ? 'confirm' : 'pin'}-$index'),
                        focusNode: _isConfirmMode
                            ? _confirmFocusNodes[index]
                            : _focusNodes[index],
                        controller: _isConfirmMode
                            ? _confirmControllers[index]
                            : _pinControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 1,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onPinChanged(index, value),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Error message
                if (_errorMessage != null || pinState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage ?? pinState.error ?? '',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                if (_isConfirmMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goBack,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isConfirmPinComplete() && !pinState.isLoading
                                  ? () => _confirmPinEntry()
                                  : null,
                          child: pinState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPinComplete() ? _proceedToConfirm : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Security notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security,
                              color: theme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Security Notice',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Your PIN is encrypted and stored securely on your device\n'
                        '• You will need to enter this PIN each time you open the app\n'
                        '• Keep your PIN confidential and don\'t share it with anyone',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ); // End PopScope
  }

  void _handleBackButton(BuildContext context) {
    if (_isConfirmMode) {
      // If in confirm mode, go back to PIN entry
      _goBack();
    } else {
      // If in PIN entry mode, show exit confirmation
      _showExitConfirmation(context);
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit PIN Setup?'),
        content: const Text(
          'You need to set up a PIN to access your account. '
          'Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth'); // Go back to login
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _onPinChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    if (_isConfirmMode) {
      _confirmPin[index] = value;
      if (value.isNotEmpty && index < 3) {
        _confirmFocusNodes[index + 1].requestFocus();
      } else if (value.isEmpty && index > 0) {
        _confirmFocusNodes[index - 1].requestFocus();
      }
    } else {
      _pin[index] = value;
      if (value.isNotEmpty && index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else if (value.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  bool _isPinComplete() {
    return _pin.every((digit) => digit.isNotEmpty);
  }

  bool _isConfirmPinComplete() {
    return _confirmPin.every((digit) => digit.isNotEmpty);
  }

  void _proceedToConfirm() {
    final pinString = _pin.join();
    if (pinString.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pinString)) {
      setState(() {
        _errorMessage = 'PIN must be exactly 4 digits';
      });
      return;
    }

    setState(() {
      _isConfirmMode = true;
      _errorMessage = null;
      // Clear confirm state and inputs for a fresh re-entry
      for (var i = 0; i < 4; i++) {
        _confirmPin[i] = '';
        _confirmControllers[i].text = '';
      }
    });

    // Focus first confirm field
    Future.delayed(const Duration(milliseconds: 100), () {
      _confirmFocusNodes[0].requestFocus();
    });
  }

  void _goBack() {
    setState(() {
      _isConfirmMode = false;
      _confirmPin.fillRange(0, 4, '');
      _errorMessage = null;
    });

    // Focus last pin field
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes[3].requestFocus();
    });
  }

  Future<void> _confirmPinEntry() async {
    final pinString = _pin.join();
    final confirmPinString = _confirmPin.join();

    if (pinString != confirmPinString) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
      });
      return;
    }

    final success = await ref.read(pinProvider.notifier).setPin(pinString);

    if (success) {
      if (mounted) {
        // Navigate to next route or dashboard
        final nextRoute = widget.nextRoute;
        if (nextRoute != null) {
          context.go(nextRoute);
        } else {
          context.go('/seeker/home'); // Default route
        }
      }
    }
  }
}
