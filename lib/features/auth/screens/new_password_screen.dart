import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});
  @override
  ConsumerState<NewPasswordScreen> createState() => _N();
}

class _N extends ConsumerState<NewPasswordScreen> {
  final p = TextEditingController(), q = TextEditingController();
  bool hide = true;
  @override
  void dispose() {
    p.dispose();
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(passwordControllerProvider);
    return Scaffold(
      appBar: AppBar(),
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
                        Text(
                          'Create new password',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextField(
                          controller: p,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            errorText:
                                c.fieldErrors['new_password']?.firstOrNull,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hide = !hide),
                              tooltip: hide ? 'Show password' : 'Hide password',
                              icon: Icon(
                                hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: q,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            errorText: c
                                .fieldErrors['password_confirmation']
                                ?.firstOrNull,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: c.busy || c.ticket == null
                              ? null
                              : () async {
                                  if (p.text.length >= 8 &&
                                      p.text == q.text &&
                                      await ref
                                          .read(passwordControllerProvider)
                                          .reset(p.text, q.text) &&
                                      context.mounted) {
                                    context.go(AppRoutes.loginPath);
                                  }
                                },
                          child: Text(c.busy ? 'Updating…' : 'Update Password'),
                        ),
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
