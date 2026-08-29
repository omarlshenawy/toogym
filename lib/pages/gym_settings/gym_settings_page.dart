import 'package:flutter/material.dart';

import '../../api/gym_settings_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class GymSettingsPage extends StatefulWidget {
  final String role;

  const GymSettingsPage({
    super.key,
    required this.role,
  });

  @override
  State<GymSettingsPage> createState() =>
      _GymSettingsPageState();
}

class _GymSettingsPageState
    extends State<GymSettingsPage> {
  Map<String, dynamic>? _gym;

  bool _loading = true;
  bool _saving = false;
  bool _testingConnection = false;

  String? _error;
  String _message = '';

  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _name;

  late final TextEditingController
  _ownerName;

  late final TextEditingController
  _email;

  late final TextEditingController
  _phone;

  late final TextEditingController
  _address;

  @override
  void initState() {
    super.initState();

    _name =
        TextEditingController();

    _ownerName =
        TextEditingController();

    _email =
        TextEditingController();

    _phone =
        TextEditingController();

    _address =
        TextEditingController();

    if (widget.role ==
        'gym_admin') {
      _loadGym();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _ownerName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();

    super.dispose();
  }

  Future<void> _loadGym() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gym =
      await GymSettingsApi
          .getGym();

      if (!mounted) return;

      _gym = gym;

      _name.text =
          gym['name']
              ?.toString() ??
              '';

      _ownerName.text =
          gym['owner_name']
              ?.toString() ??
              '';

      _email.text =
          gym['email']
              ?.toString() ??
              '';

      _phone.text =
          gym['phone']
              ?.toString() ??
              '';

      _address.text =
          gym['address']
              ?.toString() ??
              '';

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            _cleanError(
              e.toString(),
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role ==
        'saas_admin') {
      return _buildSaasSettings();
    }

    return _buildGymSettings();
  }

  Widget _buildSaasSettings() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        Responsive.isMobile(context)
            ? 16
            : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Settings',
            subtitle:
            'Platform settings and API connectivity.',
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend connection',
                    style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    'API is configured through the Flutter environment configuration.',
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ElevatedButton(
                    onPressed:
                    _testingConnection
                        ? null
                        : _testConnection,
                    child:
                    _testingConnection
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Text(
                      'Test connection',
                    ),
                  ),

                  if (_message.isNotEmpty) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      _message,
                      style:
                      const TextStyle(
                        color:
                        AppTheme.success,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymSettings() {
    if (_loading) {
      return const Center(
        child: AppLoading(
          message:
          'Loading gym settings...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: AppErrorState(
          message: _error!,
          onRetry: _loadGym,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        Responsive.isMobile(context)
            ? 16
            : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Gym Settings',
            subtitle:
            'Update your gym information.',
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                24,
              ),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final columns =
                    constraints.maxWidth >
                        750
                        ? 2
                        : 1;

                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'Gym information',
                          style:
                          Theme.of(
                            context,
                          )
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        GridView.count(
                          crossAxisCount:
                          columns,
                          shrinkWrap:
                          true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          crossAxisSpacing:
                          18,
                          mainAxisSpacing:
                          18,
                          childAspectRatio:
                          columns == 2
                              ? 4.8
                              : 5.5,
                          children: [
                            _field(
                              controller:
                              _name,
                              label:
                              'Name',
                              required:
                              true,
                            ),
                            _field(
                              controller:
                              _ownerName,
                              label:
                              'Owner name',
                              required:
                              true,
                            ),
                            _field(
                              controller:
                              _email,
                              label:
                              'Email',
                              keyboardType:
                              TextInputType
                                  .emailAddress,
                              required:
                              true,
                            ),
                            _field(
                              controller:
                              _phone,
                              label:
                              'Phone',
                            ),
                            _field(
                              controller:
                              _address,
                              label:
                              'Address',
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Align(
                          alignment:
                          Alignment
                              .centerRight,
                          child:
                          ElevatedButton(
                            onPressed:
                            _saving
                                ? null
                                : _save,
                            child: _saving
                                ? const SizedBox(
                              width:
                              18,
                              height:
                              18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Text(
                              'Save changes',
                            ),
                          ),
                        ),

                        if (_message
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            _message,
                            style:
                            const TextStyle(
                              color:
                              AppTheme
                                  .success,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController
    controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      keyboardType,
      decoration:
      InputDecoration(
        labelText: label,
      ),
      validator: required
          ? (value) {
        if (value == null ||
            value
                .trim()
                .isEmpty) {
          return '$label is required';
        }

        return null;
      }
          : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _message = '';
    });

    try {
      final gym =
      await GymSettingsApi
          .updateGym({
        'name':
        _name.text.trim(),
        'owner_name':
        _ownerName.text.trim(),
        'email':
        _email.text.trim(),
        'phone':
        _phone.text.trim().isEmpty
            ? null
            : _phone.text.trim(),
        'address':
        _address.text
            .trim()
            .isEmpty
            ? null
            : _address.text.trim(),
      });

      if (!mounted) return;

      setState(() {
        _gym = gym;
        _message = 'Saved';
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text('Gym settings saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(
              e.toString(),
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

  Future<void>
  _testConnection() async {
    setState(() {
      _testingConnection = true;
      _message = '';
    });

    try {
      await GymSettingsApi
          .testConnection();

      if (!mounted) return;

      setState(() {
        _message =
        'Backend is online';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message =
            _cleanError(
              e.toString(),
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _testingConnection = false;
        });
      }
    }
  }

  String _cleanError(
      String value,
      ) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}