import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Halaman Login — entry point utama aplikasi.
///
/// Fitur:
/// - Login email & password
/// - Biometric login (jika tersedia)
/// - Navigasi ke Register
/// - Error handling dengan SnackBar
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _hasPromptedBiometric = false;
  bool _showBioButton = false;

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocusChanged);
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onEmailFocusChanged);
    _emailController.removeListener(_onEmailChanged);
    _emailFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Listeners
  // ─────────────────────────────────────────────

  void _onEmailChanged() {
    if (_showBioButton || _hasPromptedBiometric) {
      setState(() {
        _showBioButton = false;
        _hasPromptedBiometric = false;
      });
    }
  }

  void _onEmailFocusChanged() async {
    if (!_emailFocus.hasFocus &&
        _emailController.text.isNotEmpty &&
        !_hasPromptedBiometric) {
      final provider = context.read<AuthProvider>();
      final hasBio =
          await provider.hasBiometricForEmail(_emailController.text);
      if (mounted && hasBio) {
        setState(() => _showBioButton = true);
        _hasPromptedBiometric = true;
        provider.loginWithBiometric(_emailController.text);
      }
    }
  }

  // ─────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────

  void _handleLogin(AuthProvider provider) {
    if (!_formKey.currentState!.validate()) return;
    provider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, provider, _) {
          // Tampilkan error sebagai SnackBar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.errorMessage != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              provider.clearError();
            }
          });

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.xxl),
                  _buildHeader(),
                  const SizedBox(height: AppSizes.xxl),
                  _buildForm(provider),
                  const SizedBox(height: AppSizes.sm),
                  _buildForgotPassword(),
                  const SizedBox(height: AppSizes.md),
                  AppButton(
                    label: AppStrings.login,
                    isLoading: provider.isLoading,
                    onPressed: () => _handleLogin(provider),
                  ),
                  if (_showBioButton) ...[
                    const SizedBox(height: AppSizes.md),
                    _buildBiometricButton(provider),
                  ],
                  const SizedBox(height: AppSizes.xl),
                  _buildDivider(),
                  const SizedBox(height: AppSizes.lg),
                  _buildRegisterLink(context),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section Builders
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo GIF animasi
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: _AnimatedLogo(),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        const Text(
          'Masuk untuk melanjutkan ke Smart Daily',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider provider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailController,
            label: AppStrings.email,
            hint: 'nama@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
            focusNode: _emailFocus,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            controller: _passwordController,
            label: AppStrings.password,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            focusNode: _passwordFocus,
            validator: Validators.password,
            onFieldSubmitted: (_) => _handleLogin(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(AppStrings.forgotPassword),
      ),
    );
  }

  Widget _buildBiometricButton(AuthProvider provider) {
    return OutlinedButton.icon(
      onPressed: provider.isLoading
          ? null
          : () => provider.loginWithBiometric(_emailController.text),
      icon: const Icon(Icons.fingerprint_rounded, size: 22),
      label: const Text('Login dengan Sidik Jari'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'atau',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.dontHaveAccount,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRouter.register),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.register,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Animated GIF Logo
// ─────────────────────────────────────────────

/// Widget logo animasi GIF yang looping secara otomatis.
/// Pastikan file sudah didaftarkan di pubspec.yaml:
///
/// flutter:
///   assets:
///     - assets/images/logo.gif
class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Gif(
      image: const AssetImage('assets/images/supikip-cuayo.gif'),
      controller: _controller,
      autostart: Autostart.loop,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
    );
  }
}