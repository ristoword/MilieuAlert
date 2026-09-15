import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _selectedLanguage = 'EN';
  String _selectedCountry = 'NL';

  late final AnimationController _borderAnimCtrl;
  late final AnimationController _pulseAnimCtrl;
  late final AnimationController _scanLineCtrl;

  final _formKey = GlobalKey<FormState>();

  static const _languages = {
    'EN': 'English',
    'NL': 'Nederlands',
    'IT': 'Italiano',
  };

  static const _countries = {
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'DE': 'Germany',
    'IT': 'Italy',
    'FR': 'France',
    'AT': 'Austria',
    'ES': 'Spain',
    'PT': 'Portugal',
    'UK': 'United Kingdom',
  };

  @override
  void initState() {
    super.initState();
    _borderAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _borderAnimCtrl.dispose();
    _pulseAnimCtrl.dispose();
    _scanLineCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (_isLogin) {
      success = await ref.read(authProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            rememberMe: _rememberMe,
          );
    } else {
      success = await ref.read(authProvider.notifier).register(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            displayName: _nameCtrl.text.trim(),
            preferredLanguage: _selectedLanguage,
            country: _selectedCountry,
          );
    }

    if (!mounted) return;

    if (success) {
      context.go('/onboarding/language');
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: NeonColors.pink,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: NeonColors.deepSpace,
      body: Stack(
        children: [
          // Scan-line overlay
          _ScanLineBackground(controller: _scanLineCtrl),

          // Grid pattern
          const _GridBackground(),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? size.width * 0.15 : 24,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo + branding
                    _buildBranding(),
                    const SizedBox(height: 32),

                    // Glassmorphism form card
                    _buildFormCard(authState),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return AnimatedBuilder(
      animation: _pulseAnimCtrl,
      builder: (context, child) {
        final glow = 8.0 + _pulseAnimCtrl.value * 12.0;
        return Column(
          children: [
            // Shield icon with neon glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [NeonColors.cyan, NeonColors.electricBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NeonColors.cyan.withValues(alpha: 0.5),
                    blurRadius: glow,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // App title with neon gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [NeonColors.cyan, NeonColors.electricBlue, NeonColors.purple],
              ).createShader(bounds),
              child: Text(
                'MILIEUALERT',
                style: GoogleFonts.exo2(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'LOW EMISSION ZONE GUARDIAN',
              style: GoogleFonts.exo2(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: NeonColors.cyan.withValues(alpha: 0.7),
                letterSpacing: 4,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormCard(AuthState authState) {
    return AnimatedBuilder(
      animation: _borderAnimCtrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _NeonBorderPainter(
            progress: _borderAnimCtrl.value,
            borderRadius: 20,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: NeonColors.darkCard.withValues(alpha: 0.85),
          border: Border.all(
            color: NeonColors.cyan.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Login / Register toggle
                  _buildToggle(),
                  const SizedBox(height: 28),

                  // Form fields
                  if (!_isLogin) ...[
                    _buildNeonField(
                      controller: _nameCtrl,
                      label: 'Display Name',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildNeonField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildNeonField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: NeonColors.cyan.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),

                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    _buildNeonDropdown<String>(
                      label: 'Preferred Language',
                      icon: Icons.language,
                      value: _selectedLanguage,
                      items: _languages.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedLanguage = v ?? 'EN'),
                    ),
                    const SizedBox(height: 16),
                    _buildNeonDropdown<String>(
                      label: 'Country',
                      icon: Icons.public,
                      value: _selectedCountry,
                      items: _countries.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCountry = v ?? 'NL'),
                    ),
                  ],

                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    _buildRememberMe(),
                  ],

                  const SizedBox(height: 28),

                  // Submit button
                  _buildSubmitButton(authState),

                  const SizedBox(height: 20),

                  // Toggle link
                  _buildToggleLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: NeonColors.deepSpace.withValues(alpha: 0.6),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _toggleButton('Sign In', _isLogin)),
          Expanded(child: _toggleButton('Register', !_isLogin)),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isLogin = label == 'Sign In'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isActive
              ? const LinearGradient(
                  colors: [NeonColors.cyan, NeonColors.electricBlue],
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: NeonColors.cyan.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.white54,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      cursorColor: NeonColors.cyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: NeonColors.cyan.withValues(alpha: 0.7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: NeonColors.deepSpace.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.pink, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.pink, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildNeonDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: NeonColors.darkCard,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      iconEnabledColor: NeonColors.cyan.withValues(alpha: 0.7),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: NeonColors.cyan.withValues(alpha: 0.7), size: 20),
        filled: true,
        fillColor: NeonColors.deepSpace.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? true),
            activeColor: NeonColors.cyan,
            checkColor: NeonColors.deepSpace,
            side: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Remember me',
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedBuilder(
        animation: _pulseAnimCtrl,
        builder: (context, child) {
          final glowIntensity = 0.2 + _pulseAnimCtrl.value * 0.2;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [NeonColors.cyan, NeonColors.electricBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: NeonColors.cyan.withValues(alpha: glowIntensity),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: authState.isLoading ? null : _handleSubmit,
            child: Center(
              child: authState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLogin ? Icons.login : Icons.person_add_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                          style: GoogleFonts.exo2(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account? " : 'Already have an account? ',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _isLogin = !_isLogin);
            ref.read(authProvider.notifier).clearError();
          },
          child: Text(
            _isLogin ? 'Register' : 'Sign In',
            style: GoogleFonts.inter(
              color: NeonColors.cyan,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Animated gradient border painter ---

class _NeonBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;

  _NeonBorderPainter({required this.progress, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Sweep gradient that rotates
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(progress * math.pi * 2),
      colors: const [
        NeonColors.cyan,
        NeonColors.electricBlue,
        NeonColors.purple,
        NeonColors.magenta,
        NeonColors.cyan,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(rrect, paint);

    // Outer glow
    final glowPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(_NeonBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Scan-line background animation ---

class _ScanLineBackground extends AnimatedWidget {
  const _ScanLineBackground({required AnimationController controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ScanLinePainter(progress: animation.value),
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;

  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          NeonColors.cyan.withValues(alpha: 0.06),
          NeonColors.cyan.withValues(alpha: 0.12),
          NeonColors.cyan.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 40, size.width, 80));

    canvas.drawRect(Rect.fromLTWH(0, y - 40, size.width, 80), paint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Grid pattern background ---

class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GridPainter(),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
