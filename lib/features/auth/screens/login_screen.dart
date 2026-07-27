import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/core_providers.dart';
import '../models/login_request.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _entranceController.value = 1;
      } else {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final succeeded = await ref
        .read(authControllerProvider)
        .login(
          LoginRequest(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
    if (succeeded) _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authenticationStateProvider);
    final isOffline = ref
        .watch(connectivityStatusProvider)
        .when(
          data: (status) => status == ConnectivityStatus.offline,
          error: (error, stackTrace) => false,
          loading: () => false,
        );
    final disabled = state.isSubmitting;

    return Scaffold(
      body: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tablet = constraints.maxWidth >= 760;
              final form = _LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                emailFocus: _emailFocus,
                passwordFocus: _passwordFocus,
                state: state,
                isOffline: isOffline,
                disabled: disabled,
                obscurePassword: _obscurePassword,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onSubmit: _submit,
              );
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppSpacing.xxl,
                  ),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: tablet
                            ? ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 980,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Expanded(
                                      flex: 11,
                                      child: _BrandPanel(),
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    Expanded(
                                      flex: 10,
                                      child: Center(child: form),
                                    ),
                                  ],
                                ),
                              )
                            : ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _CompactBrand(),
                                    const SizedBox(height: AppSpacing.lg),
                                    form,
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.state,
    required this.isOffline,
    required this.disabled,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final AuthenticationState state;
  final bool isOffline;
  final bool disabled;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  String? _fieldError(String key) => state.fieldErrors[key]?.firstOrNull;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in securely to continue your E-KOLEK journey.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (isOffline || state.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                _InlineNotice(
                  message: isOffline
                      ? 'You appear to be offline. Check your connection and try again.'
                      : state.message!,
                  warning: isOffline,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: emailController,
                focusNode: emailFocus,
                enabled: !disabled,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: _fieldError('email'),
                ),
                validator: Validators.email,
                onFieldSubmitted: (_) => passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocus,
                enabled: !disabled,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: _fieldError('password'),
                  suffixIcon: IconButton(
                    onPressed: disabled ? null : onTogglePassword,
                    tooltip: obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(obscurePassword),
                      ),
                    ),
                  ),
                ),
                validator: Validators.loginPassword,
                onFieldSubmitted: (_) => disabled ? null : onSubmit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                button: true,
                label: disabled ? 'Signing in' : 'Sign in',
                child: FilledButton(
                  onPressed: disabled || isOffline ? null : onSubmit,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: disabled
                        ? const SizedBox.square(
                            key: ValueKey('login-progress'),
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Sign in', key: ValueKey('login-label')),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: disabled
                    ? null
                    : () => context.push(AppRoutes.forgotPasswordPath),
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'New to E-KOLEK?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: disabled
                        ? null
                        : () => context.push(AppRoutes.signupPath),
                    child: const Text('Create account'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Your credentials are encrypted in transit and never stored as plain text on this device.',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.warning});
  final String message;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: warning
              ? AppColors.warning.withValues(alpha: 0.16)
              : AppColors.error.withValues(alpha: 0.08),
          borderRadius: AppRadius.mediumBorderRadius,
          border: Border.all(
            color: warning ? AppColors.warning : AppColors.error,
          ),
        ),
        child: Row(
          children: [
            Icon(
              warning ? Icons.wifi_off_rounded : Icons.info_outline_rounded,
              color: warning ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
          ],
        ),
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.smMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: AppRadius.largeBorderRadius,
        ),
        child: Icon(
          Icons.recycling_rounded,
          size: 34,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      const SizedBox(height: AppSpacing.smMd),
      const Text('E-KOLEK', style: AppTextStyles.headingLarge),
      Text(
        'Small actions. Measurable impact.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'E-KOLEK Resident App',
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: AppRadius.extraLargeBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.smMd),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: .12),
              borderRadius: AppRadius.largeBorderRadius,
            ),
            child: const Icon(
              Icons.recycling_rounded,
              size: 36,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your impact,\nmade visible.',
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Recycle responsibly, learn practical habits, and turn verified action into community rewards.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onBrandMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _BrandBenefit(
            Icons.monitor_heart_outlined,
            'Track verified environmental activity',
          ),
          const SizedBox(height: AppSpacing.md),
          const _BrandBenefit(
            Icons.workspace_premium_outlined,
            'Earn points, badges, and useful rewards',
          ),
          const SizedBox(height: AppSpacing.md),
          const _BrandBenefit(
            Icons.groups_outlined,
            'Grow with your barangay community',
          ),
        ],
      ),
    ),
  );
}

class _BrandBenefit extends StatelessWidget {
  const _BrandBenefit(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.onBrandMuted, size: 21),
      const SizedBox(width: AppSpacing.smMd),
      Expanded(
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
      ),
    ],
  );
}
