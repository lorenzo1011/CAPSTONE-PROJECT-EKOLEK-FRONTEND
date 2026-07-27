import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/resident_id_providers.dart';
import '../providers/resident_id_state.dart';
import '../widgets/secure_qr_card.dart';

class FullScreenQrScreen extends ConsumerStatefulWidget {
  const FullScreenQrScreen({super.key});

  @override
  ConsumerState<FullScreenQrScreen> createState() => _FullScreenQrScreenState();
}

class _FullScreenQrScreenState extends ConsumerState<FullScreenQrScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_verifyWithBackend);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyWithBackend();
    }
  }

  Future<void> _verifyWithBackend() {
    return ref
        .read(residentIdControllerProvider)
        .loadFor(ref.read(currentAuthUserProvider), refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(residentIdStateProvider);
    final id = state.id;
    final loading =
        state.status == ResidentIdLoadStatus.loading ||
        state.status == ResidentIdLoadStatus.refreshing;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        title: const Text('Secure QR'),
        backgroundColor: const Color(0xFFF5FAF7),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Verify again',
            onPressed: loading ? null : _verifyWithBackend,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _verifyWithBackend,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: id == null
                          ? _LoadState(
                              loading: loading,
                              message:
                                  state.message ??
                                  'Your secure QR code is currently unavailable.',
                              onRetry: loading ? null : _verifyWithBackend,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.isStale)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.cloud_off_outlined,
                                          color: AppColors.warning,
                                          size: 19,
                                        ),
                                        SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            'Showing the last loaded ID. Reconnect before presenting this QR.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SecureQrCard(
                                  id: id,
                                  compact: true,
                                  isRefreshing: loading,
                                  lastVerified: state.isStale
                                      ? null
                                      : state.lastUpdated,
                                  verifiedOnline: !state.isStale,
                                  onRefresh: _verifyWithBackend,
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
      ),
    );
  }
}

class _LoadState extends StatelessWidget {
  const _LoadState({
    required this.loading,
    required this.message,
    required this.onRetry,
  });

  final bool loading;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(color: Color(0xFF0B5A34))
            else
              const Icon(
                Icons.qr_code_2_rounded,
                size: 64,
                color: AppColors.textDisabled,
              ),
            const SizedBox(height: 16),
            Text(
              loading ? 'Checking your QR with E-KOLEK…' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
