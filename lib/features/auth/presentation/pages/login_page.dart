import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Login Page — Premium glassmorphic login screen
/// with animated background, role-based quick login,
/// and responsive design
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authStateProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        setState(() => _errorMessage = 'Invalid email or password');
      }
    }
  }

  Future<void> _quickLogin(String email, String password) async {
    _emailController.text = email;
    _passwordController.text = password;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authStateProvider.notifier).login(
          email.trim(),
          password.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        setState(() => _errorMessage = 'Invalid email or password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Animated Background ───────────────
          _buildAnimatedBackground(),

          // ─── Content ───────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.pagePadding,
                  vertical: 24,
                ),
                child: isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                AppColors.darkBg,
                Color(0xFF0A0A1A),
                Color(0xFF12122B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.5 + (_bgAnimController.value * 0.1),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating orbs
              Positioned(
                top: -80 + (_bgAnimController.value * 40),
                right: -60,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100 + (_bgAnimController.value * 30),
                left: -80,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.12),
                        AppColors.secondary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentCyan.withValues(alpha: 0.08),
                        AppColors.accentCyan.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Left Side: Branding ─────────────
          Expanded(
            flex: 5,
            child: FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: _buildBrandingSection(),
            ),
          ),
          const SizedBox(width: 60),

          // ─── Right Side: Login Form ──────────
          Expanded(
            flex: 4,
            child: FadeInRight(
              duration: const Duration(milliseconds: 800),
              child: _buildLoginCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: _buildBrandingSectionMobile(),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: _buildLoginCard(isMobile: true),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Symbosys',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'School Management System',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Headline
        const Text(
          'Enterprise-Grade\nSchool ERP Platform',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Multi-tenant SaaS platform with Organization → Branch → Student\nhierarchy. Manage all your schools from a single dashboard.',
          style: TextStyle(
            color: AppColors.darkTextSecondary.withValues(alpha: 0.8),
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Feature pills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildFeaturePill(Icons.business_rounded, 'Multi-Branch'),
            _buildFeaturePill(Icons.shield_rounded, 'Role-Based Access'),
            _buildFeaturePill(Icons.analytics_rounded, 'Real-time Analytics'),
            _buildFeaturePill(Icons.devices_rounded, 'Cross-Platform'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandingSectionMobile() {
    return Column(
      children: [
        // Logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Symbosys SMS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enterprise School Management',
          style: TextStyle(
            color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.darkBorder.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account to continue',
              style: TextStyle(
                color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email field
            _buildLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration(
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password field
            _buildLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                return null;
              },
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Demo accounts
            Center(
              child: Text(
                'QUICK LOGIN (DEMO)',
                style: TextStyle(
                  color: AppColors.darkTextTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDemoAccountGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.darkTextTertiary.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, size: 18, color: AppColors.darkTextTertiary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildDemoAccountGrid() {
    final platformAccount = MockAuthRepository.platformAccount;
    final accounts = MockAuthRepository.demoAccounts;

    final roleIcons = {
      'School Admin': Icons.admin_panel_settings_rounded,
      'Branch Admin': Icons.business_rounded,
      'Teacher': Icons.school_rounded,
      'Parent': Icons.family_restroom_rounded,
      'Student': Icons.person_rounded,
      'Accountant': Icons.account_balance_rounded,
    };
    final roleColors = {
      'School Admin': AppColors.primary,
      'Branch Admin': AppColors.secondary,
      'Teacher': AppColors.accentCyan,
      'Parent': AppColors.accentAmber,
      'Student': AppColors.accentPink,
      'Accountant': AppColors.accent,
    };

    return Column(
      children: [
        // Dedicated Platform Admin Control Panel Login Button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _quickLogin(
                platformAccount['email']!, platformAccount['password']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '👑 1-Tap SaaS Platform Panel Login (platformadmin@symbosys.com)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // School ERP Roles
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: accounts.map((account) {
            final color = roleColors[account['role']] ?? AppColors.primary;
            final icon = roleIcons[account['role']] ?? Icons.person;

            return _DemoAccountChip(
              label: account['role']!,
              icon: icon,
              color: color,
              onTap: () => _quickLogin(account['email']!, account['password']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DemoAccountChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoAccountChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DemoAccountChip> createState() => _DemoAccountChipState();
}

class _DemoAccountChipState extends State<_DemoAccountChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppSpacing.animFast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.15)
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.4)
                  : AppColors.darkBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? widget.color : AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
