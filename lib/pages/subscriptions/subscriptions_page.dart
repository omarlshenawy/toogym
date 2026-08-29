import 'package:flutter/material.dart';

import '../../api/members_api.dart';
import '../../api/plans_api.dart';
import '../../api/subscriptions_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({
    super.key,
  });

  @override
  State<SubscriptionsPage> createState() =>
      _SubscriptionsPageState();
}

class _SubscriptionsPageState
    extends State<SubscriptionsPage> {
  List<Map<String, dynamic>>
  _subscriptions = [];

  List<Map<String, dynamic>>
  _members = [];

  List<Map<String, dynamic>>
  _plans = [];

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _openSubscription;

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
      final result =
      await Future.wait([
        SubscriptionsApi
            .getSubscriptions(),
        MembersApi.getMembers(),
        PlansApi.getPlans(),
      ]);

      if (!mounted) return;

      setState(() {
        _subscriptions =
        result[0]
        as List<Map<String, dynamic>>;

        _members =
        result[1]
        as List<Map<String, dynamic>>;

        _plans =
        result[2]
        as List<Map<String, dynamic>>;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            _cleanError(e.toString());
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
            title: 'Subscriptions',
            subtitle:
            'Manage subscriptions for the current gym.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _members.isEmpty ||
                    _plans.isEmpty
                    ? null
                    : () {
                  setState(() {
                    _openSubscription =
                    {};
                  });
                },
                icon:
                const Icon(Icons.add),
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
                'Loading subscriptions...',
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
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_subscriptions.isEmpty) {
      return Card(
        child: SizedBox(
          height: 300,
          child: AppEmptyState(
            icon: Icons
                .card_membership_outlined,
            title:
            'No subscriptions',
            message:
            'Create a subscription for a member.',
            onAction:
            _members.isNotEmpty &&
                _plans.isNotEmpty
                ? () {
              setState(() {
                _openSubscription =
                {};
              });
            }
                : null,
            actionLabel:
            'New Subscription',
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
          columnSpacing: 30,
          columns: const [
            DataColumn(
              label: Text('Member'),
            ),
            DataColumn(
              label: Text('Plan'),
            ),
            DataColumn(
              label: Text('Period'),
            ),
            DataColumn(
              label: Text('Amount'),
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
              final member =
              _findMember(
                subscription[
                'member_id'],
              );

              final plan =
              _findPlan(
                subscription[
                'plan_id'],
              );

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      member == null
                          ? _shortId(
                        subscription[
                        'member_id']
                            ?.toString() ??
                            '',
                      )
                          : '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}',
                    ),
                  ),

                  DataCell(
                    Text(
                      plan?['name']
                          ?.toString() ??
                          _shortId(
                            subscription[
                            'plan_id']
                                ?.toString() ??
                                '',
                          ),
                    ),
                  ),

                  DataCell(
                    Text(
                      '${_date(subscription['start_date'])} — ${_date(subscription['end_date'])}',
                    ),
                  ),

                  DataCell(
                    Text(
                      _money(
                        subscription[
                        'amount'],
                      ),
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      subscription[
                      'status']
                          ?.toString() ??
                          '',
                    ),
                  ),

                  DataCell(
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _openSubscription =
                              subscription;
                        });
                      },
                      child:
                      const Text(
                        'Edit',
                      ),
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

  Map<String, dynamic>? _findMember(
      dynamic id,
      ) {
    final value = id?.toString();

    return _members
        .where(
          (member) =>
      member['id']
          ?.toString() ==
          value,
    )
        .firstOrNull;
  }

  Map<String, dynamic>? _findPlan(
      dynamic id,
      ) {
    final value = id?.toString();

    return _plans
        .where(
          (plan) =>
      plan['id']
          ?.toString() ==
          value,
    )
        .firstOrNull;
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
  }

  String _date(dynamic value) {
    if (value == null) {
      return '—';
    }

    final text = value.toString();

    return text.length >= 10
        ? text.substring(0, 10)
        : text;
  }

  String _money(dynamic value) {
    final number =
        double.tryParse(
          value?.toString() ??
              '',
        ) ??
            0;

    return '\$${number.toStringAsFixed(2)}';
  }

  String _cleanError(String value) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}

// =================================================================
// Subscription Dialog
// =================================================================

class _SubscriptionDialog
    extends StatefulWidget {
  final Map<String, dynamic>? subscription;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> plans;

  const _SubscriptionDialog({
    this.subscription,
    required this.members,
    required this.plans,
  });

  @override
  State<_SubscriptionDialog> createState() =>
      _SubscriptionDialogState();
}

class _SubscriptionDialogState
    extends State<_SubscriptionDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late String _memberId;
  late String _planId;
  late DateTime _startDate;
  DateTime? _endDate;

  late TextEditingController _amount;

  String _status = 'active';
  bool _autoRenew = false;
  bool _saving = false;

  bool get editing =>
      widget.subscription != null;

  @override
  void initState() {
    super.initState();

    final sub =
        widget.subscription;

    _memberId =
        sub?['member_id']
            ?.toString() ??
            widget.members.firstOrNull?[
            'id']?.toString() ??
            '';

    _planId =
        sub?['plan_id']
            ?.toString() ??
            widget.plans.firstOrNull?[
            'id']?.toString() ??
            '';

    _startDate =
        _parseDate(
          sub?['start_date'],
        ) ??
            DateTime.now();

    _endDate =
        _parseDate(
          sub?['end_date'],
        );

    final selectedPlan =
        widget.plans
            .where(
              (plan) =>
          plan['id']
              ?.toString() ==
              _planId,
        )
            .firstOrNull;

    _amount =
        TextEditingController(
          text: sub?['amount']
              ?.toString() ??
              selectedPlan?['price']
                  ?.toString() ??
              '',
        );

    _status =
        sub?['status']
            ?.toString() ??
            'active';

    _autoRenew =
        sub?['auto_renew'] ==
            true;

    if (_endDate == null &&
        selectedPlan != null) {
      _endDate =
          _addMonths(
            _startDate,
            _toInt(
              selectedPlan[
              'duration_months'],
            ),
          );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editing
            ? 'Update Subscription'
            : 'New Subscription',
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              if (!editing)
                _memberDropdown(),

              if (!editing)
                const SizedBox(
                  height: 14,
                ),

              if (!editing)
                _planDropdown(),

              if (!editing)
                const SizedBox(
                  height: 14,
                ),

              if (!editing)
                _dateField(
                  label:
                  'Start date',
                  value:
                  _startDate,
                  onChanged:
                      (date) {
                    setState(() {
                      _startDate =
                          date;

                      final plan =
                      _selectedPlan();

                      if (plan != null) {
                        _endDate =
                            _addMonths(
                              date,
                              _toInt(
                                plan[
                                'duration_months'],
                              ),
                            );
                      }
                    });
                  },
                ),

              if (!editing)
                const SizedBox(
                  height: 14,
                ),

              _dateField(
                label:
                'End date',
                value:
                _endDate,
                onChanged:
                    (date) {
                  setState(() {
                    _endDate =
                        date;
                  });
                },
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller:
                _amount,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                const InputDecoration(
                  labelText:
                  'Amount',
                ),
                validator:
                    (value) {
                  if (value ==
                      null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Amount is required';
                  }

                  if (double.tryParse(
                    value.trim(),
                  ) ==
                      null) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),

              if (editing) ...[
                const SizedBox(
                  height: 14,
                ),
                DropdownButtonFormField<
                    String>(
                  initialValue:
                  _status,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                      'active',
                      child:
                      Text('active'),
                    ),
                    DropdownMenuItem(
                      value:
                      'expired',
                      child:
                      Text('expired'),
                    ),
                    DropdownMenuItem(
                      value:
                      'cancelled',
                      child:
                      Text('cancelled'),
                    ),
                  ],
                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        _status =
                            value;
                      });
                    }
                  },
                ),
              ],

              const SizedBox(
                height: 8,
              ),

              CheckboxListTile(
                contentPadding:
                EdgeInsets.zero,
                value:
                _autoRenew,
                onChanged:
                    (value) {
                  setState(() {
                    _autoRenew =
                        value ??
                            false;
                  });
                },
                title:
                const Text(
                  'Auto renew',
                ),
              ),
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
            'Save subscription',
          ),
        ),
      ],
    );
  }

  Widget _memberDropdown() {
    return DropdownButtonFormField<
        String>(
      initialValue:
      _memberId.isEmpty
          ? null
          : _memberId,
      decoration:
      const InputDecoration(
        labelText:
        'Member',
      ),
      items: widget.members
          .map(
            (member) {
          final id =
              member['id']
                  ?.toString() ??
                  '';

          return DropdownMenuItem(
            value: id,
            child: Text(
              '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}',
            ),
          );
        },
      )
          .toList(),
      onChanged:
          (value) {
        if (value != null) {
          setState(() {
            _memberId =
                value;
          });
        }
      },
      validator:
          (value) {
        if (value ==
            null ||
            value.isEmpty) {
          return 'Select a member';
        }

        return null;
      },
    );
  }

  Widget _planDropdown() {
    return DropdownButtonFormField<
        String>(
      initialValue:
      _planId.isEmpty
          ? null
          : _planId,
      decoration:
      const InputDecoration(
        labelText:
        'Plan',
      ),
      items: widget.plans
          .map(
            (plan) {
          final id =
              plan['id']
                  ?.toString() ??
                  '';

          return DropdownMenuItem(
            value: id,
            child: Text(
              '${plan['name'] ?? 'Plan'} — ${_money(plan['price'])}',
            ),
          );
        },
      )
          .toList(),
      onChanged:
          (value) {
        if (value == null) {
          return;
        }

        final plan =
            widget.plans
                .where(
                  (p) =>
              p['id']
                  ?.toString() ==
                  value,
            )
                .firstOrNull;

        setState(() {
          _planId =
              value;

          _amount.text =
              plan?['price']
                  ?.toString() ??
                  '';

          if (plan != null) {
            _endDate =
                _addMonths(
                  _startDate,
                  _toInt(
                    plan[
                    'duration_months'],
                  ),
                );
          }
        });
      },
      validator:
          (value) {
        if (value ==
            null ||
            value.isEmpty) {
          return 'Select a plan';
        }

        return null;
      },
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime>
    onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date =
        await showDatePicker(
          context: context,
          initialDate:
          value ??
              DateTime.now(),
          firstDate:
          DateTime(2020),
          lastDate:
          DateTime(2100),
        );

        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration:
        InputDecoration(
          labelText: label,
        ),
        child: Text(
          value == null
              ? 'Select date'
              : _date(value),
        ),
      ),
    );
  }

  Map<String, dynamic>?
  _selectedPlan() {
    return widget.plans
        .where(
          (plan) =>
      plan['id']
          ?.toString() ==
          _planId,
    )
        .firstOrNull;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_endDate == null) {
      _showError(
        'Please select an end date.',
      );
      return;
    }

    final amount =
    double.tryParse(
      _amount.text.trim(),
    );

    if (amount == null) {
      _showError(
        'Please enter a valid amount.',
      );
      return;
    }

    final body =
    <String, dynamic>{
      'end_date':
      _date(_endDate!),
      'amount': amount,
      'auto_renew':
      _autoRenew,
    };

    if (!editing) {
      body.addAll({
        'member_id':
        _memberId,
        'plan_id':
        _planId,
        'start_date':
        _date(_startDate),
      });
    } else {
      body['status'] =
          _status;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (editing) {
        await SubscriptionsApi
            .updateSubscription(
          widget.subscription![
          'id']
              .toString(),
          body,
        );
      } else {
        await SubscriptionsApi
            .createSubscription(
          body,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
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

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  DateTime? _parseDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  DateTime _addMonths(
      DateTime date,
      int months,
      ) {
    return DateTime(
      date.year,
      date.month + months,
      date.day,
    );
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ??
          '',
    ) ??
        0;
  }

  String _date(
      dynamic value,
      ) {
    if (value is DateTime) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';
    }

    final text =
        value?.toString() ?? '';

    return text.length >= 10
        ? text.substring(0, 10)
        : text;
  }

  String _money(dynamic value) {
    final number =
        double.tryParse(
          value?.toString() ??
              '',
        ) ??
            0;

    return '\$${number.toStringAsFixed(2)}';
  }
}

// =================================================================

class _StatusBadge
    extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final normalized =
    value.toLowerCase();

    final active =
        normalized == 'active';

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
          fontSize: 12,
          fontWeight:
          FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

extension _FirstOrNull<T>
on Iterable<T> {
  T? get firstOrNull =>
      isEmpty ? null : first;
}