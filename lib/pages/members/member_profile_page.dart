import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/members_api.dart';
import '../../core/api_client.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../dashboard/dashboard_widgets.dart';

class MemberProfilePage extends StatefulWidget {
  final String memberId;

  const MemberProfilePage({
    super.key,
    required this.memberId,
  });

  @override
  State<MemberProfilePage> createState() =>
      _MemberProfilePageState();
}

class _MemberProfilePageState
    extends State<MemberProfilePage> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _member;

  List<Map<String, dynamic>>
  _subscriptions = [];

  List<Map<String, dynamic>>
  _payments = [];

  List<Map<String, dynamic>>
  _attendance = [];

  List<Map<String, dynamic>>
  _measurements = [];

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
      final results =
      await Future.wait([
        MembersApi.getMember(
          widget.memberId,
        ),
        MembersApi.getSubscriptions(),
        MembersApi.getPayments(),
        MembersApi.getAttendance(),
        MembersApi.getMeasurements(
          widget.memberId,
        ),
      ]);

      final member =
      results[0]
      as Map<String, dynamic>;

      final allSubscriptions =
      results[1]
      as List<Map<String, dynamic>>;

      final allPayments =
      results[2]
      as List<Map<String, dynamic>>;

      final allAttendance =
      results[3]
      as List<Map<String, dynamic>>;

      final measurements =
      results[4]
      as List<Map<String, dynamic>>;

      final memberId =
          widget.memberId;

      final subscriptions =
      allSubscriptions
          .where(
            (subscription) =>
        subscription[
        'member_id']
            ?.toString() ==
            memberId,
      )
          .toList();

      final subscriptionIds =
      subscriptions
          .map(
            (subscription) =>
            subscription['id']
                ?.toString(),
      )
          .whereType<String>()
          .toSet();

      final payments =
      allPayments
          .where(
            (payment) =>
            subscriptionIds
                .contains(
              payment[
              'subscription_id']
                  ?.toString(),
            ),
      )
          .toList();

      final attendance =
      allAttendance
          .where(
            (item) =>
        item['member_id']
            ?.toString() ==
            memberId,
      )
          .toList();

      if (!mounted) return;

      setState(() {
        _member = member;
        _subscriptions =
            subscriptions;
        _payments = payments;
        _attendance = attendance;
        _measurements =
            measurements;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanError(
          e.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppLoading(
        message: 'Loading member...',
      );
    }

    if (_error != null) {
      return AppErrorState(
        message: _error!,
        onRetry: _load,
      );
    }

    final member = _member;

    if (member == null) {
      return const AppErrorState(
        message: 'Member not found.',
      );
    }

    final activeSubscription =
        _subscriptions
            .where(
              (subscription) =>
          subscription[
          'status']
              ?.toString() ==
              'active',
        )
            .firstOrNull ??
            _subscriptions.firstOrNull;

    final activeAttendance =
        _attendance
            .where(
              (attendance) =>
          attendance[
          'check_out_time'] ==
              null,
        )
            .firstOrNull;

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
          _buildHeader(member),

          const SizedBox(height: 24),

          if (mobile)
            Column(
              children: [
                _buildProfileCard(member),
                const SizedBox(height: 16),
                _buildSubscriptionCard(
                  activeSubscription,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                  _buildProfileCard(
                    member,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                  _buildSubscriptionCard(
                    activeSubscription,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          _buildHistory(context),
        ],
      ),
    );
  }

  Widget _buildHeader(
      Map<String, dynamic> member,
      ) {
    final first =
        member['first_name']?.toString() ??
            '';

    final last =
        member['last_name']?.toString() ??
            '';

    final active =
        _attendance
            .where(
              (item) =>
          item['check_out_time'] ==
              null,
        )
            .firstOrNull;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppPageHeader(
                title: '$first $last',
                subtitle:
                'Member profile • ${_shortId(member['id']?.toString() ?? '')}…',
              ),
            ),

            const SizedBox(width: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                  _payments.isEmpty
                      ? _openPayment
                      : _openPayment,
                  icon: const Icon(
                    Icons.payments_outlined,
                  ),
                  label:
                  const Text('Payment'),
                ),

                OutlinedButton.icon(
                  onPressed: active != null
                      ? () => _checkOut(
                    active['id']
                        .toString(),
                  )
                      : () => _checkIn(
                    widget.memberId,
                  ),
                  icon: Icon(
                    active != null
                        ? Icons
                        .logout_outlined
                        : Icons
                        .login_outlined,
                  ),
                  label: Text(
                    active != null
                        ? 'Check Out'
                        : 'Check In',
                  ),
                ),

                OutlinedButton.icon(
                  onPressed:
                  _openMeasurement,
                  icon: const Icon(
                    Icons
                        .monitor_weight_outlined,
                  ),
                  label:
                  const Text('Measure'),
                ),

                ElevatedButton.icon(
                  onPressed:
                  _openSubscription,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label:
                  const Text('Renew Sub'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCard(
      Map<String, dynamic> member,
      ) {
    final first =
        member['first_name']?.toString() ??
            '';

    final last =
        member['last_name']?.toString() ??
            '';

    final email =
    member['email']?.toString();

    final phone =
        member['phone']?.toString() ?? '';

    return DashboardPanel(
      title: 'Profile',
      child: Column(
        children: [
          Row(
            children: [
              _avatar(
                first,
                last,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$first $last',
                      style:
                      const TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${email == null || email.isEmpty ? 'No email' : email} · $phone',
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color: AppTheme
                            .textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    _StatusBadge(
                      value: member[
                      'status']
                          ?.toString() ??
                          '',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _detailGrid([
            [
              'Date of birth',
              _formatDate(
                member[
                'date_of_birth'],
              ),
            ],
            [
              'Gender',
              member['gender']
                  ?.toString()
                  .isNotEmpty ==
                  true
                  ? member['gender']
                  .toString()
                  : '—',
            ],
            [
              'Height',
              member['height'] != null
                  ? '${member['height']} cm'
                  : '—',
            ],
            [
              'Weight',
              member['weight'] != null
                  ? '${member['weight']} kg'
                  : '—',
            ],
            [
              'Joined',
              _formatDate(
                member['joined_at'],
              ),
            ],
            [
              'Last visit',
              _formatDate(
                member[
                'last_visit_at'],
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      Map<String, dynamic>? subscription,
      ) {
    return DashboardPanel(
      title: 'Current Subscription',
      child: subscription == null
          ? const AppEmptyState(
        icon: Icons
            .card_membership_outlined,
        title:
        'No subscription yet.',
      )
          : Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            '${_shortId(subscription['plan_id']?.toString() ?? '')}…',
            style:
            const TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _detailGrid([
            [
              'Status',
              subscription['status']
                  ?.toString() ??
                  '—',
            ],
            [
              'Period',
              '${_formatDate(subscription['start_date'])} — ${_formatDate(subscription['end_date'])}',
            ],
            [
              'Amount',
              _money(
                subscription[
                'amount'],
              ),
            ],
            [
              'Auto renew',
              subscription[
              'auto_renew'] ==
                  true
                  ? 'Yes'
                  : 'No',
            ],
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.go(
                    '/subscriptions',
                  );
                },
                child: const Text(
                  'View all subscription history',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed:
                _exportMemberData,
                child: const Text(
                  'View Contract ↗',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(
      BuildContext context,
      ) {
    final mobile =
    Responsive.isMobile(context);

    final subscriptionPanel =
    DashboardPanel(
      title: 'Subscription History',
      child: _buildSubscriptionHistory(),
    );

    final paymentsPanel =
    DashboardPanel(
      title: 'Payments',
      child: _buildPayments(),
    );

    final attendancePanel =
    DashboardPanel(
      title: 'Attendance',
      child: _buildAttendance(),
    );

    if (mobile) {
      return Column(
        children: [
          subscriptionPanel,
          const SizedBox(height: 16),
          paymentsPanel,
          const SizedBox(height: 16),
          attendancePanel,
        ],
      );
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: subscriptionPanel,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: paymentsPanel,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: attendancePanel,
        ),
      ],
    );
  }

  Widget _buildSubscriptionHistory() {
    if (_subscriptions.isEmpty) {
      return const AppEmptyState(
        title: 'No subscriptions.',
      );
    }

    return Column(
      children: _subscriptions.map(
            (subscription) {
          return _listRow(
            subscription['status']
                ?.toString() ??
                '—',
            _formatDate(
              subscription[
              'end_date'],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildPayments() {
    if (_payments.isEmpty) {
      return const AppEmptyState(
        title: 'No payments.',
      );
    }

    return Column(
      children: _payments.map(
            (payment) {
          return _listRow(
            _money(
              payment['amount'],
            ),
            _formatDateTime(
              payment[
              'payment_date'],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildAttendance() {
    if (_attendance.isEmpty) {
      return const AppEmptyState(
        title: 'No attendance.',
      );
    }

    return Column(
      children: _attendance
          .take(7)
          .map(
            (attendance) {
          return _listRow(
            _formatDateTime(
              attendance[
              'check_in_time'],
            ),
            attendance[
            'check_out_time'] ==
                null
                ? 'In'
                : 'Out',
          );
        },
      )
          .toList(),
    );
  }

  Widget _listRow(
      String left,
      String right,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
          Text(
            right,
            style:
            const TextStyle(
              fontSize: 12,
              color:
              AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailGrid(
      List<List<String>> values,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
        constraints.maxWidth > 600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: values.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            columns,
            crossAxisSpacing: 20,
            mainAxisSpacing: 16,
            mainAxisExtent: 52,
          ),
          itemBuilder:
              (context, index) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  values[index][0],
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color: AppTheme
                        .textSecondary,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  values[index][1],
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _avatar(
      String first,
      String last,
      ) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.primary
            .withValues(alpha: 0.10),
        borderRadius:
        BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        '${first.isEmpty ? '?' : first[0]}${last.isEmpty ? '?' : last[0]}'
            .toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Future<void> _checkIn(
      String memberId,
      ) async {
    try {
      await MembersApi.checkIn(
        memberId,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Member checked in.',
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _checkOut(
      String attendanceId,
      ) async {
    try {
      await MembersApi.checkOut(
        attendanceId,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Member checked out.',
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _openPayment() async {
    if (_subscriptions.isEmpty) {
      _showMessage(
        'Create a subscription first, then record its payment.',
      );
      return;
    }

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _PaymentDialog(
          subscriptions:
          _subscriptions,
        );
      },
    );

    await _load();
  }

  Future<void> _openMeasurement() async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _MeasurementDialog(
          memberId:
          widget.memberId,
        );
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _openSubscription() async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _SubscriptionDialog(
          memberId:
          widget.memberId,
        );
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _exportMemberData() async {
    // Flutter Web download will be connected
    // when we build the shared web utilities.
    _showMessage(
      'Contract export will be connected with the web download utility.',
    );
  }

  void _showError(Object error) {
    if (!mounted) return;

    _showMessage(
      _cleanError(
        error.toString(),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  String _formatDate(dynamic value) {
    if (value == null) {
      return '—';
    }

    final text = value.toString();

    if (text.length >= 10) {
      return text.substring(0, 10);
    }

    return text;
  }

  String _formatDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return '—';
    }

    final text = value.toString();

    if (text.length >= 16) {
      return text
          .substring(0, 16)
          .replaceFirst('T', ' ');
    }

    return text;
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
  }

  String _cleanError(String error) {
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }

    return error;
  }
}

// =================================================================
// Payment Dialog
// =================================================================

class _PaymentDialog extends StatefulWidget {
  final List<Map<String, dynamic>>
  subscriptions;

  const _PaymentDialog({
    required this.subscriptions,
  });

  @override
  State<_PaymentDialog> createState() =>
      _PaymentDialogState();
}

class _PaymentDialogState
    extends State<_PaymentDialog> {
  late String _subscriptionId;
  late TextEditingController _amount;

  String _paymentMethod = 'cash';

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final first =
        widget.subscriptions.first;

    _subscriptionId =
        first['id'].toString();

    _amount =
        TextEditingController(
          text:
          first['amount']?.toString() ??
              '',
        );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Record Payment',
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue:
              _subscriptionId,
              decoration:
              const InputDecoration(
                labelText:
                'Subscription',
              ),
              items: widget
                  .subscriptions
                  .map(
                    (subscription) {
                  final id =
                  subscription[
                  'id']
                      .toString();

                  return DropdownMenuItem(
                    value: id,
                    child: Text(
                      '${subscription['start_date']} — ${subscription['end_date']}',
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                final subscription =
                widget
                    .subscriptions
                    .firstWhere(
                      (item) =>
                  item['id']
                      .toString() ==
                      value,
                );

                setState(() {
                  _subscriptionId =
                      value;

                  _amount.text =
                      subscription[
                      'amount']
                          ?.toString() ??
                          '';
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller: _amount,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                labelText: 'Amount',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<String>(
              initialValue:
              _paymentMethod,
              decoration:
              const InputDecoration(
                labelText:
                'Payment method',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('Cash'),
                ),
                DropdownMenuItem(
                  value: 'card',
                  child: Text('Card'),
                ),
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Text(
                    'Bank transfer',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod =
                        value;
                  });
                }
              },
            ),
          ],
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
          child: const Text(
            'Cancel',
          ),
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
              color: Colors.white,
            ),
          )
              : const Text(
            'Record payment',
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final amount =
    double.tryParse(
      _amount.text.trim(),
    );

    if (amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await MembersApi.createPayment({
        'subscription_id':
        _subscriptionId,
        'amount': amount,
        'payment_method':
        _paymentMethod,
      });

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

// =================================================================
// Measurement Dialog
// =================================================================

class _MeasurementDialog
    extends StatefulWidget {
  final String memberId;

  const _MeasurementDialog({
    required this.memberId,
  });

  @override
  State<_MeasurementDialog> createState() =>
      _MeasurementDialogState();
}

class _MeasurementDialogState
    extends State<_MeasurementDialog> {
  final _weight =
  TextEditingController();

  final _bodyFat =
  TextEditingController();

  final _bmi =
  TextEditingController();

  final _notes =
  TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _bodyFat.dispose();
    _bmi.dispose();
    _notes.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Record Measurement',
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            TextField(
              controller: _weight,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                labelText:
                'Weight',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bodyFat,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                labelText:
                'Body fat percentage',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bmi,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              decoration:
              const InputDecoration(
                labelText: 'BMI',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notes,
              decoration:
              const InputDecoration(
                labelText: 'Notes',
              ),
            ),
          ],
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
              color: Colors.white,
            ),
          )
              : const Text(
            'Save measurement',
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    try {
      await MembersApi.createMeasurement(
        widget.memberId,
        {
          'weight':
          double.tryParse(
            _weight.text.trim(),
          ),
          'body_fat_percentage':
          double.tryParse(
            _bodyFat.text.trim(),
          ),
          'bmi':
          double.tryParse(
            _bmi.text.trim(),
          ),
          'notes':
          _notes.text.trim().isEmpty
              ? null
              : _notes.text.trim(),
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

// =================================================================
// Subscription Dialog
// =================================================================

class _SubscriptionDialog
    extends StatefulWidget {
  final String memberId;

  const _SubscriptionDialog({
    required this.memberId,
  });

  @override
  State<_SubscriptionDialog> createState() =>
      _SubscriptionDialogState();
}

class _SubscriptionDialogState
    extends State<_SubscriptionDialog> {
  List<Map<String, dynamic>>
  _plans = [];

  String? _planId;

  DateTime _startDate =
  DateTime.now();

  DateTime? _endDate;

  final _amount =
  TextEditingController();

  bool _autoRenew = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      final response =
      await ApiClient.get(
        '/plans',
      );

      final data = response.data;

      final plans = data is List
          ? data
          .whereType<Map>()
          .map(
            (item) =>
        Map<String, dynamic>
            .from(item),
      )
          .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _plans = plans;
        _loading = false;
      });

      if (plans.isNotEmpty) {
        _selectPlan(
          plans.first,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

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

  void _selectPlan(
      Map<String, dynamic> plan,
      ) {
    final id =
    plan['id']?.toString();

    final price =
    double.tryParse(
      plan['price']?.toString() ??
          '',
    );

    final months =
    int.tryParse(
      plan['duration_months']
          ?.toString() ??
          '',
    );

    setState(() {
      _planId = id;

      if (price != null) {
        _amount.text =
            price.toString();
      }

      if (months != null) {
        _endDate = DateTime(
          _startDate.year,
          _startDate.month + months,
          _startDate.day,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create / Renew Subscription',
      ),
      content: SizedBox(
        width: 440,
        child: _loading
            ? const Padding(
          padding:
          EdgeInsets.all(30),
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        )
            : _plans.isEmpty
            ? const Text(
          'No membership plans are available. Create a plan first.',
        )
            : Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            DropdownButtonFormField<
                String>(
              initialValue:
              _planId,
              decoration:
              const InputDecoration(
                labelText:
                'Plan',
              ),
              items: _plans
                  .map(
                    (plan) {
                  return DropdownMenuItem<
                      String>(
                    value: plan[
                    'id']
                        ?.toString(),
                    child: Text(
                      '${plan['name'] ?? 'Plan'} — ${_money(plan['price'])}',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                final plan =
                _plans.firstWhere(
                      (item) =>
                  item['id']
                      ?.toString() ==
                      value,
                );

                _selectPlan(
                  plan,
                );
              },
            ),

            const SizedBox(
              height: 14,
            ),

            _dateButton(
              label:
              'Start date',
              date:
              _startDate,
              onPressed:
                  () =>
                  _chooseDate(
                    start: true,
                  ),
            ),

            const SizedBox(
              height: 14,
            ),

            _dateButton(
              label:
              'End date',
              date:
              _endDate,
              onPressed:
                  () =>
                  _chooseDate(
                    start: false,
                  ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
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
            ),

            const SizedBox(
              height: 8,
            ),

            CheckboxListTile(
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
              contentPadding:
              EdgeInsets.zero,
            ),
          ],
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
        if (!_loading &&
            _plans.isNotEmpty)
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

  Widget _dateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius:
      BorderRadius.circular(8),
      child: InputDecorator(
        decoration:
        InputDecoration(
          labelText: label,
        ),
        child: Text(
          date == null
              ? 'Select date'
              : _dateOnly(date),
        ),
      ),
    );
  }

  Future<void> _chooseDate({
    required bool start,
  }) async {
    final initial =
    start
        ? _startDate
        : (_endDate ??
        _startDate);

    final date =
    await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime(2100),
    );

    if (date == null) {
      return;
    }

    setState(() {
      if (start) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  Future<void> _save() async {
    if (_planId == null ||
        _planId!.isEmpty) {
      _showError(
        'Please select a membership plan.',
      );
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

    setState(() {
      _saving = true;
    });

    try {
      await MembersApi.createSubscription({
        'member_id':
        widget.memberId,
        'plan_id': _planId,
        'start_date':
        _dateOnly(_startDate),
        'end_date':
        _dateOnly(_endDate!),
        'amount': amount,
        'auto_renew':
        _autoRenew,
      });

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
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

  String _dateOnly(
      DateTime date,
      ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
// Status Badge
// =================================================================

class _StatusBadge extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        value.toLowerCase() ==
            'active';

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: (active
            ? AppTheme.success
            : AppTheme.textSecondary)
            .withValues(
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
          color: active
              ? AppTheme.success
              : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}