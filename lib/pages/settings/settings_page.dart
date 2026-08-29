import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth.dart';
import '../../core/common_widgets.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../api/gym_settings_api.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _ownerController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _addressController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gym = await GymSettingsApi.getGym();

      if (!mounted) return;

      _nameController.text = gym['name']?.toString() ?? '';

      _ownerController.text = gym['owner_name']?.toString() ?? '';

      _emailController.text = gym['email']?.toString() ?? '';

      _phoneController.text = gym['phone']?.toString() ?? '';

      _addressController.text = gym['address']?.toString() ?? '';

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final mobile = Responsive.isMobile(context);

    if (_loading) {
      return const Center(
        child: AppLoading(
          message: 'Loading settings...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: AppErrorState(
          message: _error!,
          onRetry: _loadSettings,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        mobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Settings',
            subtitle: 'Manage your account and platform settings.',
          ),
          const SizedBox(
            height: 24,
          ),
          _buildAccountCard(),
          const SizedBox(
            height: 20,
          ),
          _buildGymCard(),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    final user = ref.watch(authProvider).user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(
              height: 20,
            ),
            _infoRow(
              'Username',
              user?.username ?? '—',
            ),
            const SizedBox(
              height: 12,
            ),
            _infoRow(
              'Role',
              user?.role ?? '—',
            ),
            const SizedBox(
              height: 12,
            ),
            _infoRow(
              'Status',
              user?.status ?? '—',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gym Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Update the information associated with your gym.',
              ),
              const SizedBox(
                height: 24,
              ),
              _field(
                controller: _nameController,
                label: 'Gym name',
                required: true,
              ),
              const SizedBox(
                height: 16,
              ),
              _field(
                controller: _ownerController,
                label: 'Owner name',
                required: true,
              ),
              const SizedBox(
                height: 16,
              ),
              _field(
                controller: _emailController,
                label: 'Email',
                required: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 16,
              ),
              _field(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 16,
              ),
              _field(
                controller: _addressController,
                label: 'Address',
                maxLines: 3,
              ),
              const SizedBox(
                height: 24,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save changes',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }

              return null;
            }
          : null,
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await GymSettingsApi.updateGym({
        'name': _nameController.text.trim(),
        'owner_name': _ownerController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Settings saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
