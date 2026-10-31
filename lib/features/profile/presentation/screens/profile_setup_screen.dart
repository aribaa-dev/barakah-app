// lib/features/profile/presentation/screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/profile/domain/entities/salesman_profile.dart';
import 'package:order_link/features/profile/presentation/providers/profile_provider.dart';

/// First-launch screen: who is this salesman?
/// Also works for editing later (fields are pre-filled when a profile exists).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Fills the boxes once, when editing an existing profile.
  void _prefill(SalesmanProfile? profile) {
    if (_prefilled || profile == null) return;
    _prefilled = true;
    _nameController.text = profile.name;
    _businessController.text = profile.businessName;
    // Stored as +923001234567; the field shows only the part after +92.
    _phoneController.text = profile.phone
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^(92|0)'), '');
  }

  String? _required(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? 'Enter your $label' : null;

  /// User types 10 digits after +92, e.g. 3001234567.
  String? _validatePhone(String? value) {
    final digits = (value ?? '').trim();
    if (digits.isEmpty) return 'Enter your phone number';
    if (digits.length != 10 || !digits.startsWith('3')) {
      return 'Enter a valid number, e.g. 3001234567';
    }
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final saved = await ref
        .read(saveProfileControllerProvider.notifier)
        .save(
          SalesmanProfile(
            name: _nameController.text.trim(),
            businessName: _businessController.text.trim(),
            phone: '+92${_phoneController.text.trim()}',
          ),
        );
    if (!mounted) return;

    if (saved) {
      context.go(AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save. Check your internet and try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill when a profile already exists (editing).
    ref.listen(profileStreamProvider, (_, next) => _prefill(next.value));
    _prefill(ref.read(profileStreamProvider).value);

    final saving = ref.watch(saveProfileControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Set up your profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This is shown on your dashboard and kept with your orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 44),
                    _Field(
                      controller: _nameController,
                      label: 'Your name',
                      icon: Icons.badge_outlined,
                      capitalization: TextCapitalization.words,
                      validator: (v) => _required(v, 'name'),
                    ),
                    const SizedBox(height: 24),
                    _Field(
                      controller: _businessController,
                      label: 'Business / distributor name',
                      icon: Icons.business_rounded,
                      capitalization: TextCapitalization.words,
                      validator: (v) => _required(v, 'business name'),
                    ),
                    const SizedBox(height: 28),
                    _Field(
                      controller: _phoneController,
                      label: 'Phone number',
                      icon: Icons.phone_outlined,
                      prefixText: '+92 ',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp(r'^0')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save and continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? prefixText;
  final TextCapitalization capitalization;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?) validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.prefixText,
    this.capitalization = TextCapitalization.none,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: capitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14.5),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontSize: 14.5, color: Colors.black87),
        floatingLabelBehavior: prefixText != null
            ? FloatingLabelBehavior.always
            : null,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
