import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/prestige_theme.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();

    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
          final event = data.event;
          if (event == AuthChangeEvent.signedIn) {
            setState(() => _isLoading = true);
            final result = await widget.authService.syncOAuthUser();

            if (!mounted) return;

            if (result.success && result.session != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    username: result.session!.username,
                    puntos: result.session!.points,
                    authService: widget.authService,
                  ),
                ),
              );
            } else {
              setState(() {
                _isLoading = false;
                _error = result.error ?? 'Authentication failed';
              });
            }
          }
        });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkSavedSession() async {
    setState(() => _isLoading = true);

    final session = await widget.authService.checkSavedSession();
    if (session != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            username: session.username,
            puntos: session.points,
            authService: widget.authService,
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final username = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await widget.authService.login(
      username: username,
      password: password,
    );

    if (!mounted) {
      return;
    }

    if (result.success && result.session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            username: result.session!.username,
            puntos: result.session!.points,
            authService: widget.authService,
          ),
        ),
      );
      return;
    }

    setState(() {
      _error = result.error;
      _isLoading = false;
    });
  }

  Future<void> _goToRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(authService: widget.authService),
      ),
    );

    if (mounted) {
      _checkSavedSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          final content = Row(
            children: [
              if (isDesktop) const Expanded(flex: 5, child: _HeroPane()),
              Expanded(
                flex: isDesktop ? 5 : 10,
                child: Container(
                  color: PrestigeColors.surface,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 48 : 24,
                        vertical: isDesktop ? 32 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _LoginForm(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                error: _error,
                                obscurePassword: _obscurePassword,
                                onToggleObscure: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onSubmit: _login,
                                onGoToRegister: _goToRegister,
                                onGitHubLogin: () =>
                                    widget.authService.signInWithGitHub(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          if (isDesktop) {
            return content;
          }

          return Stack(
            children: [
              content,
              Positioned(
                top: -70,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: PrestigeColors.secondaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                left: -90,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: PrestigeColors.primaryContainer.withValues(
                        alpha: 0.07,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPane extends StatelessWidget {
  const _HeroPane();

  static const String _heroImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB35CLxFahV1r2Od6SiwzYTdeUkm9KzKCGX-kT1wZZd_sW7L-LEM-EHNy1SDWlcslvgFWbJG0Yo38b3AVPdoM8ojsJrbs0-LUp1nieOn7pudFVeQXdT23gkM-ZoVf3EYnKHdxaVoKIJjmJscqaN5clNs_-t_498BrDRteGyAx-GK-9XtoQgX2fMT6D8G1PZ9hvlPOH6_Tzs1TMgvRUqTtHIa6VVFCcWPCDOrHiXcqbDYJFRHGeTosvJjOkNm29wb8MuYpCSdFRxuw';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          _heroImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: PrestigeColors.primaryContainer),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromRGBO(13, 28, 50, 0.82),
                Color.fromRGBO(13, 28, 50, 0.0),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(52),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Curated Rewards.\nExclusively Yours.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 56,
                      height: 0.98,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Step back into a world where your loyalty is celebrated '
                    'with bespoke craftsmanship and premium experiences.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.error,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onGoToRegister,
    required this.onGitHubLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? error;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onGoToRegister;
  final VoidCallback onGitHubLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandHeader(),
          const SizedBox(height: 44),
          Text('Welcome Back', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Please enter your credentials to access your vault.',
            style: textTheme.bodyMedium?.copyWith(
              color: PrestigeColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          _FieldLabel(text: 'EMAIL ADDRESS'),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@prestige.com'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa el usuario';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: _FieldLabel(text: 'PASSWORD')),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: PrestigeColors.secondary,
                  textStyle: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: '........',
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: PrestigeColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa la contrasena';
              }
              if (value.length < 4) {
                return 'La contrasena debe tener al menos 4 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 36),
          _PressScaleButton(onPressed: onSubmit, child: const Text('Log In')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGitHubLogin,
              icon: const Text(
                '🌟',
              ), // Could use a custom icon here if preferred
              label: const Text('Sign in with GitHub'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(
                  color: PrestigeColors.outlineVariant,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                foregroundColor: PrestigeColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Align(
            child: Text.rich(
              TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                  color: PrestigeColors.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'Not a member yet? '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: onGoToRegister,
                      child: Text(
                        'Sign Up',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PrestigeColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: PrestigeColors.secondary,
                          decorationThickness: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error!,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: PrestigeColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_awesome,
            color: PrestigeColors.secondaryContainer,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Text('Client Loyalty', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelSmall);
  }
}

class _PressScaleButton extends StatefulWidget {
  const _PressScaleButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<_PressScaleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(25, 28, 30, 0.06),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
