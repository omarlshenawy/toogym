import 'package:flutter/material.dart';

import '../../api/staff_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({
    super.key,
  });

  @override
  State<StaffPage> createState() =>
      _StaffPageState();
}

class _StaffPageState
    extends State<StaffPage> {
  List<Map<String, dynamic>> _rows = [];

  bool _loading = true;
  String? _error;

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
      final rows = await StaffApi.getStaff();

      if (!mounted) return;

      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanError(e.toString());
      });
    }
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
            title: 'Staff',
            subtitle:
            'Manage staff accounts for your gym.',
            actions: [
              ElevatedButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Staff',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_loading)
            const SizedBox(
              height: 300,
              child: AppLoading(
                message: 'Loading staff...',
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
    if (_rows.isEmpty) {
      return Card(
        child: SizedBox(
          height: 300,
          child: AppEmptyState(
            icon: Icons.people_outline,
            title: 'No staff yet',
            message:
            'Add a staff account to your gym.',
            onAction: _openCreate,
            actionLabel: 'Add Staff',
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 32,
          columns: const [
            DataColumn(
              label: Text('Staff'),
            ),
            DataColumn(
              label: Text('Position'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: _rows.map(
                (staff) {
              final id =
                  staff['id']?.toString() ??
                      '';

              final username =
              staff['username']
                  ?.toString();

              final userId =
              staff['user_id']
                  ?.toString();

              final displayName =
                  username ??
                      (userId != null &&
                          userId.isNotEmpty
                          ? '${_shortId(userId)}…'
                          : '—');

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      displayName,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      staff['position']
                          ?.toString() ??
                          '—',
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      staff['status']
                          ?.toString() ??
                          '',
                    ),
                  ),

                  DataCell(
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            _openEdit(
                              staff,
                            );
                          },
                          child:
                          const Text(
                            'Edit',
                          ),
                        ),
                        TextButton(
                          onPressed:
                          staff['status']
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
                          TextButton.styleFrom(
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
      builder: (context) {
        return const _StaffDialog();
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _openEdit(
      Map<String, dynamic> staff,
      ) async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _StaffDialog(
          staff: staff,
        );
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _disable(
      String staffId,
      ) async {
    final confirmed =
    await AppConfirmDialog.show(
      context: context,
      title: 'Disable staff?',
      message:
      'This will disable the staff account. The account will no longer be active.',
      confirmLabel: 'Disable',
    );

    if (!confirmed) {
      return;
    }

    try {
      await StaffApi.disableStaff(
        staffId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Staff disabled successfully.',
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
            _cleanError(
              e.toString(),
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

    return value.substring(0, 8);
  }

  String _cleanError(String value) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}

// =================================================================
// Staff Dialog
// =================================================================

class _StaffDialog extends StatefulWidget {
  final Map<String, dynamic>? staff;

  const _StaffDialog({
    this.staff,
  });

  @override
  State<_StaffDialog> createState() =>
      _StaffDialogState();
}

class _StaffDialogState
    extends State<_StaffDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _username;

  late final TextEditingController
  _firstName;

  late final TextEditingController
  _lastName;

  late final TextEditingController
  _position;

  String _status = 'active';

  bool _saving = false;

  bool get isEditing =>
      widget.staff != null;

  @override
  void initState() {
    super.initState();

    final staff = widget.staff;

    _username =
        TextEditingController(
          text:
          staff?['username']
              ?.toString() ??
              '',
        );

    _firstName =
        TextEditingController(
          text:
          staff?['first_name']
              ?.toString() ??
              '',
        );

    _lastName =
        TextEditingController(
          text:
          staff?['last_name']
              ?.toString() ??
              '',
        );

    _position =
        TextEditingController(
          text:
          staff?['position']
              ?.toString() ??
              '',
        );

    _status =
        staff?['status']
            ?.toString() ??
            'active';
  }

  @override
  void dispose() {
    _username.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _position.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Staff'
            : 'Create Staff',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              if (!isEditing)
                _field(
                  _username,
                  'Username',
                  required: true,
                ),

              if (!isEditing)
                const SizedBox(
                  height: 14,
                ),

              if (!isEditing)
                _field(
                  _firstName,
                  'First name',
                  required: true,
                ),

              if (!isEditing)
                const SizedBox(
                  height: 14,
                ),

              if (!isEditing)
                _field(
                  _lastName,
                  'Last name',
                ),

              if (!isEditing)
                const SizedBox(
                  height: 14,
                ),

              _field(
                _position,
                'Position',
                required: true,
              ),

              if (isEditing) ...[
                const SizedBox(
                  height: 14,
                ),
                DropdownButtonFormField<
                    String>(
                  initialValue: _status,
                  decoration:
                  const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child:
                      Text('active'),
                    ),
                    DropdownMenuItem(
                      value: 'disabled',
                      child:
                      Text('disabled'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status =
                            value;
                      });
                    }
                  },
                ),
              ],
            ],
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
            'Save',
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool required = false,
      }) {
    return TextFormField(
      controller: controller,
      decoration:
      InputDecoration(
        labelText: label,
      ),
      validator: required
          ? (value) {
        if (value == null ||
            value.trim().isEmpty) {
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

    final Map<String, dynamic> body;

    if (isEditing) {
      body = {
        'position':
        _position.text.trim(),
        'status': _status,
        'first_name':
        _firstName.text.trim().isEmpty
            ? null
            : _firstName.text.trim(),
        'last_name':
        _lastName.text.trim().isEmpty
            ? null
            : _lastName.text.trim(),
      };
    } else {
      body = {
        'username':
        _username.text.trim(),
        'first_name':
        _firstName.text.trim(),
        'last_name':
        _lastName.text.trim().isEmpty
            ? null
            : _lastName.text.trim(),
        'position':
        _position.text.trim(),
      };
    }

    setState(() {
      _saving = true;
    });

    try {
      if (isEditing) {
        await StaffApi.updateStaff(
          widget.staff!['id']
              .toString(),
          body,
        );

        if (!mounted) return;

        Navigator.pop(
          context,
          true,
        );
        return;
      }

      final result =
      await StaffApi.createStaff(
        body,
      );

      if (!mounted) return;

      await _showProvisionResult(
        result,
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

  Future<void> _showProvisionResult(
      Map<String, dynamic> result,
      ) async {
    final username =
        result['username']
            ?.toString() ??
            '—';

    final activationCode =
        result['activation_code']
            ?.toString() ??
            '—';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Staff created successfully',
          ),
          content: SelectableText(
            'Username: $username\n\n'
                'Activation code: $activationCode\n\n'
                'Give these details to the staff member. '
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
              const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

// =================================================================
// Status
// =================================================================

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
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}