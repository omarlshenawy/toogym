import 'package:flutter/material.dart';

import '../../api/gyms_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class GymsPage extends StatefulWidget {
  const GymsPage({
    super.key,
  });

  @override
  State<GymsPage> createState() =>
      _GymsPageState();
}

class _GymsPageState
    extends State<GymsPage> {
  List<Map<String, dynamic>> _gyms = [];

  bool _loading = true;
  String? _error;

  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gyms =
      await GymsApi.getGyms();

      if (!mounted) return;

      setState(() {
        _gyms = gyms;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  List<Map<String, dynamic>>
  get _filtered {
    final query =
    _search.trim().toLowerCase();

    if (query.isEmpty) {
      return _gyms;
    }

    return _gyms.where(
          (gym) {
        final text = [
          gym['name'],
          gym['owner_name'],
          gym['email'],
        ]
            .map(
              (x) =>
          x?.toString() ?? '',
        )
            .join(' ')
            .toLowerCase();

        return text.contains(query);
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mobile =
    Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        mobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Gyms',
            subtitle:
            'Manage all gyms on the platform.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _openCreate,
                icon:
                const Icon(Icons.add),
                label:
                const Text(
                  'Add Gym',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          TextField(
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration:
            const InputDecoration(
              hintText:
              'Search gyms...',
              prefixIcon:
              Icon(Icons.search),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          if (_loading)
            const SizedBox(
              height: 300,
              child: AppLoading(
                message:
                'Loading gyms...',
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 300,
              child: AppErrorState(
                message: _error!,
                onRetry: _load,
              ),
            )
          else
            _buildTable(),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final gyms = _filtered;

    if (gyms.isEmpty) {
      return Card(
        child: SizedBox(
          height: 280,
          child: AppEmptyState(
            icon:
            Icons.store_outlined,
            title:
            _search.isEmpty
                ? 'No gyms'
                : 'No matching gyms',
            message:
            _search.isEmpty
                ? 'Create the first gym on the platform.'
                : 'Try a different search.',
            onAction:
            _search.isEmpty
                ? _openCreate
                : null,
            actionLabel:
            'Add Gym',
          ),
        ),
      );
    }

    return Card(
      clipBehavior:
      Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,
        child: DataTable(
          columnSpacing: 32,
          columns: const [
            DataColumn(
              label: Text('Gym'),
            ),
            DataColumn(
              label: Text('Owner'),
            ),
            DataColumn(
              label: Text('Contact'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: gyms.map(
                (gym) {
              final id =
              gym['id'].toString();

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 220,
                      child:
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            gym['name']
                                ?.toString() ??
                                '—',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                          Text(
                            _shortId(id),
                            style:
                            const TextStyle(
                              fontSize:
                              12,
                              color:
                              AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      gym['owner_name']
                          ?.toString() ??
                          '—',
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 220,
                      child:
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            gym['email']
                                ?.toString() ??
                                '—',
                          ),
                          Text(
                            gym['phone']
                                ?.toString()
                                .isNotEmpty ==
                                true
                                ? gym[
                            'phone']
                                .toString()
                                : '—',
                            style:
                            const TextStyle(
                              fontSize:
                              12,
                              color:
                              AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      gym['status']
                          ?.toString() ??
                          '',
                    ),
                  ),

                  DataCell(
                    Row(
                      mainAxisSize:
                      MainAxisSize
                          .min,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Gym detail page
                            // will be added next.
                          },
                          child:
                          const Text(
                            'View',
                          ),
                        ),
                        TextButton(
                          onPressed:
                          gym['status']
                              ?.toString()
                              .toLowerCase() ==
                              'disabled'
                              ? null
                              : () {
                            _disable(
                              id,
                            );
                          },
                          style:
                          TextButton
                              .styleFrom(
                            foregroundColor:
                            AppTheme
                                .danger,
                          ),
                          child:
                          const Text(
                            'Disable',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (_) =>
      const _CreateGymDialog(),
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _disable(
      String gymId,
      ) async {
    final confirmed =
    await AppConfirmDialog.show(
      context: context,
      title:
      'Disable gym?',
      message:
      'The gym will be disabled and will no longer be active.',
      confirmLabel:
      'Disable',
    );

    if (!confirmed) {
      return;
    }

    try {
      await GymsApi.disableGym(
        gymId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text(
            'Gym disabled',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }
}

class _StatusBadge
    extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        value.toLowerCase() ==
            'active';

    final color = active
        ? AppTheme.success
        : AppTheme.textSecondary;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty
            ? '—'
            : value,
        style: TextStyle(
          color: color,
          fontWeight:
          FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CreateGymDialog
    extends StatefulWidget {
  const _CreateGymDialog();

  @override
  State<_CreateGymDialog> createState() =>
      _CreateGymDialogState();
}

class _CreateGymDialogState
    extends State<_CreateGymDialog> {
  final _formKey =
  GlobalKey<FormState>();

  final _gymName =
  TextEditingController();

  final _ownerName =
  TextEditingController();

  final _email =
  TextEditingController();

  final _phone =
  TextEditingController();

  final _address =
  TextEditingController();

  final _username =
  TextEditingController();

  final _firstName =
  TextEditingController();

  final _lastName =
  TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _gymName.dispose();
    _ownerName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();

    _username.dispose();
    _firstName.dispose();
    _lastName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
      const Text(
        'Create Gym & Gym Admin',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Gym',
                  style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                _field(
                  _gymName,
                  'Name',
                  required: true,
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _ownerName,
                  'Owner name',
                  required: true,
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _email,
                  'Email',
                  required: true,
                  keyboardType:
                  TextInputType
                      .emailAddress,
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _phone,
                  'Phone',
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _address,
                  'Address',
                ),

                const SizedBox(
                  height: 24,
                ),

                Text(
                  'Gym Admin',
                  style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                _field(
                  _username,
                  'Username',
                  required: true,
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _firstName,
                  'First name',
                  required: true,
                ),

                const SizedBox(
                  height: 12,
                ),

                _field(
                  _lastName,
                  'Last name',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
            Navigator.pop(
              context,
              false,
            );
          },
          child:
          const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
          _saving ? null : _save,
          child: _saving
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color:
              Colors.white,
            ),
          )
              : const Text(
            'Create',
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool required = false,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller:
      controller,
      keyboardType:
      keyboardType,
      decoration:
      InputDecoration(
        labelText: label,
      ),
      validator:
      required
          ? (value) {
        if (value ==
            null ||
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
    });

    try {
      final result =
      await GymsApi.createGym({
        'gym': {
          'name':
          _gymName.text.trim(),
          'owner_name':
          _ownerName.text.trim(),
          'email':
          _email.text.trim(),
          'phone':
          _phone.text.trim().isEmpty
              ? null
              : _phone.text.trim(),
          'address':
          _address.text.trim().isEmpty
              ? null
              : _address.text.trim(),
        },
        'gym_admin': {
          'username':
          _username.text.trim(),
          'first_name':
          _firstName.text.trim(),
          'last_name':
          _lastName.text.trim().isEmpty
              ? null
              : _lastName.text.trim(),
        },
      });

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(
              'Gym created successfully',
            ),
            content:
            SelectableText(
              'Username: ${result['username'] ?? '—'}\n\n'
                  'Activation code: ${result['activation_code'] ?? '—'}\n\n'
                  'Give these details to the gym owner. '
                  'The activation code can be used once.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                const Text(
                  'Done',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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