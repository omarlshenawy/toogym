import 'package:flutter/material.dart';

import '../../api/members_api.dart';
import '../../api/payments_api.dart';
import '../../api/plans_api.dart';
import '../../api/subscriptions_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({
    super.key,
  });

  @override
  State<PaymentsPage> createState() =>
      _PaymentsPageState();
}

class _PaymentsPageState
    extends State<PaymentsPage> {
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _subscriptions = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _plans = [];

  bool _loading = true;
  String? _error;

  bool _open = false;

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
        PaymentsApi.getPayments(),
        SubscriptionsApi.getSubscriptions(),
        MembersApi.getMembers(),
        PlansApi.getPlans(),
      ]);

      if (!mounted) return;

      setState(() {
        _payments =
        result[0]
        as List<Map<String, dynamic>>;

        _subscriptions =
        result[1]
        as List<Map<String, dynamic>>;

        _members =
        result[2]
        as List<Map<String, dynamic>>;

        _plans =
        result[3]
        as List<Map<String, dynamic>>;

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
            title: 'Payments',
            subtitle:
            'Manage payments for the current gym.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _subscriptions.isEmpty
                    ? null
                    : () {
                  setState(() {
                    _open = true;
                  });
                },
                icon:
                const Icon(
                  Icons.add,
                ),
                label:
                const Text(
                  'Record Payment',
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
                'Loading payments...',
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

          if (_open)
            _PaymentDialog(
              subscriptions:
              _subscriptions,
              onClose: () {
                setState(() {
                  _open = false;
                });
              },
              onSaved: () async {
                setState(() {
                  _open = false;
                });

                await _load();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_payments.isEmpty) {
      return Card(
        child: SizedBox(
          height: 300,
          child: AppEmptyState(
            icon:
            Icons.payments_outlined,
            title:
            'No payments',
            message:
            'Record a payment for a subscription.',
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
              label:
              Text('Member'),
            ),
            DataColumn(
              label:
              Text('Plan'),
            ),
            DataColumn(
              label:
              Text('Amount'),
            ),
            DataColumn(
              label:
              Text('Method'),
            ),
            DataColumn(
              label:
              Text('Status'),
            ),
            DataColumn(
              label:
              Text('Date'),
            ),
          ],
          rows: _payments.map(
                (payment) {
              final subscription =
                  _subscriptions
                      .where(
                        (sub) =>
                    sub['id']
                        ?.toString() ==
                        payment[
                        'subscription_id']
                            ?.toString(),
                  )
                      .firstOrNull;

              final member =
              subscription == null
                  ? null
                  : _members
                  .where(
                    (member) =>
                member['id']
                    ?.toString() ==
                    subscription[
                    'member_id']
                        ?.toString(),
              )
                  .firstOrNull;

              final plan =
              subscription == null
                  ? null
                  : _plans
                  .where(
                    (plan) =>
                plan['id']
                    ?.toString() ==
                    subscription[
                    'plan_id']
                        ?.toString(),
              )
                  .firstOrNull;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      member == null
                          ? _shortId(
                        payment[
                        'subscription_id']
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
                          'Subscription',
                    ),
                  ),

                  DataCell(
                    Text(
                      _money(
                        payment[
                        'amount'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      payment[
                      'payment_method']
                          ?.toString()
                          .isNotEmpty ==
                          true
                          ? payment[
                      'payment_method']
                          .toString()
                          : '—',
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      payment[
                      'status']
                          ?.toString() ??
                          '',
                    ),
                  ),

                  DataCell(
                    Text(
                      _formatDateTime(
                        payment[
                        'payment_date'],
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

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8);
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

  String _formatDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return '—';
    }

    final text =
    value.toString();

    if (text.length >= 16) {
      return text
          .substring(0, 16)
          .replaceFirst(
        'T',
        ' ',
      );
    }

    return text;
  }
}

// =================================================================

class _PaymentDialog
    extends StatefulWidget {
  final List<Map<String, dynamic>>
  subscriptions;

  final VoidCallback onClose;
  final Future<void> Function()
  onSaved;

  const _PaymentDialog({
    required this.subscriptions,
    required this.onClose,
    required this.onSaved,
  });

  @override
  State<_PaymentDialog> createState() =>
      _PaymentDialogState();
}

class _PaymentDialogState
    extends State<_PaymentDialog> {
  late String _subscriptionId;

  late TextEditingController
  _amount;

  String _paymentMethod =
      'cash';

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
          first['amount']
              ?.toString() ??
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
      title:
      const Text(
        'Record Payment',
      ),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            DropdownButtonFormField<
                String>(
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
                      '${subscription['start_date']} — ${subscription['end_date']} · ${_money(subscription['amount'])}',
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

                final sub = widget
                    .subscriptions
                    .where(
                      (item) =>
                  item['id']
                      .toString() ==
                      value,
                )
                    .firstOrNull;

                setState(() {
                  _subscriptionId =
                      value;

                  _amount.text =
                      sub?['amount']
                          ?.toString() ??
                          '';
                });
              },
            ),

            const SizedBox(
              height: 16,
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
              height: 16,
            ),

            DropdownButtonFormField<
                String>(
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
                  child:
                  Text('Cash'),
                ),
                DropdownMenuItem(
                  value: 'card',
                  child:
                  Text('Card'),
                ),
                DropdownMenuItem(
                  value:
                  'bank_transfer',
                  child:
                  Text(
                    'Bank transfer',
                  ),
                ),
              ],
              onChanged:
                  (value) {
                if (value !=
                    null) {
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
          onPressed:
          _saving
              ? null
              : widget.onClose,
          child:
          const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
          _saving
              ? null
              : _save,
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
      _showError(
        'Please enter a valid amount.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await PaymentsApi
          .createPayment({
        'subscription_id':
        _subscriptionId,
        'amount':
        amount,
        'payment_method':
        _paymentMethod,
      });

      await widget.onSaved();
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
        content:
        Text(message),
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
            'completed' ||
            value.toLowerCase() ==
                'paid' ||
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