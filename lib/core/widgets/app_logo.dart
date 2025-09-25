import 'package:flutter/material.dart';

/// A reusable widget for displaying the JobHunt logo
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showText;
  final TextStyle? textStyle;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.showText = false,
    this.textStyle,
  });

  /// Small logo for app bars and compact spaces
  const AppLogo.small({
    super.key,
    this.fit = BoxFit.contain,
    this.showText = false,
    this.textStyle,
  })  : width = 40,
        height = 40;

  /// Medium logo for cards and sections
  const AppLogo.medium({
    super.key,
    this.fit = BoxFit.contain,
    this.showText = false,
    this.textStyle,
  })  : width = 80,
        height = 80;

  /// Large logo for splash screens and main branding
  const AppLogo.large({
    super.key,
    this.fit = BoxFit.contain,
    this.showText = false,
    this.textStyle,
  })  : width = 140,
        height = 140;

  /// Extra large logo for onboarding and welcome screens
  const AppLogo.extraLarge({
    super.key,
    this.fit = BoxFit.contain,
    this.showText = false,
    this.textStyle,
  })  : width = 240,
        height = 240;

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoImage(),
          const SizedBox(height: 8),
          Text(
            'JobHunt',
            style: textStyle ??
                Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
          ),
        ],
      );
    }

    return _buildLogoImage();
  }

  Widget _buildLogoImage() {
    return Image.asset(
      'assets/JobHunt Logo.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to an icon if logo fails to load
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.work,
            size: (width ?? 32) * 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

/// A branded app bar that includes the app logo
class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final bool showLogo;
  final PreferredSizeWidget? bottom;

  const BrandedAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.showLogo = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo.small(),
                if (title != null) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      title!,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            )
          : title != null
              ? Flexible(
                  child: Text(
                    title!,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      actions: actions,
      leading: leading,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// A splash screen widget with the app logo and loading animation
class LogoSplashWidget extends StatefulWidget {
  final String? subtitle;
  final Widget? child;
  final bool showLoading;

  const LogoSplashWidget({
    super.key,
    this.subtitle,
    this.child,
    this.showLoading = true,
  });

  @override
  State<LogoSplashWidget> createState() => _LogoSplashWidgetState();
}

class _LogoSplashWidgetState extends State<LogoSplashWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo.extraLarge(
                      showText: false,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        widget.subtitle!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (widget.showLoading) ...[
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    if (widget.child != null) ...[
                      const SizedBox(height: 48),
                      widget.child!,
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
