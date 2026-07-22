import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/app_routes.dart';
import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_offline_view.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/resident_id_providers.dart';
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
    return AdaptivePageScaffold(
      title: 'Digital Resident ID',
      subtitle: 'Your verified E-KOLEK identity',
      body: RefreshIndicator(
        onRefresh: () => controller.loadFor(user, refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _body(context, state, controller, user),
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
    dynamic controller,
    dynamic user,
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
    final date = DateFormat.yMMMd();
    return Column(
      children: [
        if (state.isStale)
          const _Notice('Some ID information may not be up to date.'),
        if (state.status == ResidentIdLoadStatus.refreshing)
          const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 12),
        DigitalResidentCard(id: id),
        const SizedBox(height: 16),
        SecureQrCard(
          id: id,
          onExpand: id.canDisplayQr
              ? () => context.push(AppRoutes.residentIdQrPath)
              : null,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Physical ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _row('Card number', id.cardNumber ?? 'Not yet issued'),
                if (id.cardIssuedAt != null)
                  _row('Issued', date.format(id.cardIssuedAt!.toLocal())),
                if (id.cardExpiryDate != null)
                  _row(
                    'Valid until',
                    date.format(id.cardExpiryDate!.toLocal()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lost physical ID?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Notify CENRO if your physical ID is lost. Its old QR may be deactivated. Bring supporting documents when instructed by CENRO. Replacement requests are not currently available in this app.',
                ),
              ],
            ),
          ),
        ),
        if (state.lastUpdated != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Last checked ${DateFormat.jm().format(state.lastUpdated!.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: Text(text),
    leading: const Icon(Icons.info_outline_rounded),
    actions: const [SizedBox.shrink()],
  );
}
