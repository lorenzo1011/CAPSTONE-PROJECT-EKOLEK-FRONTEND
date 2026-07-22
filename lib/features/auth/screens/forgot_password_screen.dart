import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _State();
}

class _State extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(passwordControllerProvider);
    return _PasswordScaffold(
      title: 'Reset your password',
      icon: Icons.lock_reset_rounded,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your resident email. If it matches an account, a six-digit code will be sent.',
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (c.message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(c.message!),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: c.busy
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      if (!(_form.currentState?.validate() ?? false)) return;
                      if (await ref
                              .read(passwordControllerProvider)
                              .request(_email.text.trim()) &&
                          context.mounted) {
                        context.go(AppRoutes.passwordResetVerifyPath);
                      }
                    },
              child: Text(c.busy ? 'Sending…' : 'Send Reset Code'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.loginPath),
              child: const Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordScaffold extends StatelessWidget {
  const _PasswordScaffold({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(icon, size: 56),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
