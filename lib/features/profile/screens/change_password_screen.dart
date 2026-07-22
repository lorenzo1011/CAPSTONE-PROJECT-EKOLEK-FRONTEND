import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _C();
}

class _C extends ConsumerState<ChangePasswordScreen> {
  final old = TextEditingController(),
      next = TextEditingController(),
      confirm = TextEditingController();
  bool hide = true;
  @override
  void dispose() {
    old.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(passwordControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        TextField(
                          controller: old,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'Current password',
                            errorText:
                                c.fieldErrors['old_password']?.firstOrNull,
                          ),
                        ),
                        TextField(
                          controller: next,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            errorText:
                                c.fieldErrors['new_password']?.firstOrNull,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => hide = !hide),
                              tooltip: hide
                                  ? 'Show passwords'
                                  : 'Hide passwords',
                              icon: Icon(
                                hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: confirm,
                          obscureText: hide,
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: c.busy
                              ? null
                              : () async {
                                  if (next.text.length >= 8 &&
                                      next.text == confirm.text &&
                                      await ref
                                          .read(passwordControllerProvider)
                                          .change(old.text, next.text) &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Your password was changed successfully.',
                                        ),
                                      ),
                                    );
                                    context.pop();
                                  }
                                },
                          child: Text(c.busy ? 'Saving…' : 'Save Password'),
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
