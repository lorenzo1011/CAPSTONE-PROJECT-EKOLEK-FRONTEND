import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/profile_providers.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStateProvider).profile;
    return AdaptivePageScaffold(
      title: 'Personal information',
      subtitle: 'Verified details linked to your resident account',
      scrollable: true,
      body: profile == null
          ? AppErrorView(
              title: 'Profile unavailable',
              message: 'Return to Profile and reload your information.',
              onRetry: () => ref.read(profileControllerProvider).load(),
              retryLabel: 'Reload',
            )
          : Card(
              child: Column(
                children: [
                  _field('Legal name', profile.fullName),
                  _field('Email / login', profile.email),
                  _field(
                    'Phone number',
                    profile.phoneNumber.isEmpty
                        ? 'Not provided'
                        : profile.phoneNumber,
                  ),
                  _field('Birthdate', _date(profile.birthdate)),
                  _field('Barangay', profile.barangay.name),
                  _field('Complete address', profile.completeAddress),
                  _field('Resident ID', profile.residentId ?? 'Not yet issued'),
                  _field(
                    'Approval status',
                    _status(profile.approvalStatus.value),
                  ),
                  _field(
                    'Member since',
                    _date(profile.memberSince),
                    last: true,
                  ),
                ],
              ),
            ),
    );
  }

  static Widget _field(String label, String value, {bool last = false}) =>
      Column(
        children: [
          ListTile(
            title: Text(label),
            subtitle: Text(value),
            trailing: const Tooltip(
              message: 'Verified information cannot be changed in the app',
              child: Icon(Icons.lock_outline_rounded, size: 18),
            ),
          ),
          if (!last) const Divider(height: 1),
        ],
      );

  static String _date(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

  static String _status(String value) {
    final normalized = value.toLowerCase();
    return normalized.isEmpty
        ? 'Unknown'
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}
