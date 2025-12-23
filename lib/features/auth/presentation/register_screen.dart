import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../domain/auth_cubit.dart';
import '../../../core/themes/design_tokens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng ký, giờ sẽ gọi Cubit
  void _onRegisterPressed() {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Gọi phương thức từ AuthCubit
    context.read<AuthCubit>().signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            
            // Responsive sizing
            final logoSize = screenHeight * 0.1;
            final spacing = screenHeight * 0.015;
            final fieldHeight = screenHeight * 0.07;
            
            return BlocConsumer<AuthCubit, AuthState>(
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
                      backgroundColor: FigmaColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final bool isLoading = state is AuthLoading;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Header
                      _buildHeader(logoSize, screenHeight),
                      
                      SizedBox(height: spacing * 2),
                      
                      // Email Field
                      SizedBox(
                        height: fieldHeight,
                        child: _buildEmailField(isLoading),
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Username Field
                      SizedBox(
                        height: fieldHeight,
                        child: _buildUsernameField(isLoading),
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Password Field
                      SizedBox(
                        height: fieldHeight,
                        child: _buildPasswordField(isLoading),
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Confirm Password Field
                      SizedBox(
                        height: fieldHeight,
                        child: _buildConfirmPasswordField(isLoading),
                      ),
                      
                      SizedBox(height: spacing * 1.5),
                      
                      // Terms Checkbox
                      _buildTermsCheckbox(screenHeight),
                      
                      SizedBox(height: spacing * 1.5),
                      
                      // Sign Up Button
                      SizedBox(
                        height: fieldHeight * 0.9,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildSignUpButton(),
                      ),
                      
                      SizedBox(height: spacing * 2),
                      
                      // Sign In Navigation
                      _buildSignInNavigation(context, isLoading, screenHeight),
                      
                      const Spacer(flex: 1),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- CÁC HÀM BUILD UI RESPONSIVE ---

  Widget _buildHeader(double logoSize, double screenHeight) {
    final titleSize = screenHeight < 700 ? 22.0 : 26.0;
    final subtitleSize = screenHeight < 700 ? 13.0 : 15.0;
    
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_inapp.png',
          height: logoSize,
          width: logoSize,
        ),
        SizedBox(height: screenHeight * 0.015),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: FigmaColors.textPrimary,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          'Start your productive journey today!',
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w500,
            color: FigmaColors.textSecondary,
          ),
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

  Widget _buildUsernameField(bool isLoading) {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: 'Username',
        prefixIcon: const Icon(Icons.person_outline),
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

  Widget _buildConfirmPasswordField(bool isLoading) {
    return TextField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: FigmaColors.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
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
      obscureText: _obscureConfirmPassword,
      enabled: !isLoading,
    );
  }

  Widget _buildTermsCheckbox(double screenHeight) {
    final fontSize = screenHeight < 700 ? 12.0 : 14.0;
    
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            activeColor: FigmaColors.primary,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: TextStyle(
                fontSize: fontSize,
                color: FigmaColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: FigmaColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print('Navigate to Terms & Conditions');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _onRegisterPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
      ),
      child: const Text(
        'CREATE ACCOUNT',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildSignInNavigation(BuildContext context, bool isLoading, double screenHeight) {
    final fontSize = screenHeight < 700 ? 13.0 : 15.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            fontSize: fontSize,
            color: FigmaColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Log In',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: FigmaColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}