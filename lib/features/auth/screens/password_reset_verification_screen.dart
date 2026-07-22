import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/providers/auth_providers.dart';

class PasswordResetVerificationScreen extends ConsumerStatefulWidget {
  const PasswordResetVerificationScreen({super.key});
  @override
  ConsumerState<PasswordResetVerificationScreen> createState() => _S();
}

class _S extends ConsumerState<PasswordResetVerificationScreen> {
  final code = TextEditingController();
  @override
  void dispose() {
    code.dispose();
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
                          'Enter reset code',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: code,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Six-digit code',
                            errorText: c.fieldErrors['code']?.firstOrNull,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: c.busy || c.email == null
                              ? null
                              : () async {
                                  if (code.text.length == 6 &&
                                      await ref
                                          .read(passwordControllerProvider)
                                          .verify(code.text) &&
                                      context.mounted) {
                                    context.go(AppRoutes.newPasswordPath);
                                  }
                                },
                          child: Text(c.busy ? 'Verifying…' : 'Verify Code'),
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
