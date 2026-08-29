import 'package:flutter/material.dart';

import '../../api/gyms_api.dart';
import '../../api/gym_subscriptions_api.dart';
import '../../api/saas_plans_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class GymSubscriptionsPage extends StatefulWidget {
  const GymSubscriptionsPage({
    super.key,
  });

  @override
  State<GymSubscriptionsPage> createState() =>
      _GymSubscriptionsPageState();
}

class _GymSubscriptionsPageState
    extends State<GymSubscriptionsPage> {
  List<Map<String, dynamic>> _subscriptions = [];
  List<Map<String, dynamic>> _gyms = [];
  List<Map<String, dynamic>> _plans = [];

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
      final result = await Future.wait([
        GymSubscriptionsApi.getSubscriptions(),
        GymsApi.getGyms(),
        SaasPlansApi.getPlans(),
      ]);

      if (!mounted) return;

      setState(() {
        _subscriptions =
        result[0] as List<Map<String, dynamic>>;
        _gyms =
        result[1] as List<Map<String, dynamic>>;
        _plans =
        result[2] as List<Map<String, dynamic>>;
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
    final mobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Gym Subscriptions',
            subtitle:
            'Manage platform subscriptions for each gym.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _gyms.isEmpty || _plans.isEmpty
                    ? null
                    : _openCreate,
                icon: const Icon(Icons.add),
                label: const Text(
                  'New Subscription',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_loading)
            const SizedBox(
              height: 300,
              child: AppLoading(
                message:
                'Loading gym subscriptions...',
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
    if (_subscriptions.isEmpty) {
      return Card(
        child: SizedBox(
          height: 280,
          child: AppEmptyState(
            icon: Icons.subscriptions_outlined,
            title: 'No gym subscriptions',
            message:
            'Create a SaaS subscription for a gym.',
            onAction:
            _gyms.isEmpty || _plans.isEmpty
                ? null
                : _openCreate,
            actionLabel: 'New Subscription',
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 34,
          columns: const [
            DataColumn(
              label: Text('Gym'),
            ),
            DataColumn(
              label: Text('Plan'),
            ),
            DataColumn(
              label: Text('Period'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: _subscriptions.map(
                (subscription) {
              final gym = _findById(
                _gyms,
                subscription['gym_id'],
              );

              final plan = _findById(
                _plans,
                subscription['saas_plan_id'],
              );

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      gym?['name']?.toString() ??
                          _shortId(
                            subscription['gym_id']
                                ?.toString() ??
                                '',
                          ),
                    ),
                  ),

                  DataCell(
                    Text(
                      plan?['name']?.toString() ??
                          _shortId(
                            subscription[
                            'saas_plan_id']
                                ?.toString() ??
                                '',
                          ),
                    ),
                  ),

                  DataCell(
                    Text(
                      '${_date(subscription['start_date'])} — '
                          '${_date(subscription['end_date'])}',
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      subscription['status']
                          ?.toString() ??
                          '',
                    ),
                  ),

                  DataCell(
                    TextButton(
                      onPressed: () {
                        _openEdit(subscription);
                      },
                      child: const Text('Edit'),
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
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => GymSubscriptionDialog(
        gyms: _gyms,
        plans: _plans,
      ),
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _openEdit(
      Map<String, dynamic> subscription,
      ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => GymSubscriptionDialog(
        gyms: _gyms,
        plans: _plans,
        subscription: subscription,
      ),
    );

    if (saved == true) {
      await _load();
    }
  }

  Map<String, dynamic>? _findById(
      List<Map<String, dynamic>> list,
      dynamic id,
      ) {
    final value = id?.toString();

    for (final item in list) {
      if (item['id']?.toString() == value) {
        return item;
      }
    }

    return null;
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }

  String _date(dynamic value) {
    if (value == null) {
      return '—';
    }

    final text = value.toString();

    if (text.length >= 10) {
      return text.substring(0, 10);
    }

    return text;
  }

  String _cleanError(String value) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}

class GymSubscriptionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> gyms;
  final List<Map<String, dynamic>> plans;
  final Map<String, dynamic>? subscription;

  const GymSubscriptionDialog({
    super.key,
    required this.gyms,
    required this.plans,
    this.subscription,
  });

  @override
  State<GymSubscriptionDialog> createState() =>
      _GymSubscriptionDialogState();
}

class _GymSubscriptionDialogState
    extends State<GymSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _gymId;
  late String _planId;
  late String _startDate;
  late String _endDate;
  late String _status;

  bool _saving = false;

  bool get editing =>
      widget.subscription != null;

  @override
  void initState() {
    super.initState();

    final subscription = widget.subscription;

    _gymId =
        subscription?['gym_id']?.toString() ??
            widget.gyms.firstOrNull?['id']?.toString() ??
            '';

    _planId =
        subscription?['saas_plan_id']?.toString() ??
            widget.plans.firstOrNull?['id']?.toString() ??
            '';

    _startDate =
        subscription?['start_date']?.toString() ??
            _today();

    _endDate =
        subscription?['end_date']?.toString() ??
            '';

    _status =
        subscription?['status']?.toString() ??
            'active';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editing
            ? 'Update Gym Subscription'
            : 'New Gym Subscription',
      ),
      content: SizedBox(
        width: 470,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue:
                _gymId.isEmpty ? null : _gymId,
                decoration: const InputDecoration(
                  labelText: 'Gym',
                ),
                items: widget.gyms.map(
                      (gym) {
                    final id =
                        gym['id']?.toString() ?? '';

                    return DropdownMenuItem(
                      value: id,
                      child: Text(
                        gym['name']?.toString() ??
                            id,
                      ),
                    );
                  },
                ).toList(),
                onChanged: editing
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    _gymId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a gym';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue:
                _planId.isEmpty ? null : _planId,
                decoration: const InputDecoration(
                  labelText: 'SaaS plan',
                ),
                items: widget.plans.map(
                      (plan) {
                    final id =
                        plan['id']?.toString() ?? '';

                    return DropdownMenuItem(
                      value: id,
                      child: Text(
                        plan['name']?.toString() ??
                            id,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _planId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a SaaS plan';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _dateField(
                label: 'Start date',
                value: _startDate,
                onChanged: (value) {
                  setState(() {
                    _startDate = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _dateField(
                label: 'End date',
                value: _endDate,
                onChanged: (value) {
                  setState(() {
                    _endDate = value;
                  });
                },
              ),

              if (editing) ...[
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('active'),
                    ),
                    DropdownMenuItem(
                      value: 'expired',
                      child: Text('expired'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _status = value;
                    });
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
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
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
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    DateTime initial =
        DateTime.tryParse(value) ??
            DateTime.now();

    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (selected == null) return;

        final formatted =
            '${selected.year.toString().padLeft(4, '0')}-'
            '${selected.month.toString().padLeft(2, '0')}-'
            '${selected.day.toString().padLeft(2, '0')}';

        onChanged(formatted);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
        ),
        child: Text(
          value.isEmpty ? 'Select date' : value,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate.isEmpty || _endDate.isEmpty) {
      _showError(
        'Start date and end date are required.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final body = <String, dynamic>{
        'saas_plan_id': _planId,
        'start_date': _startDate,
        'end_date': _endDate,
      };

      if (!editing) {
        body['gym_id'] = _gymId;
      } else {
        body['status'] = _status;
      }

      if (editing) {
        await GymSubscriptionsApi.updateSubscription(
          widget.subscription!['id'].toString(),
          body,
        );
      } else {
        await GymSubscriptionsApi.createSubscription(
          {
            'gym_id': _gymId,
            'saas_plan_id': _planId,
            'start_date': _startDate,
            'end_date': _endDate,
          },
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _today() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        value.toLowerCase() == 'active';

    final color = active
        ? AppTheme.success
        : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull =>
      isEmpty ? null : first;
}