import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/adaptive_page_scaffold.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/providers/profile_providers.dart';
import '../providers/profile_state.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileStateProvider);
    final profile = state.profile;
    if (profile != null && !_initialized) {
      _phone.text = profile.phoneNumber;
      _initialized = true;
    }
    return AdaptivePageScaffold(
      title: 'Edit profile',
      subtitle: 'Only fields approved for self-service editing are shown',
      scrollable: true,
      body: profile == null
          ? const AppErrorView(
              title: 'Profile unavailable',
              message: 'Return to Profile and reload your information.',
            )
          : Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (profile.permissions.canEditPhoto)
                        OutlinedButton.icon(
                          onPressed: state.phase == ProfilePhase.uploadingPhoto
                              ? null
                              : _pickPhoto,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: Text(
                            state.phase == ProfilePhase.uploadingPhoto
                                ? 'Uploading photo…'
                                : 'Choose profile photo',
                          ),
                        ),
                      if (state.phase == ProfilePhase.uploadingPhoto)
                        LinearProgressIndicator(value: state.uploadProgress),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phone,
                        enabled:
                            profile.permissions.canEditPhone &&
                            state.phase != ProfilePhase.saving,
                        maxLength: 20,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) > 20
                            ? 'Phone number cannot exceed 20 characters.'
                            : null,
                      ),
                      if (state.message != null) ...[
                        const SizedBox(height: 8),
                        Text(state.message!, semanticsLabel: state.message),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed:
                            profile.permissions.canEditPhone &&
                                state.phase != ProfilePhase.saving
                            ? _save
                            : null,
                        child: Text(
                          state.phase == ProfilePhase.saving
                              ? 'Saving…'
                              : 'Save changes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _pickPhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (photo == null || !mounted) return;
    final extension = photo.path.split('.').last.toLowerCase();
    final size = await photo.length();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension) ||
        size > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a JPG, PNG, or WEBP image up to 5 MB.'),
          ),
        );
      }
      return;
    }
    await ref.read(profileControllerProvider).uploadPhoto(photo.path);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(profileControllerProvider)
        .savePhone(_phone.text);
    if (saved && mounted) Navigator.of(context).pop();
  }
}
