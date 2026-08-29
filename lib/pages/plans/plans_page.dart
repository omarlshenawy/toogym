import 'package:flutter/material.dart';

import '../../api/plans_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({
    super.key,
  });

  @override
  State<PlansPage> createState() =>
      _PlansPageState();
}

class _PlansPageState
    extends State<PlansPage> {
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
      final rows =
      await PlansApi.getPlans();

      if (!mounted) return;

      setState(() {
        _rows = rows;
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
            title: 'Plans',
            subtitle:
            'Membership plans offered by your gym.',
            actions: [
              ElevatedButton.icon(
                onPressed: _openCreate,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'New Plan',
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
                'Loading plans...',
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
            icon: Icons
                .card_membership_outlined,
            title:
            'No membership plans',
            message:
            'Create your first membership plan.',
            onAction:
            _openCreate,
            actionLabel:
            'New Plan',
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
              Text('Plan'),
            ),
            DataColumn(
              label:
              Text('Price'),
            ),
            DataColumn(
              label:
              Text('Duration'),
            ),
            DataColumn(
              label:
              Text('Status'),
            ),
            DataColumn(
              label:
              Text('Actions'),
            ),
          ],
          rows: _rows.map(
                (plan) {
              final id =
                  plan['id']
                      ?.toString() ??
                      '';

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
                            plan['name']
                                ?.toString() ??
                                '—',
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            plan['description']
                                ?.toString()
                                .isNotEmpty ==
                                true
                                ? plan[
                            'description']
                                .toString()
                                : '—',
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontSize:
                              12,
                              color: AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      _money(
                        plan['price'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      '${plan['duration_months'] ?? 0} months',
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value:
                      plan['status']
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
                          onPressed:
                              () {
                            _openEdit(
                              plan,
                            );
                          },
                          child:
                          const Text(
                            'Edit',
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () {
                            _delete(
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
                            'Delete',
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
        return const _PlanDialog();
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _openEdit(
      Map<String, dynamic> plan,
      ) async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _PlanDialog(
          plan: plan,
        );
      },
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _delete(
      String planId,
      ) async {
    final confirmed =
    await AppConfirmDialog.show(
      context: context,
      title: 'Delete plan?',
      message:
      'This will permanently delete the membership plan.',
      confirmLabel: 'Delete',
    );

    if (!confirmed) {
      return;
    }

    try {
      await PlansApi.deletePlan(
        planId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Plan deleted successfully.',
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

  String _money(dynamic value) {
    final number =
        double.tryParse(
          value?.toString() ??
              '',
        ) ??
            0;

    return '\$${number.toStringAsFixed(2)}';
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

// =================================================================
// Plan Dialog
// =================================================================

class _PlanDialog
    extends StatefulWidget {
  final Map<String, dynamic>? plan;

  const _PlanDialog({
    this.plan,
  });

  @override
  State<_PlanDialog> createState() =>
      _PlanDialogState();
}

class _PlanDialogState
    extends State<_PlanDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _name;

  late final TextEditingController
  _description;

  late final TextEditingController
  _price;

  late final TextEditingController
  _duration;

  String _status = 'active';

  bool _saving = false;

  bool get isEditing =>
      widget.plan != null;

  @override
  void initState() {
    super.initState();

    final plan = widget.plan;

    _name =
        TextEditingController(
          text:
          plan?['name']
              ?.toString() ??
              '',
        );

    _description =
        TextEditingController(
          text:
          plan?['description']
              ?.toString() ??
              '',
        );

    _price =
        TextEditingController(
          text:
          plan?['price']
              ?.toString() ??
              '',
        );

    _duration =
        TextEditingController(
          text:
          plan?['duration_months']
              ?.toString() ??
              '1',
        );

    _status =
        plan?['status']
            ?.toString() ??
            'active';
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Plan'
            : 'New Plan',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              _field(
                _name,
                'Name',
                required: true,
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _description,
                'Description',
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _price,
                'Price',
                required: true,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _duration,
                'Duration (months)',
                required: true,
                keyboardType:
                TextInputType.number,
              ),

              if (isEditing) ...[
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
                      value: 'active',
                      child:
                      Text('active'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child:
                      Text('inactive'),
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
              : Text(
            isEditing
                ? 'Save changes'
                : 'Save plan',
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
      controller: controller,
      keyboardType: keyboardType,
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

    final price =
    double.tryParse(
      _price.text.trim(),
    );

    final duration =
    int.tryParse(
      _duration.text.trim(),
    );

    if (price == null) {
      _showError(
        'Please enter a valid price.',
      );
      return;
    }

    if (duration == null ||
        duration <= 0) {
      _showError(
        'Duration must be at least 1 month.',
      );
      return;
    }

    final body =
    <String, dynamic>{
      'name':
      _name.text.trim(),
      'description':
      _description.text
          .trim()
          .isEmpty
          ? null
          : _description.text.trim(),
      'price': price,
      'duration_months':
      duration,
    };

    if (isEditing) {
      body['status'] = _status;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (isEditing) {
        await PlansApi.updatePlan(
          widget.plan!['id']
              .toString(),
          body,
        );
      } else {
        await PlansApi.createPlan(
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
}

// =================================================================
// Status Badge
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