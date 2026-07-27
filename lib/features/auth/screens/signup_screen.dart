import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/core_providers.dart';
import '../models/barangay_option.dart';
import '../models/registration_request.dart';
import '../providers/auth_state.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _birthdate = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _imagePicker = ImagePicker();

  late Future<List<BarangayOption>> _barangays;
  DateTime? _selectedBirthdate;
  int? _barangayId;
  XFile? _profilePhoto;
  XFile? _validId;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    _barangays = ref.read(authServiceProvider).getActiveBarangays();
    _password.addListener(_refreshPasswordGuide);
  }

  @override
  void dispose() {
    _password.removeListener(_refreshPasswordGuide);
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _birthdate.dispose();
    _address.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _refreshPasswordGuide() {
    if (mounted) setState(() {});
  }

  String? _serverError(AuthenticationState state, String field) =>
      state.fieldErrors[field]?.firstOrNull;

  Future<void> _pickBirthdate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthdate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'SELECT YOUR BIRTHDATE',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedBirthdate = picked;
      _birthdate.text = DateFormat.yMMMMd().format(picked);
    });
  }

  Future<void> _pickImage({required bool validId}) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (image == null || !mounted) return;
    final extension = image.path.split('.').last.toLowerCase();
    final size = await image.length();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension) ||
        size > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a JPG, PNG, or WEBP image up to 5 MB.'),
        ),
      );
      return;
    }
    setState(() {
      if (validId) {
        _validId = image;
      } else {
        _profilePhoto = image;
      }
    });
  }

  void _retryBarangays() {
    setState(() {
      _barangays = ref.read(authServiceProvider).getActiveBarangays();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that your information is accurate.'),
        ),
      );
      return;
    }
    final birthdate = _selectedBirthdate;
    final barangayId = _barangayId;
    if (birthdate == null || barangayId == null) return;
    setState(() => _uploadProgress = 0);
    await ref
        .read(authControllerProvider)
        .register(
          RegistrationRequest(
            email: _email.text,
            password: _password.text,
            fullName: _fullName.text,
            birthdate: birthdate,
            barangayId: barangayId,
            completeAddress: _address.text,
            phoneNumber: _phone.text,
            profilePhotoPath: _profilePhoto?.path,
            validIdImagePath: _validId?.path,
          ),
          onUploadProgress: (value) {
            if (mounted) setState(() => _uploadProgress = value);
          },
        );
    if (mounted) setState(() => _uploadProgress = null);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationStateProvider);
    final offline = ref
        .watch(connectivityStatusProvider)
        .when(
          data: (value) => value == ConnectivityStatus.offline,
          loading: () => false,
          error: (_, _) => false,
        );
    final submitting = authState.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: submitting ? null : () => context.pop(),
          tooltip: 'Back to sign in',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xl2,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SignupHero(),
                      const SizedBox(height: AppSpacing.lg),
                      if (offline || authState.message != null) ...[
                        _SignupNotice(
                          icon: offline
                              ? Icons.wifi_off_rounded
                              : Icons.info_outline_rounded,
                          message: offline
                              ? 'You are offline. Connect to the internet to create your account.'
                              : authState.message!,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _FormSection(
                        number: '1',
                        title: 'Personal information',
                        subtitle:
                            'Use the same details shown on your valid ID.',
                        children: [
                          TextFormField(
                            controller: _fullName,
                            enabled: !submitting,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            maxLength: 255,
                            decoration: InputDecoration(
                              labelText: 'Full name',
                              hintText: 'Juan Dela Cruz',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                              errorText: _serverError(authState, 'full_name'),
                            ),
                            validator: (value) =>
                                Validators.required(value, label: 'Full name'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _birthdate,
                            enabled: !submitting,
                            readOnly: true,
                            onTap: _pickBirthdate,
                            decoration: InputDecoration(
                              labelText: 'Birthdate',
                              hintText: 'Select your birthdate',
                              prefixIcon: const Icon(Icons.cake_outlined),
                              suffixIcon: const Icon(
                                Icons.calendar_month_outlined,
                              ),
                              errorText: _serverError(authState, 'birthdate'),
                            ),
                            validator: (_) => _selectedBirthdate == null
                                ? 'Birthdate is required.'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _phone,
                            enabled: !submitting,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            maxLength: 20,
                            decoration: InputDecoration(
                              labelText: 'Phone number (optional)',
                              hintText: '09XX XXX XXXX',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              errorText: _serverError(
                                authState,
                                'phone_number',
                              ),
                            ),
                            validator: (value) =>
                                (value?.trim().length ?? 0) > 20
                                ? 'Phone number cannot exceed 20 characters.'
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FormSection(
                        number: '2',
                        title: 'Resident address',
                        subtitle:
                            'Your barangay is verified during account review.',
                        children: [
                          FutureBuilder<List<BarangayOption>>(
                            future: _barangays,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const _BarangayLoading();
                              }
                              if (snapshot.hasError ||
                                  (snapshot.data?.isEmpty ?? true)) {
                                return _BarangayError(onRetry: _retryBarangays);
                              }
                              final options = snapshot.data!;
                              return DropdownButtonFormField<int>(
                                initialValue: _barangayId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Barangay',
                                  prefixIcon: const Icon(
                                    Icons.location_city_outlined,
                                  ),
                                  errorText: _serverError(
                                    authState,
                                    'barangay',
                                  ),
                                ),
                                hint: const Text('Select your barangay'),
                                items: options
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: Text(
                                          item.displayName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: submitting
                                    ? null
                                    : (value) =>
                                          setState(() => _barangayId = value),
                                validator: (value) => value == null
                                    ? 'Barangay is required.'
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _address,
                            enabled: !submitting,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            autofillHints: const [
                              AutofillHints.fullStreetAddress,
                            ],
                            minLines: 2,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Complete address',
                              hintText:
                                  'House/lot, street, subdivision or sitio',
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 48),
                                child: Icon(Icons.home_outlined),
                              ),
                              errorText: _serverError(
                                authState,
                                'complete_address',
                              ),
                            ),
                            validator: (value) => Validators.required(
                              value,
                              label: 'Complete address',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FormSection(
                        number: '3',
                        title: 'Account security',
                        subtitle: 'You will use these credentials to sign in.',
                        children: [
                          TextFormField(
                            controller: _email,
                            enabled: !submitting,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Email address',
                              hintText: 'you@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: _serverError(authState, 'email'),
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _password,
                            enabled: !submitting,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: submitting
                                    ? null
                                    : () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              errorText: _serverError(authState, 'password'),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: AppSpacing.smMd),
                          _PasswordGuide(password: _password.text),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _confirmPassword,
                            enabled: !submitting,
                            obscureText: _obscureConfirmation,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_reset_rounded),
                              suffixIcon: IconButton(
                                onPressed: submitting
                                    ? null
                                    : () => setState(
                                        () => _obscureConfirmation =
                                            !_obscureConfirmation,
                                      ),
                                tooltip: _obscureConfirmation
                                    ? 'Show password confirmation'
                                    : 'Hide password confirmation',
                                icon: Icon(
                                  _obscureConfirmation
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password.';
                              }
                              if (value != _password.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) =>
                                submitting || offline ? null : _submit(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FormSection(
                        number: '4',
                        title: 'Verification photos',
                        subtitle:
                            'Optional now. Adding clear photos can help CENRO review your registration.',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ImagePickerTile(
                                  title: 'Profile photo',
                                  subtitle: 'Clear face photo',
                                  icon: Icons.add_a_photo_outlined,
                                  image: _profilePhoto,
                                  onPick: submitting
                                      ? null
                                      : () => _pickImage(validId: false),
                                  onRemove: submitting
                                      ? null
                                      : () => setState(
                                          () => _profilePhoto = null,
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.smMd),
                              Expanded(
                                child: _ImagePickerTile(
                                  title: 'Valid ID',
                                  subtitle: 'Readable front side',
                                  icon: Icons.badge_outlined,
                                  image: _validId,
                                  onPick: submitting
                                      ? null
                                      : () => _pickImage(validId: true),
                                  onRemove: submitting
                                      ? null
                                      : () => setState(() => _validId = null),
                                ),
                              ),
                            ],
                          ),
                          if (_serverError(authState, 'profile_photo') !=
                                  null ||
                              _serverError(authState, 'valid_id_image') !=
                                  null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _serverError(authState, 'profile_photo') ??
                                  _serverError(authState, 'valid_id_image')!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CheckboxListTile(
                        value: _acceptTerms,
                        onChanged: submitting
                            ? null
                            : (value) =>
                                  setState(() => _acceptTerms = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'I confirm that the information I provided is true and accurate.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        subtitle: const Text(
                          'False information may cause the application to be rejected.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      if (submitting && _uploadProgress != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        LinearProgressIndicator(
                          value: _uploadProgress == 0 ? null : _uploadProgress,
                          borderRadius: AppRadius.circularBorderRadius,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _profilePhoto != null || _validId != null
                              ? 'Submitting registration and uploading photos…'
                              : 'Submitting your registration…',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: submitting || offline ? null : _submit,
                        icon: submitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.how_to_reg_rounded),
                        label: Text(
                          submitting
                              ? 'Creating your account…'
                              : 'Submit registration',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already registered?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: submitting ? null : () => context.pop(),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Use at least 8 characters.';
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Your password cannot be entirely numeric.';
    }
    if (!RegExp('[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
      return 'Use a mix of letters and numbers.';
    }
    return null;
  }
}

class _SignupHero extends StatelessWidget {
  const _SignupHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.heroStart, AppColors.heroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.extraLargeBorderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.largeBorderRadius,
            ),
            child: Image.asset(
              'assets/images/branding/ekoleklogo.png',
              fit: BoxFit.contain,
              semanticLabel: 'E-KOLEK logo',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join E-KOLEK',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Create your resident account and turn everyday eco-actions into community impact.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: .9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String number;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.subtleShadow,
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.mdLg),
          ...children,
        ],
      ),
    );
  }
}

class _PasswordGuide extends StatelessWidget {
  const _PasswordGuide({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('At least 8 characters', password.length >= 8),
      ('Contains letters', RegExp('[A-Za-z]').hasMatch(password)),
      ('Contains a number', RegExp(r'\d').hasMatch(password)),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: checks
          .map(
            (item) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: item.$2
                    ? AppColors.successContainer
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.circularBorderRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.$2
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 15,
                    color: item.$2
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    item.$1,
                    style: AppTextStyles.caption.copyWith(
                      color: item.$2
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final XFile? image;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = image != null;
    return InkWell(
      onTap: onPick,
      borderRadius: AppRadius.mediumBorderRadius,
      child: Container(
        height: 142,
        padding: const EdgeInsets.all(AppSpacing.smMd),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceVariant,
          borderRadius: AppRadius.mediumBorderRadius,
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.border,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected)
                    ClipRRect(
                      borderRadius: AppRadius.smallBorderRadius,
                      child: Image.file(
                        File(image!.path),
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(icon, size: 34, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    selected ? '$title added' : title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMedium,
                  ),
                  Text(
                    selected ? 'Tap to replace' : subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove $title',
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarangayLoading extends StatelessWidget {
  const _BarangayLoading();

  @override
  Widget build(BuildContext context) {
    return const InputDecorator(
      decoration: InputDecoration(
        labelText: 'Barangay',
        prefixIcon: Icon(Icons.location_city_outlined),
        suffixIcon: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      child: Text('Loading active barangays…'),
    );
  }
}

class _BarangayError extends StatelessWidget {
  const _BarangayError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.mediumBorderRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Barangays could not be loaded.',
              style: AppTextStyles.bodySmall,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SignupNotice extends StatelessWidget {
  const _SignupNotice({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: AppRadius.mediumBorderRadius,
          border: Border.all(color: AppColors.error.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.error),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
          ],
        ),
      ),
    );
  }
}
