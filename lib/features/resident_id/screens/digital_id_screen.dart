import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/resident_id_providers.dart';
import '../../auth/models/auth_user.dart';
import '../models/digital_resident_id.dart';
import '../providers/resident_id_controller.dart';
import '../providers/resident_id_state.dart';
import '../widgets/digital_id_skeleton.dart';
import '../widgets/digital_resident_card.dart';
import '../widgets/secure_qr_card.dart';

class DigitalIdScreen extends ConsumerStatefulWidget {
  const DigitalIdScreen({super.key});

  @override
  ConsumerState<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends ConsumerState<DigitalIdScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(residentIdControllerProvider)
          .loadFor(ref.read(currentAuthUserProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(residentIdStateProvider);
    final controller = ref.read(residentIdControllerProvider);
    final user = ref.watch(currentAuthUserProvider);
    final refreshing =
        state.status == ResidentIdLoadStatus.loading ||
        state.status == ResidentIdLoadStatus.refreshing;

    Future<void> refresh() => controller.loadFor(user, refresh: true);

    return AdaptivePageScaffold(
      title: 'Digital Resident ID',
      subtitle: 'Your official E-KOLEK identity',
      actions: [
        IconButton(
          tooltip: 'Refresh ID',
          onPressed: refreshing ? null : refresh,
          icon: refreshing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: _body(context, state, controller, user, refresh),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ResidentIdState state,
    ResidentIdController controller,
    AuthUser? user,
    Future<void> Function() refresh,
  ) {
    if (state.id == null && state.status == ResidentIdLoadStatus.loading) {
      return const DigitalIdSkeleton();
    }
    if (state.id == null && state.status == ResidentIdLoadStatus.offline) {
      return AppOfflineView(
        onRetry: () => controller.loadFor(user, refresh: true),
      );
    }
    if (state.id == null &&
        (state.status == ResidentIdLoadStatus.failure ||
            state.status == ResidentIdLoadStatus.unavailable)) {
      return AppErrorView(
        title: 'Digital ID unavailable',
        message:
            state.message ??
            'Your E-KOLEK Resident ID could not be loaded. Please try again.',
        onRetry: state.status == ResidentIdLoadStatus.failure
            ? () => controller.loadFor(user, refresh: true)
            : null,
      );
    }

    final id = state.id;
    if (id == null) return const DigitalIdSkeleton();
    final refreshing = state.status == ResidentIdLoadStatus.refreshing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isStale) ...[
          const _BackendNotice(
            icon: Icons.cloud_off_outlined,
            text:
                'Offline copy shown. Refresh before presenting the QR for a transaction.',
            warning: true,
          ),
          const SizedBox(height: 14),
        ] else ...[
          const _BackendNotice(
            icon: Icons.verified_user_outlined,
            text:
                'Verified fields below come directly from your authenticated E-KOLEK record.',
          ),
          const SizedBox(height: 14),
        ],
        if (refreshing) ...[
          const LinearProgressIndicator(minHeight: 3, color: Color(0xFF0B5A34)),
          const SizedBox(height: 12),
        ],
        DigitalResidentCard(id: id, qrVerifiedOnline: !state.isStale),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'Present your secure QR',
          subtitle:
              'Authorized E-KOLEK scanners validate its active status on the backend.',
          icon: Icons.qr_code_scanner_rounded,
        ),
        const SizedBox(height: 12),
        SecureQrCard(
          id: id,
          isRefreshing: refreshing,
          lastVerified: state.isStale ? null : state.lastUpdated,
          verifiedOnline: !state.isStale,
          onRefresh: refresh,
          onExpand: id.canDisplayQr && !state.isStale
              ? () => context.push(AppRoutes.residentIdQrPath)
              : null,
        ),
        const SizedBox(height: 24),
        const _SectionHeading(
          title: 'ID record',
          subtitle: 'Official issuance and validity details',
          icon: Icons.fact_check_outlined,
        ),
        const SizedBox(height: 12),
        _IdRecordCard(id: id),
        const SizedBox(height: 16),
        const _LostCardNotice(),
        if (state.lastUpdated != null) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Last checked ${DateFormat.yMMMd().add_jm().format(state.lastUpdated!.toLocal())}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _BackendNotice extends StatelessWidget {
  const _BackendNotice({
    required this.icon,
    required this.text,
    this.warning = false,
  });

  final IconData icon;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final foreground = warning ? AppColors.warning : AppColors.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: warning
            ? AppColors.warningContainer.withValues(alpha: .65)
            : AppColors.successContainer.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8F3),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF0B5A34), size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdRecordCard extends StatelessWidget {
  const _IdRecordCard({required this.id});

  final DigitalResidentId id;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd();
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final items = [
              _RecordItem(
                icon: Icons.badge_outlined,
                label: 'Card number',
                value: id.cardNumber ?? 'Not yet issued',
              ),
              _RecordItem(
                icon: Icons.calendar_today_outlined,
                label: 'Date issued',
                value: id.cardIssuedAt == null
                    ? 'Not available'
                    : date.format(id.cardIssuedAt!.toLocal()),
              ),
              _RecordItem(
                icon: Icons.event_available_outlined,
                label: 'Valid until',
                value: id.cardExpiryDate == null
                    ? 'No date supplied'
                    : date.format(id.cardExpiryDate!.toLocal()),
              ),
              _RecordItem(
                icon: id.status.icon,
                label: 'Backend status',
                value: id.status.label,
              ),
            ];
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    items[i],
                    if (i != items.length - 1)
                      const Divider(height: 25, color: AppColors.divider),
                  ],
                ],
              );
            }
            return Wrap(
              spacing: 16,
              runSpacing: 18,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: item,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8F3),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: const Color(0xFF0B5A34), size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LostCardNotice extends StatelessWidget {
  const _LostCardNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF5E3B7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_gmailerrorred_outlined, color: AppColors.warning),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lost, stolen, or damaged ID?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Report it to CENRO immediately. The old backend QR can be deactivated so it can no longer be accepted by EkoScan.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
