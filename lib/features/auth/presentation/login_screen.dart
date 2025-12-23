import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../domain/auth_cubit.dart';
import '../../../core/themes/design_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    }
                  });
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final bool isLoading = state is AuthLoading;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(textTheme),
                    const SizedBox(height: 48),
                    _buildEmailField(isLoading),
                    const SizedBox(height: 16),
                    _buildPasswordField(isLoading),
                    const SizedBox(height: 8),
                    _buildForgotPasswordButton(context, isLoading),
                    const SizedBox(height: 24),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildSignInButton(context),
                    const SizedBox(height: 24),
                    _buildSocialLoginSeparator(textTheme),
                    const SizedBox(height: 24),
                    _buildGoogleSignInButton(context, isLoading),
                    const SizedBox(height: 32),
                    _buildSignUpNavigation(context, isLoading, textTheme, colorScheme),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_inapp.png',
          height: FigmaSpacing.logoSize,
          width: FigmaSpacing.logoSize,
        ),
        SizedBox(height: FigmaSpacing.lg),
        Text(
          'Moji Focus',
          style: FigmaTextStyles.h2,
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: FigmaColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: FigmaSpacing.inputPadding,
        hintStyle: FigmaTextStyles.hint,
      ),
      style: FigmaTextStyles.input,
      keyboardType: TextInputType.emailAddress,
      enabled: !isLoading,
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: FigmaColors.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: FigmaColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: FigmaSpacing.inputPadding,
        hintStyle: FigmaTextStyles.hint,
      ),
      style: FigmaTextStyles.input,
      obscureText: _obscurePassword,
      enabled: !isLoading,
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context, bool isLoading) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
        child: Text(
          'Forgot Password?',
          style: FigmaTextStyles.labelMedium.copyWith(
            color: FigmaColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthCubit>().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: FigmaColors.textOnPrimary,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
        elevation: FigmaElevation.sm,
      ),
      child: Text('SIGN IN', style: FigmaTextStyles.labelLarge),
    );
  }

  Widget _buildSocialLoginSeparator(TextTheme textTheme) {
    return Row(
      children: [
        const Expanded(child: Divider(color: FigmaColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: FigmaSpacing.md),
          child: Text(
            'OR',
            style: FigmaTextStyles.bodySmall.copyWith(
              color: FigmaColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: FigmaColors.divider)),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().signInWithGoogle(),
      icon: const Icon(Icons.g_mobiledata, size: 28.0),
      label: Text('Sign In with Google', style: FigmaTextStyles.labelMedium),
      style: OutlinedButton.styleFrom(
        foregroundColor: FigmaColors.textPrimary,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        side: const BorderSide(
          color: FigmaColors.surface,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
      ),
    );
  }

  Widget _buildSignUpNavigation(BuildContext context, bool isLoading, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: FigmaTextStyles.bodyMedium.copyWith(
            color: FigmaColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.register),
          child: Text(
            'Sign Up',
            style: FigmaTextStyles.labelMedium.copyWith(
              color: FigmaColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}